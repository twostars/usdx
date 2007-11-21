; This list contains the files that will be installed

; Create required directories:
  
  CreateDirectory "$INSTDIR\Covers"
  CreateDirectory "$INSTDIR\Languages"
  CreateDirectory "$INSTDIR\Plugins"
  CreateDirectory "$INSTDIR\Skins"
  CreateDirectory "$INSTDIR\Skins\Classic"
  CreateDirectory "$INSTDIR\Skins\Deluxe"
  CreateDirectory "$INSTDIR\Songs"
  CreateDirectory "$INSTDIR\Sounds"
  CreateDirectory "$INSTDIR\Themes"

; Extract files to the directories:

  SetOutPath "$INSTDIR"
  File "..\InstallerDependencies\dll\bass.dll"
  File "..\InstallerDependencies\dll\SDL.dll"
  File "..\InstallerDependencies\dll\smpeg.dll"
  File "..\InstallerDependencies\dll\sqlite3.dll"

  File "..\InstallerDependencies\documents\Changelog.german.txt"
  File "..\InstallerDependencies\documents\Changelog.txt"
  File "..\InstallerDependencies\documents\documentation.pdf"
  File "..\InstallerDependencies\documents\License.txt"
  File "..\InstallerDependencies\documents\ReadMe.txt"

  File "..\ScoreConverter.exe"
  File "..\${exe}.exe"

${If} ${AtLeastWinVista}

  SetOutPath "$WINDIR"
  File "..\InstallerDependencies\plugins\gdf.dll"

${EndIf}

  SetOutPath "$INSTDIR\Covers\"
  File "..\Covers\Covers.ini"
  File "..\Covers\NoCover.jpg"

  SetOutPath "$INSTDIR\Languages\"

  File "..\Languages\readme.txt"

  File "..\Languages\Catalan.ini"
  File "..\Languages\Dutch.ini"
  File "..\Languages\English.ini"
  File "..\Languages\French.ini"
  File "..\Languages\German.ini"
  File "..\Languages\Italian.ini"
  File "..\Languages\Norwegian.ini"
  File "..\Languages\Portuguese.ini"
  File "..\Languages\Serbian.ini"
  File "..\Languages\Spanish.ini"
  File "..\Languages\Swedish.ini"

  SetOutPath "$INSTDIR\Plugins\"
  File "..\Plugins\Blind.dll"
  File "..\Plugins\Duell.dll"
  File "..\Plugins\Hold_The_Line.dll"
  File "..\Plugins\Until5000.dll"

  SetOutPath "$INSTDIR\Skins\Classic\"
  File "..\Skins\Classic\[button]13.jpg"
  File "..\Skins\Classic\[button]alt.jpg"
  File "..\Skins\Classic\[button]az.jpg"
  File "..\Skins\Classic\[button]e.jpg"
  File "..\Skins\Classic\[button]enter.jpg"
  File "..\Skins\Classic\[button]esc.jpg"
  File "..\Skins\Classic\[button]j.jpg"
  File "..\Skins\Classic\[button]m.jpg"
  File "..\Skins\Classic\[button]navi.jpg"
  File "..\Skins\Classic\[button]p.jpg"
  File "..\Skins\Classic\[effect]goldenNoteStar.jpg"
  File "..\Skins\Classic\[effect]perfectNoteStar.jpg"
  File "..\Skins\Classic\[helper]rectangle.jpg"
  File "..\Skins\Classic\[icon]error.jpg"
  File "..\Skins\Classic\[icon]question.jpg"
  File "..\Skins\Classic\[icon]Star.jpg"
  File "..\Skins\Classic\[icon]stats.jpg"
  File "..\Skins\Classic\[icon]video.jpg"
  File "..\Skins\Classic\[main]Bar.jpg"
  File "..\Skins\Classic\[main]Bar1.jpg"
  File "..\Skins\Classic\[main]Button.jpg"
  File "..\Skins\Classic\[main]Button2.jpg"
  File "..\Skins\Classic\[main]Button3.jpg"
  File "..\Skins\Classic\[main]ButtonEditor.jpg"
  File "..\Skins\Classic\[main]Logo.jpg"
  File "..\Skins\Classic\[main]songCover.jpg"
  File "..\Skins\Classic\[main]square.jpg"
  File "..\Skins\Classic\[mainbutton]Exit.jpg"
  File "..\Skins\Classic\[mainbutton]Multi.jpg"
  File "..\Skins\Classic\[mainbutton]Options.jpg"
  File "..\Skins\Classic\[mainbutton]Solo.jpg"
  File "..\Skins\Classic\[mainbutton]Stats.jpg"
  File "..\Skins\Classic\[menu]jumpToBg.jpg"
  File "..\Skins\Classic\[menu]PopUpBg.JPG"
  File "..\Skins\Classic\[menu]PopUpFg.JPG"
  File "..\Skins\Classic\[menu]songMenuBg.jpg"
  File "..\Skins\Classic\[menu]songMenuBorder.jpg"
  File "..\Skins\Classic\[menu]songMenuButtonBG.jpg"
  File "..\Skins\Classic\[menu]songMenuSelectBG.jpg"
  File "..\Skins\Classic\[party]Joker.jpg"
  File "..\Skins\Classic\[party]playerButton.jpg"
  File "..\Skins\Classic\[party]playerTeamButton.jpg"
  File "..\Skins\Classic\[party]pointer.bmp"
  File "..\Skins\Classic\[party]roundBG1.jpg"
  File "..\Skins\Classic\[party]roundBG2.jpg"
  File "..\Skins\Classic\[party]roundBG3.jpg"
  File "..\Skins\Classic\[party]roundBG4.jpg"
  File "..\Skins\Classic\[party]roundTeamButton.jpg"
  File "..\Skins\Classic\[party]scoreBG1.jpg"
  File "..\Skins\Classic\[party]scoreBG2.jpg"
  File "..\Skins\Classic\[party]scoreDecoration.jpg"
  File "..\Skins\Classic\[party]teamPoints.jpg"
  File "..\Skins\Classic\[party]winDecoration.jpg"
  File "..\Skins\Classic\[party]winTeamButton1.jpg"
  File "..\Skins\Classic\[party]winTeamButton2.jpg"
  File "..\Skins\Classic\[party]winTeamButton3.jpg"
  File "..\Skins\Classic\[score]box.jpg"
  File "..\Skins\Classic\[score]level.jpg"
  File "..\Skins\Classic\[score]levelround.jpg"
  File "..\Skins\Classic\[score]line.jpg"
  File "..\Skins\Classic\[sing]lineBonusPopUp.jpg"
  File "..\Skins\Classic\[sing]LyricsBall.bmp"
  File "..\Skins\Classic\[sing]lyricsHelpBar.bmp"
  File "..\Skins\Classic\[sing]notesBgLeft.bmp"
  File "..\Skins\Classic\[sing]notesBgMid.bmp"
  File "..\Skins\Classic\[sing]notesBgRight.bmp"
  File "..\Skins\Classic\[sing]notesLeft.bmp"
  File "..\Skins\Classic\[sing]notesMid.bmp"
  File "..\Skins\Classic\[sing]notesRight.bmp"
  File "..\Skins\Classic\[sing]p.jpg"
  File "..\Skins\Classic\[sing]scoreBg.jpg"
  File "..\Skins\Classic\[sing]singBarBack.jpg"
  File "..\Skins\Classic\[sing]singBarBar.jpg"
  File "..\Skins\Classic\[sing]singBarFront.jpg"
  File "..\Skins\Classic\[sing]textBar.jpg"
  File "..\Skins\Classic\[song]BGFade.jpg"
  File "..\Skins\Classic\[song]EqualizerBG.jpg"
  File "..\Skins\Classic\[song]selection.jpg"
  File "..\Skins\Classic\[stat]detailBG1.jpg"
  File "..\Skins\Classic\[stat]mainBG1.jpg"
  File "..\Skins\Classic\[stat]mainBG2.jpg"
  File "..\Skins\Classic\[stat]mainBG3.jpg"
  File "..\Skins\Classic\Star.ini"

  SetOutPath "$INSTDIR\Skins\Deluxe\"
  File "..\Skins\Deluxe\[bg-load]blue.jpg"
  File "..\Skins\Deluxe\[bg-load]fall.jpg"
  File "..\Skins\Deluxe\[bg-load]summer.jpg"
  File "..\Skins\Deluxe\[bg-load]winter.jpg"
  File "..\Skins\Deluxe\[bg-main]blue.jpg"
  File "..\Skins\Deluxe\[bg-main]fall.jpg"
  File "..\Skins\Deluxe\[bg-main]summer.jpg"
  File "..\Skins\Deluxe\[bg-main]winter.jpg"
  File "..\Skins\Deluxe\[button]13.jpg"
  File "..\Skins\Deluxe\[button]alt.jpg"
  File "..\Skins\Deluxe\[button]az.jpg"
  File "..\Skins\Deluxe\[button]enter.jpg"
  File "..\Skins\Deluxe\[button]esc.jpg"
  File "..\Skins\Deluxe\[button]j.jpg"
  File "..\Skins\Deluxe\[button]m.jpg"
  File "..\Skins\Deluxe\[button]navi.jpg"
  File "..\Skins\Deluxe\[button]p.jpg"
  File "..\Skins\Deluxe\[effect]goldenNoteStar.jpg"
  File "..\Skins\Deluxe\[effect]perfectNoteStar.jpg"
  File "..\Skins\Deluxe\[helper]buttonFade.jpg"
  File "..\Skins\Deluxe\[helper]rectangle.jpg"
  File "..\Skins\Deluxe\[icon]cd.jpg"
  File "..\Skins\Deluxe\[icon]error.jpg"
  File "..\Skins\Deluxe\[icon]main.jpg"
  File "..\Skins\Deluxe\[icon]options.jpg"
  File "..\Skins\Deluxe\[icon]party.jpg"
  File "..\Skins\Deluxe\[icon]question.jpg"
  File "..\Skins\Deluxe\[icon]score.jpg"
  File "..\Skins\Deluxe\[icon]search.jpg"
  File "..\Skins\Deluxe\[icon]songmenu.jpg"
  File "..\Skins\Deluxe\[icon]stats.jpg"
  File "..\Skins\Deluxe\[icon]video.jpg"
  File "..\Skins\Deluxe\[main]button.jpg"
  File "..\Skins\Deluxe\[main]buttonf.jpg"
  File "..\Skins\Deluxe\[main]mainBar.jpg"
  File "..\Skins\Deluxe\[main]playerNumberBox.jpg"
  File "..\Skins\Deluxe\[main]selectbg.jpg"
  File "..\Skins\Deluxe\[main]songCover.jpg"
  File "..\Skins\Deluxe\[main]songSelection1.jpg"
  File "..\Skins\Deluxe\[main]songSelection2.jpg"
  File "..\Skins\Deluxe\[menu]jumpToBg.jpg"
  File "..\Skins\Deluxe\[menu]PopUpBg.JPG"
  File "..\Skins\Deluxe\[menu]PopUpFg.JPG"
  File "..\Skins\Deluxe\[menu]songMenuBg.jpg"
  File "..\Skins\Deluxe\[menu]songMenuSelectBg.jpg"
  File "..\Skins\Deluxe\[party]Joker.jpg"
  File "..\Skins\Deluxe\[party]playerButton.jpg"
  File "..\Skins\Deluxe\[party]playerTeamButton.jpg"
  File "..\Skins\Deluxe\[party]pointer.bmp"
  File "..\Skins\Deluxe\[party]roundBG1.jpg"
  File "..\Skins\Deluxe\[party]roundBG2.jpg"
  File "..\Skins\Deluxe\[party]roundBG3.jpg"
  File "..\Skins\Deluxe\[party]roundBG4.jpg"
  File "..\Skins\Deluxe\[party]roundTeamButton.jpg"
  File "..\Skins\Deluxe\[party]scoreBG1.jpg"
  File "..\Skins\Deluxe\[party]scoreBG2.jpg"
  File "..\Skins\Deluxe\[party]scoreDecoration.jpg"
  File "..\Skins\Deluxe\[party]teamPoints.jpg"
  File "..\Skins\Deluxe\[party]winDecoration1.jpg"
  File "..\Skins\Deluxe\[party]winTeamButton1.jpg"
  File "..\Skins\Deluxe\[party]winTeamButton2.jpg"
  File "..\Skins\Deluxe\[party]winTeamButton3.jpg"
  File "..\Skins\Deluxe\[score]box.jpg"
  File "..\Skins\Deluxe\[score]endcap.jpg"
  File "..\Skins\Deluxe\[score]level.jpg"
  File "..\Skins\Deluxe\[score]levelRound.jpg"
  File "..\Skins\Deluxe\[score]Line.jpg"
  File "..\Skins\Deluxe\[sing]lineBonusPopUp.jpg"
  File "..\Skins\Deluxe\[sing]LyricsBall.bmp"
  File "..\Skins\Deluxe\[sing]lyricsHelpBar.bmp"
  File "..\Skins\Deluxe\[sing]notesBgLeft.bmp"
  File "..\Skins\Deluxe\[sing]notesBgMid.bmp"
  File "..\Skins\Deluxe\[sing]notesBgRight.bmp"
  File "..\Skins\Deluxe\[sing]notesLeft.bmp"
  File "..\Skins\Deluxe\[sing]notesMid.bmp"
  File "..\Skins\Deluxe\[sing]notesRight.bmp"
  File "..\Skins\Deluxe\[sing]p.jpg"
  File "..\Skins\Deluxe\[sing]scoreBg.jpg"
  File "..\Skins\Deluxe\[sing]singBarBack.jpg"
  File "..\Skins\Deluxe\[sing]singBarBar.jpg"
  File "..\Skins\Deluxe\[sing]singBarFront.jpg"
  File "..\Skins\Deluxe\[sing]textBar.jpg"
  File "..\Skins\Deluxe\[sing]timeBar.jpg"
  File "..\Skins\Deluxe\[sing]timeBar1.jpg"
  File "..\Skins\Deluxe\[sing]timeBarBG.jpg"
  File "..\Skins\Deluxe\[special]bar1.jpg"
  File "..\Skins\Deluxe\[special]bar2.jpg"
  File "..\Skins\Deluxe\[stat]detailBG1.jpg"
  File "..\Skins\Deluxe\[stat]mainBG1.jpg"
  File "..\Skins\Deluxe\[stat]mainBG2.jpg"
  File "..\Skins\Deluxe\[stat]mainBG3.jpg"
  File "..\Skins\Deluxe\Blue.ini"
  File "..\Skins\Deluxe\Fall.ini"
  File "..\Skins\Deluxe\Summer.ini"
  File "..\Skins\Deluxe\Winter.ini"

  SetOutPath "$INSTDIR\Sounds\"
  File "..\Sounds\Common back.mp3"
  File "..\Sounds\Common start.mp3"
  File "..\Sounds\credits-outro-tune.mp3"
  File "..\Sounds\dismissed.mp3"
  File "..\Sounds\menu swoosh.mp3"
  File "..\Sounds\option change col.mp3"
  File "..\Sounds\rimshot022b.mp3"
  File "..\Sounds\select music change music 50.mp3"
  File "..\Sounds\select music change music.mp3"
  File "..\Sounds\wome-credits-tune.mp3"
  
  SetOutPath "$INSTDIR\Themes\"
  File "..\Themes\Classic.ini"
  File "..\Themes\Deluxe.ini"

  SetOutPath "$INSTDIR"