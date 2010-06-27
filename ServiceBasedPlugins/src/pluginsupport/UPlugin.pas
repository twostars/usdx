{* UltraStar Deluxe - Karaoke Game
 *
 * UltraStar Deluxe is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/base/UMain.pas $
 * $Id: UMain.pas 1629 2009-03-07 22:30:04Z k-m_schindler $
 *}

unit UPlugin;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses UPluginDefines;

// a basic implementation of IPlugin
type
  TPlugin = class(TInterfacedObject, IUS_Plugin)
    protected
      Status: TUS_PluginStatus;
      Handle: TUS_Handle;
      UniqueID: TUS_Handle;
      Filename: WideString;
      ErrorReason: WideString;

      Info: TUS_PluginInfo;

      procedure OnChangeStatus(Status: TUS_PluginStatus); virtual;
    public
      constructor Create(Handle: TUS_Handle; Filename: WideString); virtual;

      function GetLoader: LongInt; virtual;

      function GetStatus: TUS_PluginStatus; virtual;
      procedure SetStatus(Status: TUS_PluginStatus); virtual;

      function GetInfo: TUS_PluginInfo; virtual;
      function Identify(Info: TUS_PluginInfo): boolean; virtual;

      function GetHandle: TUS_Handle; virtual;
      function GetUniqueID: TUS_Handle; virtual;
      function GetFilename: WideString; virtual;

      procedure Init; virtual; {$IFDEF HasInline}inline;{$ENDIF}
      procedure DeInit; virtual; {$IFDEF HasInline}inline;{$ENDIF}

      procedure SetError(Reason: WideString); virtual;
      function GetErrorReason: WideString; virtual;
  end;

implementation
uses UPluginManager, ULog;

constructor TPlugin.Create(Handle: TUS_Handle; Filename: WideString);
begin
  inherited Create;
  
  Self.Handle   := Handle;
  Self.Filename := Filename;
  Self.Status   := psNone;

  Self.UniqueID := CalculateUSHash(Filename); //< this should be done another way ;) just for testing purposes

  Self.Info.Version := US_VERSION_UNDEFINED;
end;

function TPlugin.GetLoader: LongInt;
begin
  Result := US_LOADER_UNDEFINED;
end;

function TPlugin.GetStatus: TUS_PluginStatus;
begin
  Result := Status;
end;

procedure TPlugin.SetStatus(Status: TUS_PluginStatus);
begin
  // OnChangeStatus has to change the status attribut 
  OnChangeStatus(Status);
end;

function TPlugin.GetInfo: TUS_PluginInfo;
begin
  Result := Info;
end;

function TPlugin.Identify(Info: TUS_PluginInfo): boolean;
begin
  Result := false;
  If (Self.Info.Version = US_VERSION_UNDEFINED) then
  begin //first identify

    If (Length(Info.Name) > 0) AND (Length(Info.Author) > 0) AND (Length(Info.PluginDesc) > 0) AND (Info.Version <> US_VERSION_UNDEFINED) then
    begin
      Self.Info := Info;
      Result := true;
    end
    else
      SetError('Identify called with incomplete info struct');
  end
  else
    Log.LogWarn('Identify is called twice', Self.Info.Name);
end;

function TPlugin.GetHandle: TUS_Handle;
begin
  Result := Handle;
end;

function TPlugin.GetUniqueID: TUS_Handle;
begin
  Result := UniqueID;
end;

function TPlugin.GetFilename: WideString;
begin
  Result := Filename;
end;

procedure TPlugin.Init; {$IFDEF HasInline}inline;{$ENDIF}
begin
  if (Status = psWaitingInit) then
    SetStatus(psInited);
end;

procedure TPlugin.DeInit; {$IFDEF HasInline}inline;{$ENDIF}
begin
  if (Status = psInited) then
    SetStatus(psDeInited);
end;

procedure TPlugin.SetError(Reason: WideString);
begin
  ErrorReason := Reason;
  SetStatus(psError);
  PluginManager.ReportError(Handle);
  Log.LogError(Filename + ': ' + Reason);
end;

function TPlugin.GetErrorReason: WideString;
begin
  Result := ErrorReason;
end;

procedure TPlugin.OnChangeStatus(Status: TUS_PluginStatus);
begin
  //do nothing here
  //should be overwritten by the child classes
end;

end.