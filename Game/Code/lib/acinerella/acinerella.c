/*
    This file is part of Acinerella.

    Acinerella is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Acinerella is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Acinerella.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdlib.h>
#include <stdbool.h>
#include "acinerella.h"
#include <libavformat/avformat.h>
#include <libavformat/avio.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libswscale/swscale.h>
#include <string.h>

#define AUDIO_BUFFER_BASE_SIZE ((AVCODEC_MAX_AUDIO_FRAME_SIZE * 3) / 2)

//This struct represents one Acinerella video object.
//It contains data needed by FFMpeg.
struct _ac_data {
  ac_instance instance;
  
  AVFormatContext *pFormatCtx;
  
  void *sender;
  ac_openclose_callback open_proc;
  ac_read_callback read_proc; 
  ac_seek_callback seek_proc; 
  ac_openclose_callback close_proc; 
  
  URLProtocol protocol;
  char protocol_name[9];  
};

typedef struct _ac_data ac_data;
typedef ac_data* lp_ac_data;

struct _ac_decoder_data {
  ac_decoder decoder;
  int sought;
  double last_timecode;
};

typedef struct _ac_decoder_data ac_decoder_data;
typedef ac_decoder_data* lp_ac_decoder_data;

struct _ac_video_decoder {
  ac_decoder decoder;
  int sought;
  double last_timecode;
  AVCodec *pCodec;
  AVCodecContext *pCodecCtx;
  AVFrame *pFrame;
  AVFrame *pFrameRGB; 
  struct SwsContext *pSwsCtx;  
};

typedef struct _ac_video_decoder ac_video_decoder;
typedef ac_video_decoder* lp_ac_video_decoder;

struct _ac_audio_decoder {
  ac_decoder decoder;
  int sought;
  double last_timecode;
  int max_buffer_size;
  AVCodec *pCodec;
  AVCodecContext *pCodecCtx;
};

typedef struct _ac_audio_decoder ac_audio_decoder;
typedef ac_audio_decoder* lp_ac_audio_decoder;

struct _ac_package_data {
  ac_package package;
  AVPacket ffpackage;
  int pts;
};

typedef struct _ac_package_data ac_package_data;
typedef ac_package_data* lp_ac_package_data;

//
//---Small functions that are missing in FFMpeg ;-) ---
//

//Deletes a protocol from the FFMpeg protocol list
void unregister_protocol(URLProtocol *protocol) {
  URLProtocol *pcurrent = first_protocol;
  URLProtocol *plast = NULL;	
  
  while (pcurrent != NULL) {
    //Search for the protocol that is given as parameter
    if (pcurrent == protocol) {
      if (plast != NULL) {
        plast->next = pcurrent->next;
        return;
      } else {
        first_protocol = pcurrent->next;
        return;
      }
    }
    plast = pcurrent;
    pcurrent = pcurrent->next;
  }
}

void unique_protocol_name(char *name) {
  URLProtocol *p = first_protocol;
  int i = 0;
  
  //Copy the string "acinx" to the string
  strcpy(name, "acinx");
  
  while (1) {
    //Replace the "x" in the string with a character
    name[4] = (char)(65 + i);
    
    while (1) {   
      //There is no element in the list or we are at the end of the list. In this case the string
      //is unique
      if (p == NULL) {
        return;
      }    
      //We got an element from the list, compare its name to our string. If they are the same,
      //the string isn't unique and we have to create a new one.
      if (strcmp(p->name, name) == 0) {
        p = first_protocol;
        break;
      }
      p = p->next;
    }    
    i++;
  }  
}

//
//--- Memory manager ---
//

ac_malloc_callback mgr_malloc = &malloc;
ac_realloc_callback mgr_realloc =  &realloc;
ac_free_callback mgr_free = &free;

void CALL_CONVT ac_mem_mgr(ac_malloc_callback mc, ac_realloc_callback rc, ac_free_callback fc) {
  mgr_malloc = mc;
  mgr_realloc = rc;
  mgr_free = fc;
}

//
//--- Initialization and Stream opening---
//

void init_info(lp_ac_file_info info) {
  info->title[0] = 0;
  info->author[0] = 0;
  info->copyright[0] = 0;
  info->comment[0] = 0;
  info->album[0] = 0;
  info->year = -1;
  info->track = -1;
  info->genre[0] = 0;
  info->duration = -1;
  info->bitrate = -1;
}

lp_ac_instance CALL_CONVT ac_init(void) {
  //Initialize FFMpeg libraries
  av_register_all();
  
  //Allocate a new instance of the videoplayer data and return it
  lp_ac_data ptmp;  
  ptmp = (lp_ac_data)mgr_malloc(sizeof(ac_data));
  ptmp->instance.opened = 0;
  ptmp->instance.stream_count = 0;
  ptmp->instance.output_format = AC_OUTPUT_BGR24;
  init_info(&(ptmp->instance.info));
  return (lp_ac_instance)ptmp;  
}

void CALL_CONVT ac_free(lp_ac_instance pacInstance) {
  //Close the decoder. If it is already closed, this won't be a problem as ac_close checks the streams state
  ac_close(pacInstance);
  
  if (pacInstance != NULL) {
    mgr_free((lp_ac_data)pacInstance);
  }
}

lp_ac_data last_instance;

//Function called by FFMpeg when opening an ac stream.
static int file_open(URLContext *h, const char *filename, int flags)
{
  h->priv_data = last_instance;
  h->is_streamed = last_instance->seek_proc == NULL;
  
  if (last_instance->open_proc != NULL) {
    last_instance->open_proc(last_instance->sender);
  }
    
  return 0;
}

//Function called by FFMpeg when reading from the stream
static int file_read(URLContext *h, unsigned char *buf, int size)
{
  if (((lp_ac_data)(h->priv_data))->read_proc != NULL) {
    return ((lp_ac_data)(h->priv_data))->read_proc(((lp_ac_data)(h->priv_data))->sender, buf, size);
  }
  
  return -1;
}

//Function called by FFMpeg when seeking the stream

int64_t file_seek(URLContext *h, int64_t pos, int whence)
{
  if ((whence >= 0) && (whence <= 2)) {
    if (((lp_ac_data)(h->priv_data))->seek_proc != NULL) {
      return ((lp_ac_data)(h->priv_data))->seek_proc(((lp_ac_data)(h->priv_data))->sender, pos, whence);
    } 
  }

  return -1;
}

uint64_t global_video_pkt_pts = AV_NOPTS_VALUE;

int ac_get_buffer(struct AVCodecContext *c, AVFrame *pic) {
  int ret = avcodec_default_get_buffer(c, pic);
  uint64_t *pts = av_malloc(sizeof(uint64_t));
  *pts = global_video_pkt_pts;
  pic->opaque = pts;
  return ret;
}

void ac_release_buffer(struct AVCodecContext *c, AVFrame *pic){
  if (pic) av_freep(&pic->opaque);
  avcodec_default_release_buffer(c, pic);
}

//Function called by FFMpeg when the stream should be closed
static int file_close(URLContext *h)
{
  if (((lp_ac_data)(h->priv_data))->close_proc != NULL) {
    return ((lp_ac_data)(h->priv_data))->close_proc(((lp_ac_data)(h->priv_data))->sender);
  }
    
  return 0;
}

int CALL_CONVT ac_open(
  lp_ac_instance pacInstance,
  void *sender, 
  ac_openclose_callback open_proc,
  ac_read_callback read_proc, 
  ac_seek_callback seek_proc,
  ac_openclose_callback close_proc) {
  
  pacInstance->opened = 0;
  
  //Set last instance
  last_instance = (lp_ac_data)pacInstance;
  
  //Store the given parameters in the ac Instance
  ((lp_ac_data)pacInstance)->sender = sender;
  ((lp_ac_data)pacInstance)->open_proc = open_proc;  
  ((lp_ac_data)pacInstance)->read_proc = read_proc;
  ((lp_ac_data)pacInstance)->seek_proc = seek_proc;
  ((lp_ac_data)pacInstance)->close_proc = close_proc;      
 
  //Create a new protocol name
  unique_protocol_name(((lp_ac_data)pacInstance)->protocol_name);  
 
  //Create a new protocol
  ((lp_ac_data)pacInstance)->protocol.name = ((lp_ac_data)pacInstance)->protocol_name;
  ((lp_ac_data)pacInstance)->protocol.url_open = &file_open;
  ((lp_ac_data)pacInstance)->protocol.url_read = &file_read;
  ((lp_ac_data)pacInstance)->protocol.url_write = NULL;
  if (!(seek_proc == NULL)) {
    ((lp_ac_data)pacInstance)->protocol.url_seek = &file_seek;
  } else {
    ((lp_ac_data)pacInstance)->protocol.url_seek = NULL;
  }
  ((lp_ac_data)pacInstance)->protocol.url_close = &file_close;
  
  //Register the generated protocol
  av_register_protocol(&((lp_ac_data)pacInstance)->protocol);
  
  //Generate a unique filename
  char filename[50];
  strcpy(filename, ((lp_ac_data)pacInstance)->protocol_name);
  strcat(filename, "://dummy.file");
  
  if(av_open_input_file(
      &(((lp_ac_data)pacInstance)->pFormatCtx), filename, NULL, 0, NULL) != 0 ) {
    return -1;
  }
 
  //Retrieve stream information
  if(av_find_stream_info(((lp_ac_data)pacInstance)->pFormatCtx)<0) {
    return -1;
  }
  
  //Set some information in the instance variable 
  pacInstance->stream_count = ((lp_ac_data)pacInstance)->pFormatCtx->nb_streams;
  pacInstance->opened = pacInstance->stream_count > 0;  
  
  //Try to obtain even more stream information (duration, author, album etc.)
  if (av_find_stream_info(((lp_ac_data)pacInstance)->pFormatCtx) >= 0) {
    AVFormatContext *ctx = ((lp_ac_data)pacInstance)->pFormatCtx;
    strcpy(pacInstance->info.title, ctx->title);
    strcpy(pacInstance->info.author, ctx->author);
    strcpy(pacInstance->info.copyright, ctx->copyright);
    strcpy(pacInstance->info.comment, ctx->comment);
    strcpy(pacInstance->info.album, ctx->album);
    strcpy(pacInstance->info.genre, ctx->genre);    

    pacInstance->info.year = ctx->year;
    pacInstance->info.track = ctx->track;
    pacInstance->info.bitrate = ctx->bit_rate;     
   
    pacInstance->info.duration = ctx->duration * 1000 / AV_TIME_BASE;    
  }  
}

void CALL_CONVT ac_close(lp_ac_instance pacInstance) {
  if (pacInstance->opened) {
    unregister_protocol(&((lp_ac_data)(pacInstance))->protocol);
    av_close_input_file(((lp_ac_data)(pacInstance))->pFormatCtx);
    pacInstance->opened = 0;    
  }
}
void CALL_CONVT ac_get_stream_info(lp_ac_instance pacInstance, int nb, lp_ac_stream_info info) {
  if (!(pacInstance->opened)) { 
    return;
  }
  
  switch (((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->codec_type) {
    case CODEC_TYPE_VIDEO:
      //Set stream type to "VIDEO"
      info->stream_type = AC_STREAM_TYPE_VIDEO;
      
      //Store more information about the video stream
      info->additional_info.video_info.frame_width = 
        ((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->width;
      info->additional_info.video_info.frame_height = 
        ((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->height;
      info->additional_info.video_info.pixel_aspect = 
        av_q2d(((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->sample_aspect_ratio);
      //Sometime "pixel aspect" may be zero. Correct this.
      if (info->additional_info.video_info.pixel_aspect == 0.0) {
        info->additional_info.video_info.pixel_aspect = 1.0;
      }
      
    info->additional_info.video_info.frames_per_second =
      (double)((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->r_frame_rate.den /
      (double)((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->r_frame_rate.num;
    break;
    case CODEC_TYPE_AUDIO:
      //Set stream type to "AUDIO"
      info->stream_type = AC_STREAM_TYPE_AUDIO;
      
      //Store more information about the video stream
      info->additional_info.audio_info.samples_per_second = 
        ((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->sample_rate;        
      info->additional_info.audio_info.channel_count = 
        ((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->channels;
      
      // Set bit depth      
      switch (((lp_ac_data)pacInstance)->pFormatCtx->streams[nb]->codec->sample_fmt) {
        //8-Bit
        case SAMPLE_FMT_U8:
          info->additional_info.audio_info.bit_depth = 
            8;                
        break;
        
        //16-Bit
        case SAMPLE_FMT_S16:
          info->additional_info.audio_info.bit_depth = 
              16;                            
        break;
        
/*        //24-Bit (removed in the newest ffmpeg version)
        case SAMPLE_FMT_S24:
          info->additional_info.audio_info.bit_depth = 
              24;                                          
        break; */
        
        //32-Bit
        case SAMPLE_FMT_S32: case SAMPLE_FMT_FLT:
          info->additional_info.audio_info.bit_depth = 
              32;                                          
        break;       
         
        //Unknown format, return zero
        default:
          info->additional_info.audio_info.bit_depth = 
            0;        
      }
        
    break;
    default:
      info->stream_type = AC_STREAM_TYPE_UNKNOWN;
  }
}

//
//---Package management---
//

lp_ac_package CALL_CONVT ac_read_package(lp_ac_instance pacInstance) {
  //Try to read package
  AVPacket Package;  
  if (av_read_frame(((lp_ac_data)(pacInstance))->pFormatCtx, &Package) >= 0) {
    //Reserve memory
    lp_ac_package_data pTmp = (lp_ac_package_data)(mgr_malloc(sizeof(ac_package_data)));
    
    //Set package data
    pTmp->package.data = Package.data;
    pTmp->package.size = Package.size;
    pTmp->package.stream_index = Package.stream_index;
    pTmp->ffpackage = Package;
    if (Package.dts != AV_NOPTS_VALUE) {
      pTmp->pts = Package.dts;
    }
    
    return (lp_ac_package)(pTmp);
  } else {
    return NULL;
  }
}

//Frees the currently loaded package
void CALL_CONVT ac_free_package(lp_ac_package pPackage) {
  //Free the packet
  if (pPackage != NULL) {    
    av_free_packet(&((lp_ac_package_data)pPackage)->ffpackage);
    mgr_free((lp_ac_package_data)pPackage);
  }
}

//
//--- Decoder management ---
//

enum PixelFormat convert_pix_format(ac_output_format fmt) {
  switch (fmt) {
    case AC_OUTPUT_RGB24: return PIX_FMT_RGB24;
    case AC_OUTPUT_BGR24: return PIX_FMT_BGR24;
    case AC_OUTPUT_RGBA32: return PIX_FMT_RGB32;
    case AC_OUTPUT_BGRA32: return PIX_FMT_BGR32;        
  }
  return PIX_FMT_RGB24;
}

//Init a video decoder
void* ac_create_video_decoder(lp_ac_instance pacInstance, lp_ac_stream_info info, int nb) {
  //Allocate memory for a new decoder instance
  lp_ac_video_decoder pDecoder;  
  pDecoder = (lp_ac_video_decoder)(mgr_malloc(sizeof(ac_video_decoder)));
  
  //Set a few properties
  pDecoder->decoder.pacInstance = pacInstance;
  pDecoder->decoder.type = AC_DECODER_TYPE_VIDEO;
  pDecoder->decoder.stream_index = nb;
  pDecoder->pCodecCtx = ((lp_ac_data)(pacInstance))->pFormatCtx->streams[nb]->codec;
  pDecoder->pCodecCtx->get_buffer = ac_get_buffer;
  pDecoder->pCodecCtx->release_buffer = ac_release_buffer; 
  pDecoder->decoder.stream_info = *info;  
  
  //Find correspondenting codec
  if (!(pDecoder->pCodec = avcodec_find_decoder(pDecoder->pCodecCtx->codec_id))) {
    return NULL; //Codec could not have been found
  }
  
  //Open codec
  if (avcodec_open(pDecoder->pCodecCtx, pDecoder->pCodec) < 0) {
    return NULL; //Codec could not have been opened
  }
  
  //Reserve frame variables
  pDecoder->pFrame = avcodec_alloc_frame();
  pDecoder->pFrameRGB = avcodec_alloc_frame();
  
  pDecoder->pSwsCtx = NULL;
  
  //Reserve buffer memory
  pDecoder->decoder.buffer_size = avpicture_get_size(convert_pix_format(pacInstance->output_format), 
    pDecoder->pCodecCtx->width, pDecoder->pCodecCtx->height);
  pDecoder->decoder.pBuffer = (uint8_t*)mgr_malloc(pDecoder->decoder.buffer_size);

  //Link decoder to buffer
  avpicture_fill(
    (AVPicture*)(pDecoder->pFrameRGB), 
    pDecoder->decoder.pBuffer, convert_pix_format(pacInstance->output_format),
    pDecoder->pCodecCtx->width, pDecoder->pCodecCtx->height);
    
  return (void*)pDecoder;
}

//Init a audio decoder
void* ac_create_audio_decoder(lp_ac_instance pacInstance, lp_ac_stream_info info, int nb) {
  //Allocate memory for a new decoder instance
  lp_ac_audio_decoder pDecoder;
  pDecoder = (lp_ac_audio_decoder)(mgr_malloc(sizeof(ac_audio_decoder)));
  
  //Set a few properties
  pDecoder->decoder.pacInstance = pacInstance;
  pDecoder->decoder.type = AC_DECODER_TYPE_AUDIO;
  pDecoder->decoder.stream_index = nb;
  pDecoder->decoder.stream_info = *info;
  
  //Temporary store codec context pointer
  AVCodecContext *pCodecCtx = ((lp_ac_data)(pacInstance))->pFormatCtx->streams[nb]->codec;
  pDecoder->pCodecCtx = pCodecCtx;  
  
  //Find correspondenting codec
  if (!(pDecoder->pCodec = avcodec_find_decoder(pCodecCtx->codec_id))) {
    return NULL;
  }
  
  //Open codec
  if (avcodec_open(pCodecCtx, pDecoder->pCodec) < 0) {
    return NULL;
  }

  //Reserve a buffer
  pDecoder->max_buffer_size = AUDIO_BUFFER_BASE_SIZE;
  pDecoder->decoder.pBuffer = (uint8_t*)(mgr_malloc(pDecoder->max_buffer_size));
  pDecoder->decoder.buffer_size = 0;
  
  return (void*)pDecoder;
}

lp_ac_decoder CALL_CONVT ac_create_decoder(lp_ac_instance pacInstance, int nb) {
  //Get information about the chosen data stream and create an decoder that can
  //handle this kind of stream.
  ac_stream_info info;
  ac_get_stream_info(pacInstance, nb, &info);
  
  lp_ac_decoder result;
  
  if (info.stream_type == AC_STREAM_TYPE_VIDEO) {
    result = ac_create_video_decoder(pacInstance, &info, nb);
  } 
  else if (info.stream_type == AC_STREAM_TYPE_AUDIO) {
    result = ac_create_audio_decoder(pacInstance, &info, nb);  
  }
  
  ((lp_ac_decoder_data)result)->last_timecode = 0;
  ((lp_ac_decoder_data)result)->sought = 1;
  result->video_clock = 0;
  
  return result;
}

double ac_sync_video(lp_ac_package pPackage, lp_ac_decoder pDec, AVFrame *src_frame, double pts){
  double frame_delay;
  
  if(pts != 0){
    pDec->video_clock = pts;
  } else {
    pts = pDec->video_clock;
  }
  
  frame_delay = av_q2d(((lp_ac_data)pDec->pacInstance)->pFormatCtx->streams[pPackage->stream_index]->time_base);
  frame_delay += src_frame->repeat_pict * (frame_delay * 0.5);
  pDec->video_clock += frame_delay;
  return pts;
}

int ac_decode_video_package(lp_ac_package pPackage, lp_ac_video_decoder pDecoder, lp_ac_decoder pDec) {
  int finished;
  double pts;
	
  avcodec_decode_video2(
    pDecoder->pCodecCtx, pDecoder->pFrame, &finished,
    &((lp_ac_package_data)pPackage)->ffpackage);

  
  
  
  if (finished) {
	pts=0;
    global_video_pkt_pts = ((lp_ac_package_data)pPackage)->ffpackage.pts;
	
    if(((lp_ac_package_data)pPackage)->ffpackage.dts == AV_NOPTS_VALUE &&
	  *(uint64_t*)pDecoder->pFrame->opaque != AV_NOPTS_VALUE ){
	  pts = *(uint64_t*)pDecoder->pFrame->opaque;
    } else if(((lp_ac_package_data)pPackage)->ffpackage.dts != AV_NOPTS_VALUE){
      pts = ((lp_ac_package_data)pPackage)->ffpackage.dts;
    } else {
	  pts = 0;
    }
	
	if(((lp_ac_data)pDec->pacInstance)->pFormatCtx->streams[pPackage->stream_index]->start_time != AV_NOPTS_VALUE){
      pts -= ((lp_ac_data)pDec->pacInstance)->pFormatCtx->streams[pPackage->stream_index]->start_time;
	}

    pts *= av_q2d(((lp_ac_data)pDec->pacInstance)->pFormatCtx->streams[pPackage->stream_index]->time_base);
	
    pts = ac_sync_video(pPackage, pDec, pDecoder->pFrame, pts);
	pDec->timecode = pts;
/*    img_convert(
      (AVPicture*)(pDecoder->pFrameRGB), convert_pix_format(pDecoder->decoder.pacInstance->output_format), 
      (AVPicture*)(pDecoder->pFrame), pDecoder->pCodecCtx->pix_fmt, 
			pDecoder->pCodecCtx->width, pDecoder->pCodecCtx->height);*/
      
    pDecoder->pSwsCtx = sws_getCachedContext(pDecoder->pSwsCtx,
      pDecoder->pCodecCtx->width, pDecoder->pCodecCtx->height, pDecoder->pCodecCtx->pix_fmt,
      pDecoder->pCodecCtx->width, pDecoder->pCodecCtx->height, convert_pix_format(pDecoder->decoder.pacInstance->output_format),
      SWS_BICUBIC, NULL, NULL, NULL);
                                  
    sws_scale(
      pDecoder->pSwsCtx,
      pDecoder->pFrame->data,
      pDecoder->pFrame->linesize,
      0, //?
      pDecoder->pCodecCtx->height, 
      pDecoder->pFrameRGB->data, 
      pDecoder->pFrameRGB->linesize);
    return 1;
  }
  return 0;
}

int ac_decode_audio_package(lp_ac_package pPackage, lp_ac_audio_decoder pDecoder) {
  int len1;
  int dest_buffer_size = pDecoder->max_buffer_size;
  int dest_buffer_pos = 0;
  int size;
  uint8_t *src_buffer = pPackage->data;
  int src_buffer_size = pPackage->size;
  
  pDecoder->decoder.buffer_size = 0;
  
  while (src_buffer_size > 0) {
    //Set the size of bytes that can be written to the current size of the destination buffer
    size = dest_buffer_size;
    
    //Decode a piece of the audio buffer. len1 contains the count of bytes read from the soure buffer.
    /*
	len1 = avcodec_decode_audio2(
      pDecoder->pCodecCtx, (uint16_t*)(pDecoder->decoder.pBuffer + dest_buffer_pos), &size, 
      src_buffer, src_buffer_size);*/
    
	len1 = avcodec_decode_audio3(
	  pDecoder->pCodecCtx, (uint16_t*)(pDecoder->decoder.pBuffer + dest_buffer_pos), &size,
      &((lp_ac_package_data)pPackage)->ffpackage);
		
    src_buffer_size = pPackage->size - len1;
    src_buffer      = pPackage->data + len1;
    
    dest_buffer_size -= size;
    dest_buffer_pos += size;
    pDecoder->decoder.buffer_size = dest_buffer_pos;
    
    if (dest_buffer_size <= AUDIO_BUFFER_BASE_SIZE) {
      pDecoder->decoder.pBuffer = mgr_realloc(pDecoder->decoder.pBuffer, pDecoder->max_buffer_size * 2);
      dest_buffer_size += pDecoder->max_buffer_size;
      pDecoder->max_buffer_size *= 2;
    }
    
    if (len1 <= 0) {    
      return 1;
    }
  }
  
  return 1;
}

int CALL_CONVT ac_decode_package(lp_ac_package pPackage, lp_ac_decoder pDecoder) {
  if (pDecoder->type == AC_DECODER_TYPE_AUDIO) {
      
    double timebase = 
      av_q2d(((lp_ac_data)pDecoder->pacInstance)->pFormatCtx->streams[pPackage->stream_index]->time_base);
  
    //Create a valid timecode
    if (((lp_ac_package_data)pPackage)->pts > 0) {
      lp_ac_decoder_data dec_dat = (lp_ac_decoder_data)pDecoder;    

      dec_dat->last_timecode = pDecoder->timecode;
      pDecoder->timecode = ((lp_ac_package_data)pPackage)->pts * timebase;
    
      double delta = pDecoder->timecode - dec_dat->last_timecode;
      double max_delta, min_delta;
    
      if (dec_dat->sought > 0) {
        max_delta = 120.0;
        min_delta = -120.0;
        --dec_dat->sought;
      } else {
        max_delta = 4.0;
        min_delta = 0.0;
      }
      
      if ((delta < min_delta) || (delta > max_delta)) {
        pDecoder->timecode = dec_dat->last_timecode;
        if (dec_dat->sought > 0) {
          ++dec_dat->sought;
        }
      }
    }
    return ac_decode_audio_package(pPackage, (lp_ac_audio_decoder)pDecoder);
  } else if (pDecoder->type == AC_DECODER_TYPE_VIDEO) {
    return ac_decode_video_package(pPackage, (lp_ac_video_decoder)pDecoder, pDecoder);
  } 
  return 0;
}

//Seek function
int CALL_CONVT ac_seek(lp_ac_decoder pDecoder, int dir, int64_t target_pos) {
  AVRational timebase = 
    ((lp_ac_data)pDecoder->pacInstance)->pFormatCtx->streams[pDecoder->stream_index]->time_base;
  
  int flags = dir < 0 ? AVSEEK_FLAG_BACKWARD : 0;    
  
  int64_t pos = av_rescale(target_pos, AV_TIME_BASE, 1000);
  
  ((lp_ac_decoder_data)pDecoder)->sought = 100;
  pDecoder->timecode = target_pos / 1000;
  //pDecoder->timecode = 0;
  if (av_seek_frame(((lp_ac_data)pDecoder->pacInstance)->pFormatCtx, pDecoder->stream_index, 
      av_rescale_q(pos, AV_TIME_BASE_Q, timebase), flags) >= 0) {
	avcodec_flush_buffers(((lp_ac_video_decoder)pDecoder)->pCodecCtx);
    return 1;
  }
  
  return 0;  
}

//Free video decoder
void ac_free_video_decoder(lp_ac_video_decoder pDecoder) {
//  av_free(pDecoder->decoder.pBuffer);  
  av_free(pDecoder->pFrame);
  av_free(pDecoder->pFrameRGB);    
  if (pDecoder->pSwsCtx != NULL) {
    sws_freeContext(pDecoder->pSwsCtx);
  }
  avcodec_close(pDecoder->pCodecCtx);
  
  
  //Free reserved memory for the buffer
  mgr_free(pDecoder->decoder.pBuffer);  
  
  //Free reserved memory for decoder record
  mgr_free(pDecoder);
}

//Free video decoder
void ac_free_audio_decoder(lp_ac_audio_decoder pDecoder) {
//  av_free(pDecoder->decoder.pBuffer);
  avcodec_close(pDecoder->pCodecCtx);
  
  //Free reserved memory for the buffer
  mgr_free(pDecoder->decoder.pBuffer);

  //Free reserved memory for decoder record
  mgr_free(pDecoder);
}

void CALL_CONVT ac_free_decoder(lp_ac_decoder pDecoder) {
  if (pDecoder->type == AC_DECODER_TYPE_VIDEO) {
    ac_free_video_decoder((lp_ac_video_decoder)pDecoder);
  }
  else if (pDecoder->type == AC_DECODER_TYPE_AUDIO) {
    ac_free_audio_decoder((lp_ac_audio_decoder)pDecoder);  
  }  
}
