unit UScreenOptionsThemes;

interface

{$I switches.inc}

uses
  UMenu, SDL, UDisplay, UMusic, UFiles, UIni, UThemes;

type
  TScreenOptionsThemes = class(TMenu)
    public
      SkinSelect: Integer;
      constructor Create; override;
      function ParseInput(PressedKey: Cardinal; ScanCode: byte; PressedDown: Boolean): Boolean; override;
      procedure onShow; override;
      procedure InteractInc; override;
      procedure InteractDec; override;
  end;

implementation

uses UGraphic, USkins;

function TScreenOptionsThemes.ParseInput(PressedKey: Cardinal; ScanCode: byte; PressedDown: Boolean): Boolean;
begin
  Result := true;
  If (PressedDown) Then
  begin // Key Down
    case PressedKey of
      SDLK_Q:
        begin
          Result := false;
        end;

      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          Ini.Save;

          // Reload all screens, after Theme changed
          // Todo : JB - Check if theme was actually changed
          UGraphic.UnLoadScreens();
          UGraphic.LoadScreens();

          AudioPlayback.PlayBack;
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 3 then
          begin
            Ini.Save;

            // Reload all screens, after Theme changed
            // Todo : JB - Check if theme was actually changed
            UGraphic.UnLoadScreens();
            UGraphic.LoadScreens();

            UGraphic.LoadScreens();

            AudioPlayback.PlayBack;
            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then 
          begin
            AudioPlayback.PlayOption;
            InteractInc;
          end;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then 
          begin
            AudioPlayback.PlayOption;
            InteractDec;
          end;
        end;
    end;
  end;
end;

procedure TScreenOptionsThemes.InteractInc;
begin
  inherited InteractInc;
  //Update Skins
  if (SelInteraction = 0) then
  begin
    Skin.OnThemeChange;
    UpdateSelectSlideOptions (Theme.OptionsThemes.SelectSkin, SkinSelect, ISkin, Ini.SkinNo);

    Theme.LoadTheme('Themes\' + ITheme[Ini.Theme] + '.ini', Ini.Color);

    ScreenOptionsThemes := TScreenOptionsThemes.create();
    ScreenOptionsThemes.onshow;
    Display.ActualScreen := @ScreenOptionsThemes;
    ScreenOptionsThemes.Draw;


    Display.Draw;
    SwapBuffers;

    freeandnil( self );
    
  end;
end;

procedure TScreenOptionsThemes.InteractDec;
begin
  inherited InteractDec;
  //Update Skins
  if (SelInteraction = 0) then
  begin
    Skin.OnThemeChange;
    UpdateSelectSlideOptions (Theme.OptionsThemes.SelectSkin, SkinSelect, ISkin, Ini.SkinNo);

    Theme.LoadTheme('Themes\' + ITheme[Ini.Theme] + '.ini', Ini.Color);

    ScreenOptionsThemes := TScreenOptionsThemes.create();
    ScreenOptionsThemes.onshow;
    Display.ActualScreen := @ScreenOptionsThemes;
    ScreenOptionsThemes.Draw;


    Display.Draw;
    SwapBuffers;

    freeandnil( self );
    
  end;
end;

constructor TScreenOptionsThemes.Create;
var
  I:      integer;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsThemes);

  AddSelectSlide(Theme.OptionsThemes.SelectTheme, Ini.Theme, ITheme);

  SkinSelect := AddSelectSlide(Theme.OptionsThemes.SelectSkin, Ini.SkinNo, ISkin);

  AddSelectSlide(Theme.OptionsThemes.SelectColor, Ini.Color, IColor);

  AddButton(Theme.OptionsThemes.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(14, 20, Theme.Options.Description[7]);
end;

procedure TScreenOptionsThemes.onShow;
begin
  Interaction := 0;
end;

end.