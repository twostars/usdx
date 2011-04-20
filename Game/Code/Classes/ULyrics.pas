unit ULyrics;

interface
uses SysUtils, gl, glext, UMusic, UIni;

type
  TWord = record
      X:      real;
      Y:      real;
      Size:   real;
      Width:  real;
      Text:   string;
      Color:  integer; //0=normal, 1=golden
      ColR:   real;
      ColG:   real;
      ColB:   real;
      Scale:  real;
      Done:   real;
      FontStyle:  integer;
      Italic:     boolean;
      Selected:   boolean;
  end;

  TLyric = class
    private
      AlignI:         integer;
      XR:             real;
      YR:             real;
      SizeR:          real;
      SelectedI:      integer;
      ScaleR:         real;
      StyleI:         integer;          // 0 - one selection, 1 - long selection, 2 - one selection with fade to normal text, 3 - long selection with fade with color from left
      FontStyleI:     integer;          // font number
      Word:           array of TWord;
      Alpha:          real;
      procedure SetX(Value: real);
      procedure SetY(Value: real);
      function GetClientX: real;
      procedure SetAlign(Value: integer);
      function GetSize: real;
      procedure SetSize(Value: real);
      procedure SetSelected(Value: integer);
      procedure SetDone(Value: real);
      procedure SetScale(Value: real);
      procedure SetStyle(Value: integer);
      procedure SetFStyle(Value: integer);
      procedure Refresh;
      procedure DrawNormal(W: integer);
      procedure DrawPlain(W: integer);
      procedure DrawScaled(W: integer);
      procedure DrawSlide(W: integer);
    public
      ColR:     array [0..1] of real;
      ColG:     array [0..1] of real;
      ColB:     array [0..1] of real;
      ColSR:    array [0..1] of real;
      ColSG:    array [0..1] of real;
      ColSB:    array [0..1] of real;

      Italic:   boolean;
      Text:     string;   // LCD

    published
      property X: real write SetX;
      property Y: real write SetY;
      property ClientX: real read GetClientX;
      property Align: integer write SetAlign;
      property Size: real read GetSize write SetSize;
      property Selected: integer read SelectedI write SetSelected;
      property Done: real write SetDone;
      property Scale: real write SetScale;
      property Style: integer write SetStyle;
      property FontStyle: integer write SetFStyle;
      procedure AddWord(Text: string; Golden: boolean);
      procedure AddCzesc(CP, NrCzesci: integer); //AddLine?
      procedure ChangeCurText(Text: String);

      function SelectedLetter: integer;  // LCD
      function SelectedLength: integer;  // LCD

      procedure Clear;
      procedure Draw();
      procedure SetAlpha(alpha: real);
      function GetAlpha: real;

  end;

{var
  Lyric:    TLyric;}

implementation
uses TextGL, UGraphic, UDrawTexture;

procedure TLyric.SetAlpha(alpha: real);
begin
  Self.Alpha := alpha;

  if (Self.Alpha>1) then
    Self.Alpha := 1;

  if (Self.Alpha<0) then
    Self.Alpha := 0;
end;

function TLyric.GetAlpha: real;
begin
  Result := Alpha;
end;

procedure TLyric.SetX(Value: real);
begin
  XR := Value;
end;

procedure TLyric.SetY(Value: real);
begin
  YR := Value;
end;

function TLyric.GetClientX: real;
begin
  Result := Word[0].X;
end;

procedure TLyric.SetAlign(Value: integer);
begin
  AlignI := Value;
//  if AlignInt = 0 then beep;
end;

function TLyric.GetSize: real;
begin
  Result := SizeR;
end;

procedure TLyric.SetSize(Value: real);
begin
  SizeR := Value;
end;

procedure TLyric.SetSelected(Value: integer);
var
  W:  integer;
begin
  if (StyleI = 0) or (StyleI = 2) or (StyleI = 4) then
  begin
    if (SelectedI > -1) and (SelectedI <= High(Word)) then
    begin
      Word[SelectedI].Selected := false;
      Word[SelectedI].ColR := ColR[Word[SelectedI].Color];
      Word[SelectedI].ColG := ColG[Word[SelectedI].Color];
      Word[SelectedI].ColB := ColB[Word[SelectedI].Color];
      Word[SelectedI].Done := 0;
    end;

    SelectedI := Value;
    if (Value > -1) and (Value <= High(Word)) then
    begin
      Word[Value].Selected := true;
      Word[Value].ColR := ColSR[Word[Value].Color];
      Word[Value].ColG := ColSG[Word[Value].Color];
      Word[Value].ColB := ColSB[Word[Value].Color];
      Word[Value].Scale := ScaleR;
    end;
  end;

  if (StyleI = 1) or (StyleI = 3) then
  begin
    if (SelectedI > -1) and (SelectedI <= High(Word)) then
    begin
      for W := SelectedI to High(Word) do
      begin
        Word[W].Selected := false;
        Word[W].ColR := ColR[Word[W].Color];
        Word[W].ColG := ColG[Word[W].Color];
        Word[W].ColB := ColB[Word[W].Color];
        Word[W].Done := 0;
      end;
    end;

    SelectedI := Value;
    if (Value > -1) and (Value <= High(Word)) then
    begin
      for W := 0 to Value do
      begin
        Word[W].Selected := true;
        Word[W].ColR := ColSR[Word[W].Color];
        Word[W].ColG := ColSG[Word[W].Color];
        Word[W].ColB := ColSB[Word[W].Color];
        Word[W].Scale := ScaleR;
        Word[W].Done := 1;
      end;
    end;
  end;

  Refresh;
end;

procedure TLyric.SetDone(Value: real);
var
  W:    integer;
begin
  W := SelectedI;
  if W > -1 then
    Word[W].Done := Value;
end;

procedure TLyric.SetScale(Value: real);
begin
  ScaleR := Value;
end;

procedure TLyric.SetStyle(Value: integer);
begin
  StyleI := Value;
end;

procedure TLyric.SetFStyle(Value: integer);
begin
  FontStyleI := Value;
end;

procedure TLyric.AddWord(Text: string; Golden: boolean);
var
  WordNum:    integer;
begin
  WordNum := Length(Word);
  SetLength(Word, WordNum + 1);
  if WordNum = 0 then begin
    Word[WordNum].X := XR;
  end else begin
    Word[WordNum].X := Word[WordNum - 1].X + Word[WordNum - 1].Width;
  end;

  Word[WordNum].Y := YR;
  Word[WordNum].Size := SizeR;
  Word[WordNum].FontStyle := FontStyleI; // new
  SetFontStyle(FontStyleI);
  SetFontSize(SizeR);
  Word[WordNum].Width := glTextWidth(pchar(Text));
  Word[WordNum].Text := Text;

  if not Golden or (Ini.LyricsGolden=0) then
    Word[WordNum].Color := 0
  else
    Word[WordNum].Color := 1;

  Word[WordNum].ColR := ColR[Word[WordNum].Color];
  Word[WordNum].ColG := ColG[Word[WordNum].Color];
  Word[WordNum].ColB := ColB[Word[WordNum].Color];
  
  Word[WordNum].Scale := 1;
  Word[WordNum].Done := 0;
  Word[WordNum].Italic := Italic;

  Refresh;
end;

procedure TLyric.AddCzesc(CP, NrCzesci: integer);
var
  N:    integer;
begin
  Clear;
  if (Length(Czesci[CP].Czesc[NrCzesci].Nuta)>0) then
  begin
    for N := 0 to Czesci[CP].Czesc[NrCzesci].HighNut do
    begin
      Italic := Czesci[CP].Czesc[NrCzesci].Nuta[N].FreeStyle;
      AddWord(Czesci[CP].Czesc[NrCzesci].Nuta[N].Tekst, Czesci[CP].Czesc[NrCzesci].Nuta[N].Wartosc=2);
      Text := Text + Czesci[CP].Czesc[NrCzesci].Nuta[N].Tekst;
    end;
  end else
  begin
    Italic := false;
    AddWord(' ', false);
    Text := ' ';
  end;
  Selected := -1;
end;

procedure TLyric.Clear;
begin
  SetLength(Word, 0);
  Text := '';
  SelectedI := -1;
  Alpha := 1;
end;

procedure TLyric.Refresh;
var
  W:          integer;
  TotWidth:   real;
begin
  if AlignI = 1 then begin
    TotWidth := 0;
    for W := 0 to High(Word) do
      TotWidth := TotWidth + Word[W].Width;

    Word[0].X := XR - TotWidth / 2;
    for W := 1 to High(Word) do
      Word[W].X := Word[W - 1].X + Word[W - 1].Width;
  end;
end;

procedure TLyric.Draw();
var
  W:    integer;
begin
  glEnable(GL_BLEND);
  case StyleI of
    0:
      begin
        for W := 0 to High(Word) do
          DrawNormal(W);
      end;
    1:
      begin
        for W := 0 to High(Word) do
          DrawPlain(W);
      end;
    2: // zoom
      begin
        for W := 0 to High(Word) do
          if not Word[W].Selected then
            DrawNormal(W);

        for W := 0 to High(Word) do
          if Word[W].Selected then
            DrawScaled(W);
      end;
    3: // slide
      begin
        for W := 0 to High(Word) do
        begin
          if not Word[W].Selected then
            DrawNormal(W)
          else
            DrawSlide(W);
        end;
      end;
    4: // ball
      begin
        for W := 0 to High(Word) do
          DrawNormal(W);

        for W := 0 to High(Word) do
          if Word[W].Selected then
          begin
            Tex_Ball.X := (Word[W].X - 10) + Word[W].Done * Word[W].Width;
            Tex_Ball.Y := YR -12 - 10*sin(Word[W].Done * pi);
            Tex_Ball.W := 20;
            Tex_Ball.H := 20;
            DrawTexture(Tex_Ball, Alpha);
          end;
      end;
  end; // case
  glDisable(GL_BLEND);
end;

procedure TLyric.DrawNormal(W: integer);
begin
  SetFontStyle(Word[W].FontStyle);
  SetFontPos(Word[W].X+ 10*ScreenX, Word[W].Y);
  SetFontSize(Word[W].Size);
  SetFontItalic(Word[W].Italic);
  glColor4f(Word[W].ColR, Word[W].ColG, Word[W].ColB, Alpha);
  glPrint(pchar(Word[W].Text));
end;

procedure TLyric.DrawPlain(W: integer);
var
  D:    real;
begin
  D := Word[W].Done; // przyrost

  SetFontStyle(Word[W].FontStyle);
  SetFontPos(Word[W].X, Word[W].Y);
  SetFontSize(Word[W].Size);
  SetFontItalic(Word[W].Italic);
  if D = 0 then
    glColor4f(Word[W].ColR, Word[W].ColG, Word[W].ColB, Alpha)
  else
    glColor4f(ColSR[Word[W].Color], ColSG[Word[W].Color], ColSB[Word[W].Color], Alpha);

  glPrint(pchar(Word[W].Text));
end;

procedure TLyric.DrawScaled(W: integer);
var
  D:    real;
begin
  // previous plus dynamic scaling effect
  D := 1-Word[W].Done; // przyrost
  SetFontStyle(Word[W].FontStyle);
  SetFontPos(Word[W].X - D * Word[W].Width * (Word[W].Scale - 1) / 2 + (D+1)*10*ScreenX, Word[W].Y - D * 1.5 * Word[W].Size *(Word[W].Scale - 1));
  SetFontSize(Word[W].Size + D * (Word[W].Size * Word[W].Scale - Word[W].Size));
  SetFontItalic(Word[W].Italic);
  glColor4f(Word[W].ColR, Word[W].ColG, Word[W].ColB, Alpha);
  glPrint(pchar(Word[W].Text))
end;

procedure TLyric.DrawSlide(W: integer);
var
  D:    real;
begin
  D := Word[W].Done; // przyrost
  SetFontStyle(Word[W].FontStyle);
  SetFontPos(Word[W].X, Word[W].Y);
  SetFontSize(Word[W].Size);
  SetFontItalic(Word[W].Italic);
  glColor4f(Word[W].ColR, Word[W].ColG, Word[W].ColB, Alpha);
  glPrintDone(pchar(Word[W].Text), D, ColR[Word[W].Color], ColG[Word[W].Color], ColB[Word[W].Color], Alpha);
end;

function TLyric.SelectedLetter;  // LCD
var
  W:    integer;
begin
  Result := 1;

  for W := 0 to SelectedI-1 do
    Result := Result + Length(Word[W].Text);
end;

function TLyric.SelectedLength: integer;  // LCD
begin
  Result := Length(Word[SelectedI].Text);
end;

procedure TLyric.ChangeCurText(Text: String);
begin
  Word[Selected].Text := Text;
end;

end.
