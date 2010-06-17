unit UScreenPartyPlayer;

Interface

uses
  UMenu, SDL, UDisplay, UMusic, UFiles, SysUtils, UThemes, Math;

type

  TArrayElement = String;
  TArray = array of TArrayElement;

  TScreenPartyPlayer = class(TMenu)
    public
      Team1Name: Cardinal;
      Player1Name: Cardinal;
      Player2Name: Cardinal;
      Player3Name: Cardinal;
      Player4Name: Cardinal;

      Team2Name: Cardinal;
      Player5Name: Cardinal;
      Player6Name: Cardinal;
      Player7Name: Cardinal;
      Player8Name: Cardinal;

      Team3Name: Cardinal;
      Player9Name: Cardinal;
      Player10Name: Cardinal;
      Player11Name: Cardinal;
      Player12Name: Cardinal;

      constructor Create; override;
      function ParseInput(PressedKey: Cardinal; ScanCode: byte; PressedDown: Boolean): Boolean; override;
      procedure onShow; override;
      procedure SetAnimationProgress(Progress: real); override;
      procedure ShuffleNames(var aArray: TArray);
  end;



const
  ID='ID_016';   //for help system

implementation

uses UGraphic, UMain, UIni, UTexture, UParty, UHelp, ULog;

function TScreenPartyPlayer.ParseInput(PressedKey: Cardinal; ScanCode: byte; PressedDown: Boolean): Boolean;
var
  I, J, countPlayer:    integer;
  SDL_ModState:  Word;
  randomNames:   TArray;   //new for randomize names
  procedure IntNext;
  begin
    repeat
      InteractNext;
    until Button[Interaction].Visible;
  end;
  procedure IntPrev;
  begin
    repeat
      InteractPrev;
    until Button[Interaction].Visible;
  end;

begin
  Result := true;

  if not (ScanCode in [0..31, 127..159]) then
  begin
    Button[Interaction].Text[0].Text := Button[Interaction].Text[0].Text + chr(ScanCode);
    Exit;
  end;

  If (PressedDown) Then
  begin // Key Down
    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
    + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);
    
    if (SDL_ModState = KMOD_LCTRL) then
    begin
      case PressedKey of
        //-------------------------------------randomize player names---------- mod by merc
        // TODO: rewrite! (some for loops?)
       SDLK_KP_MULTIPLY, SDLK_R:
         begin

           countPlayer := 0;
           SetLength(randomNames, 12);

           If (PartySession.Teams.NumTeams>=1) then
           begin
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=1) then
             begin
               randomNames[countPlayer] := Button[1].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=2) then
             begin
               randomNames[countPlayer] := Button[2].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=3) then
             begin
               randomNames[countPlayer] := Button[3].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=4) then
             begin
               randomNames[countPlayer] := Button[4].Text[0].Text;
               inc(countPlayer);
             end;
           end;

           If (PartySession.Teams.NumTeams>=2) then
           begin
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=1) then
             begin
               randomNames[countPlayer] := Button[6].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=2) then
             begin
               randomNames[countPlayer] := Button[7].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=3) then
             begin
               randomNames[countPlayer] := Button[8].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=4) then
             begin
               randomNames[countPlayer] := Button[9].Text[0].Text;
               inc(countPlayer);
             end;
           end;

           If (PartySession.Teams.NumTeams>=3) then
           begin
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=1) then
             begin
               randomNames[countPlayer] := Button[11].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=2) then
             begin
               randomNames[countPlayer] := Button[12].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=3) then
             begin
               randomNames[countPlayer] := Button[13].Text[0].Text;
               inc(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=4) then
             begin
               randomNames[countPlayer] := Button[14].Text[0].Text;
               inc(countPlayer);
             end;
           end;

           SetLength(randomNames, countPlayer);
           ShuffleNames(randomNames);


           //Write Names back to Players
           dec(countPlayer);
           If (PartySession.Teams.NumTeams>=1) then
           begin
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=1) then
             begin
               Button[1].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=2) then
             begin
               Button[2].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=3) then
             begin
               Button[3].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[0].NumPlayers >=4) then
             begin
               Button[4].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
           end;

           If (PartySession.Teams.NumTeams>=2) then
           begin
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=1) then
             begin
               Button[6].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=2) then
             begin
               Button[7].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=3) then
             begin
               Button[8].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[1].NumPlayers >=4) then
             begin
               Button[9].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
           end;

           If (PartySession.Teams.NumTeams>=3) then
           begin
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=1) then
             begin
               Button[11].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=2) then
             begin
               Button[12].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=3) then
             begin
               Button[13].Text[0].Text := randomNames[countPlayer];
               dec(countPlayer);
             end;
             If (PartySession.Teams.Teaminfo[2].NumPlayers >=4) then
             begin
               Button[14].Text[0].Text := randomNames[countPlayer];
               //dec(countPlayer);  useless...
             end;
           end;
         end;
      end;

    end else
    begin

    case PressedKey of
      SDLK_TAB:
        begin
          ScreenPopupHelp.ShowPopup();
        end;

      // Templates for Names Mod
      SDLK_F1:
       if (SDL_ModState = KMOD_LALT) then
         begin
          Ini.NameTemplate[0] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[0];
         end;
      SDLK_F2:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[1] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[1];
         end;
      SDLK_F3:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[2] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[2];
         end;
      SDLK_F4:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[3] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[3];
         end;
      SDLK_F5:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[4] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[4];
         end;
      SDLK_F6:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[5] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[5];
         end;
      SDLK_F7:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[6] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[6];
         end;
      SDLK_F8:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[7] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[7];
         end;
      SDLK_F9:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[8] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[8];
         end;
      SDLK_F10:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[9] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[9];
         end;
      SDLK_F11:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[10] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[10];
         end;
      SDLK_F12:
       if (SDL_ModState = KMOD_LALT) then
         begin
           Ini.NameTemplate[11] := Button[Interaction].Text[0].Text;
         end
         else
         begin
           Button[Interaction].Text[0].Text := Ini.NameTemplate[11];
         end;

      SDLK_BACKSPACE:
        begin
          Button[Interaction].Text[0].DeleteLastL;
        end;

      SDLK_ESCAPE :
        begin
          Ini.SaveNames;
          Music.PlayBack;
          FadeTo(@ScreenPartyOptions);
        end;

      SDLK_RETURN:
        begin
          Ini.SaveNames;
          //Save PlayerNames
          for I := 0 to PartySession.Teams.NumTeams-1 do
          begin
            PartySession.Teams.Teaminfo[I].Name := PChar(Button[I*5].Text[0].Text);
            for J := 0 to PartySession.Teams.Teaminfo[I].NumPlayers-1 do
            begin
              PartySession.Teams.Teaminfo[I].Playerinfo[J].Name := PChar(Button[I*5 + J+1].Text[0].Text);
              PartySession.Teams.Teaminfo[I].Playerinfo[J].TimesPlayed := 0;
            end;
          end;

          Music.PlayStart;
          FadeTo(@ScreenPartyNewRound);
        end;

      // Up and Down could be done at the same time,
      // but I don't want to declare variables inside
      // functions like this one, called so many times
      SDLK_DOWN:    IntNext;
      SDLK_UP:      IntPrev;
      SDLK_RIGHT:   IntNext;
      SDLK_LEFT:    IntPrev;
    end;
  end;
  end;
end;

constructor TScreenPartyPlayer.Create;
begin
  inherited Create;

  LoadFromTheme(Theme.PartyPlayer);

  Team1Name := AddButton(Theme.PartyPlayer.Team1Name);
  AddButton(Theme.PartyPlayer.Player1Name);
  AddButton(Theme.PartyPlayer.Player2Name);
  AddButton(Theme.PartyPlayer.Player3Name);
  AddButton(Theme.PartyPlayer.Player4Name);

  Team2Name := AddButton(Theme.PartyPlayer.Team2Name);
  AddButton(Theme.PartyPlayer.Player5Name);
  AddButton(Theme.PartyPlayer.Player6Name);
  AddButton(Theme.PartyPlayer.Player7Name);
  AddButton(Theme.PartyPlayer.Player8Name);

  Team3Name := AddButton(Theme.PartyPlayer.Team3Name);
  AddButton(Theme.PartyPlayer.Player9Name);
  AddButton(Theme.PartyPlayer.Player10Name);
  AddButton(Theme.PartyPlayer.Player11Name);
  AddButton(Theme.PartyPlayer.Player12Name);

  Interaction := 0;
end;

procedure TScreenPartyPlayer.onShow;
var
  I:    integer;
begin
  if not Help.SetHelpID(ID) then
    Log.LogError('No Entry for Help-ID ' + ID + ' (ScreenPartyPlayer)');

  // Templates for Names Mod
  for I := 1 to 4 do
    Button[I].Text[0].Text := Ini.Name[I-1];

  for I := 6 to 9 do
    Button[I].Text[0].Text := Ini.Name[I-2];

  for I := 11 to 14 do
    Button[I].Text[0].Text := Ini.Name[I-3];

    Button[0].Text[0].Text := Ini.NameTeam[0];
    Button[5].Text[0].Text := Ini.NameTeam[1];
    Button[10].Text[0].Text := Ini.NameTeam[2];
    // Templates for Names Mod end


  If (PartySession.Teams.NumTeams>=1) then
  begin
    Button[0].Visible := True;
    Button[1].Visible := (PartySession.Teams.Teaminfo[0].NumPlayers >=1);
    Button[2].Visible := (PartySession.Teams.Teaminfo[0].NumPlayers >=2);
    Button[3].Visible := (PartySession.Teams.Teaminfo[0].NumPlayers >=3);
    Button[4].Visible := (PartySession.Teams.Teaminfo[0].NumPlayers >=4);
  end
  else
  begin
    Button[0].Visible := False;
    Button[1].Visible := False;
    Button[2].Visible := False;
    Button[3].Visible := False;
    Button[4].Visible := False;
  end;

  If (PartySession.Teams.NumTeams>=2) then
  begin
    Button[5].Visible := True;
    Button[6].Visible := (PartySession.Teams.Teaminfo[1].NumPlayers >=1);
    Button[7].Visible := (PartySession.Teams.Teaminfo[1].NumPlayers >=2);
    Button[8].Visible := (PartySession.Teams.Teaminfo[1].NumPlayers >=3);
    Button[9].Visible := (PartySession.Teams.Teaminfo[1].NumPlayers >=4);
  end
  else
  begin
    Button[5].Visible := False;
    Button[6].Visible := False;
    Button[7].Visible := False;
    Button[8].Visible := False;
    Button[9].Visible := False;
  end;

  If (PartySession.Teams.NumTeams>=3) then
  begin
    Button[10].Visible := True;
    Button[11].Visible := (PartySession.Teams.Teaminfo[2].NumPlayers >=1);
    Button[12].Visible := (PartySession.Teams.Teaminfo[2].NumPlayers >=2);
    Button[13].Visible := (PartySession.Teams.Teaminfo[2].NumPlayers >=3);
    Button[14].Visible := (PartySession.Teams.Teaminfo[2].NumPlayers >=4);
  end
  else
  begin
    Button[10].Visible := False;
    Button[11].Visible := False;
    Button[12].Visible := False;
    Button[13].Visible := False;
    Button[14].Visible := False;
  end;

end;

procedure TScreenPartyPlayer.SetAnimationProgress(Progress: real);
var
  I:    integer;
begin
  for I := 0 to high(Button) do
    Button[I].Texture.ScaleW := Progress;
end;

  // perfektes Mischen nach Fisher-Yates (for randomize PlayerNames - merc)
procedure TScreenPartyPlayer.ShuffleNames(var aArray: TArray);
  var
    i,j: Integer;
    tmp: TArrayElement;
begin
  for i := Low(aArray) to High(aArray) do begin
    j := i +Random(Length(aArray) -i +Low(aArray));
    tmp := aArray[j];
    aArray[j] := aArray[i];
    aArray[i] := tmp;
  end;
end;

end.