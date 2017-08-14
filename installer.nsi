; ImagoTrigger@gmail.com for AZ

SetCompressor /SOLID lzma

!include "build.nsh"

!define CLIENT_FILE_URL "http://cdn.allegiancezone.com/install/Client_${BUILD}.7z"
!define MINIMAL_FILE_URL "http://cdn.allegiancezone.com/install/Minimal_${BUILD}.7z"
!define REGULAR_FILE_URL "http://cdn.allegiancezone.com/install/Regular_${BUILD}.7z"
!define HIRES_FILE_URL "http://cdn.allegiancezone.com/install/Hires_${BUILD}.7z"
!define TOOLS_FILE_URL "http://cdn.allegiancezone.com/install/Tools_${BUILD}.7z"
!define SERVER_FILE_URL "http://cdn.allegiancezone.com/install/Server_${BUILD}.7z"
!define LOBBY_FILE_URL "http://cdn.allegiancezone.com/install/Lobby_${BUILD}.7z"
!define MUSIC_FILE_URL "http://cdn.allegiancezone.com/install/Music_${BUILD}.7z"
!define PDB_FILE_URL "http://cdn.allegiancezone.com/install/Pdb_${BUILD}.7z"

!define VERSION2 "1.3"

var BGHWND
var IsWINE

!include "MUI2.nsh"
!include "InstallOptions.nsh"
!include "Sections.nsh"

XPStyle "on"
Name "Allegiance"
OutFile "${AZBP}\Package\AllegSetup_${BUILD}.exe"
InstallDir "$PROGRAMFILES\Allegiance ${VERSION2}"
RequestExecutionLevel admin
BrandingText "Allegiance Zone - http://www.allegiancezone.com" 
Insttype "Install client /w high-resolution graphics"
Insttype "Install client /w regular graphics"
Insttype "Install server"

Var PAGETOKEEP
Var SHOWFINISH
Var ICONS_GROUP
var ARTPATH

!include "${AZBP}\installer.nsh"

Function myonguiinit
	${If} $IsWINE != "1"
    	SetOutPath $TEMP
	File "${AZBP}\mainbkgnd2.gif"
	File "${AZBP}\bombrun.gif"
	File "${AZBP}\screen.gif"
	File "${AZBP}\2.gif"
	BgImage::SetBg /NOUNLOAD /GRADIENT 0x00 0x00 0x00 0x00 0x00 0x00
	BgImage::Redraw
	Sleep 1
	FindWindow $BGHWND 'NSISBGImage'
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\mainbkgnd2.gif"
	${EndIf}	
FunctionEnd

!define MUI_CUSTOMFUNCTION_GUIINIT myonguiinit

Page custom PageCreate PageLeave

!define MUI_ICON "${AZBP}\allegg.ico"
!define MUI_UNICON "${AZBP}\allegr.ico"

!define MUI_COMPONENTSPAGE_NODESC
!define MUI_PAGE_CUSTOMFUNCTION_PRE LicensePage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_LICENSE "${AZBP}\EULA.rtf"

!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryPage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_PAGE_CUSTOMFUNCTION_PRE ComponentsPage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_CUSTOMFUNCTION_PRE StartMenuPage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

!insertmacro MUI_PAGE_INSTFILES

!define MUI_WELCOMEFINISHPAGE_BITMAP "${AZBP}\fakemessage.bmp"
!define MUI_FINISHPAGE_RUN "$INSTDIR\Allegiance.exe"
!define MUI_PAGE_CUSTOMFUNCTION_PRE PreFinish
!define MUI_PAGE_CUSTOMFUNCTION_SHOW ModifyCheckboxes
!define MUI_FINISHPAGE_TITLE 'Finished installing the Allegiance Zone files to your computer.'
!define MUI_TEXT_FINISH_INFO_TEXT 'The selected components have been setup.$\r$\n$\r$\nClick finish to close this installer.'
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View the Rules of Conduct"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.rtf" ;
!define MUI_FINISHPAGE_LINK "Signup for an account"
!define MUI_FINISHPAGE_LINK_LOCATION "http://allegiancezone.com/signup"
!insertmacro MUI_PAGE_FINISH
  
!include "${AZBP}\lang.nsh"

VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Allegiance Zone Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Created by imago.buildvideogames.com at ${RUNTIME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Allegiance Zone"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Allegiance is a trademark of Microsoft Corporation"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© 1995-2000 Microsoft Corporation.  All rights reserved."
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "The Microsoft© Allegiance Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}.0.0"
VIProductVersion "1.3.0.${BUILD}"

Section "-"
SetOutPath "$TEMP"
File ${AZBP}\AZCA.cer
Push $TEMP\AZCA.cer
Call AddCertificateToStore
Pop $0
Delete $TEMP\AZCA.cer
SetOutPath "$INSTDIR"
${If} ${FileExists} "$INSTDIR\Artwork\font.mdl"
	ClearErrors
	FileOpen $R0 "$INSTDIR\Artwork\font.mdl" a
	${If} ${Errors}
		MessageBox MB_ICONEXCLAMATION|MB_OK "Error 1 - $INSTDIR\Artwork\ is in use!  Please close Allegiance and try again."
		Abort
	${Else}
	 FileClose $R0
	${EndIf}
	ClearErrors
	Rename "$INSTDIR\Artwork\font.mdl" "$INSTDIR\Artwork\font_test.mdl"
	${If} ${Errors}
		MessageBox MB_ICONEXCLAMATION|MB_OK "Error 2 - $INSTDIR\Artwork\ is in use!  Please close Allegiance and try again."
		Abort
	${Else}
	 Rename "$INSTDIR\Artwork\font_test.mdl" "$INSTDIR\Artwork\font.mdl"
	${EndIf}	
${EndIf}
SectionEnd

Section /o "Client" 
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\2.gif"
	${Endif}
	AddSize 8000
	SectionIn 1 2
	DetailPrint "Client..."
	Call GetDXVersion
	Pop $R3
	IntCmp $R3 900 +2 0 +2
	 	Call SetupDX
  	StrCpy $SHOWFINISH 1
  	DeleteRegValue HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "MoveInProgress"
	DeleteRegValue HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "MoveInProgress"
	${GameExplorer_AddGame} all "$INSTDIR\Allegiance.exe" "$INSTDIR" "$INSTDIR\Allegiance.exe" "" ""
	${GameExplorer_AddPlayTask} "Safe Mode" "$INSTDIR\Allegiance.exe" "-software -nomovies"
	${GameExplorer_AddSupportTask} "Home Page" "http://www.allegiancezone.com/"
	Delete $PLUGINSDIR\GameuxInstallHelper.dll	
	SimpleFC::IsFirewallEnabled 
	Pop $0
	Pop $1
	${If} $1 == 1
		SimpleFC::AddApplication "Allegiance" "$INSTDIR\Allegiance.exe" 0 2 "" 1
		DetailPrint "Added firewall exception."
		Pop $0
	${Endif}
	SetOutPath "$INSTDIR"
  	StrCpy $1 "$INSTDIR\Client.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${CLIENT_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${CLIENT_FILE_SIZE} ${CLIENT_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${CLIENT_FILE_SIZE} ${CLIENT_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Client.7z" $R9
	  GetFunctionAddress $R9 Callback7z

	WriteIniStr "$INSTDIR\Allegiance Training.url" "InternetShortcut" "URL" "http://www.allegiancezone.com/#Training"
	  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	  	CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
	  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Training.lnk" "$INSTDIR\Allegiance Training.url"
	  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance.lnk" "$INSTDIR\Allegiance.exe" "-autojoin //1"
	  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance (Safe mode).lnk" "$INSTDIR\Allegiance.exe" "-software -checkfiles"
	  	CreateShortCut "$DESKTOP\Allegiance.lnk" "$INSTDIR\Allegiance.exe" "-autojoin //1"
	  !insertmacro MUI_STARTMENU_WRITE_END
	  WriteRegStr HKCR "Allegiance" "URL Protocol" ""
	  WriteRegStr HKCR "Allegiance" "" "URL:Allegiance Protocol"
	  WriteRegStr HKCR "Allegiance\shell\open\command" "" '"$INSTDIR\Allegiance.exe" -autojoin %1 %2 %3 %4 %5 %6'
SectionEnd

SectionGroup "Graphics" SecArtwork
Section /o "Minimal Graphics" g1o1
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\bombrun.gif"
	AddSize 7000
	${Endif}
	SetOutPath "$INSTDIR"
	DetailPrint "Minimal Graphics..."
	CreateDirectory "$INSTDIR\Artwork_minimal"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork_minimal" "(BU)" "GenericRead + GenericWrite"
  	StrCpy $1 "$INSTDIR\Minimal.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${MINIMAL_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${MINIMAL_FILE_SIZE} ${MINIMAL_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${MINIMAL_FILE_SIZE} ${MINIMAL_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Minimal.7z" $R9
	  GetFunctionAddress $R9 Callback7z

	!insertmacro RemoveFilesAndSubDirs "$INSTDIR\Artwork\"
	RMDir /r "$INSTDIR\Artwork"
  	Rename "$INSTDIR\Artwork_minimal\" "$INSTDIR\Artwork\"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork" "(BU)" "GenericRead + GenericWrite"
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPAth" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZ.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZ.cfg"		
SectionEnd

Section /o "Regular Graphics" g1o2
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\bombrun.gif"
	${Endif}
	AddSize 700000
	SetOutPath "$INSTDIR"
	SectionIn 2
	DetailPrint "Regular Graphics..."
	CreateDirectory "$INSTDIR\Artwork"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork" "(BU)" "GenericRead + GenericWrite"
  	
  	StrCpy $1 "$INSTDIR\Regular.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Regular_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Regular_FILE_SIZE} ${Regular_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Regular_FILE_SIZE} ${Regular_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	
	!insertmacro RemoveFilesAndSubDirs "$INSTDIR\Artwork\"
	RMDir /r "$INSTDIR\Artwork"	
	
	  Nsis7z::ExtractWithCallback "$INSTDIR\Regular.7z" $R9
	  GetFunctionAddress $R9 Callback7z
 	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPAth" "$INSTDIR\Artwork"  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZNoart.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZNoart.cfg"	
	
SectionEnd

Section  "High-resolution Graphics" g1o3
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\bombrun.gif"
	${Endif}
	AddSize 1300000
	SetOutPath "$INSTDIR"
	SectionIn 1
	DetailPrint "High-resolution Graphics..."
	CreateDirectory "$INSTDIR\Artwork_detailed"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork_detailed" "(BU)" "GenericRead + GenericWrite"
  	StrCpy $1 "$INSTDIR\Hires.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Hires_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Hires_FILE_SIZE} ${Hires_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Hires_FILE_SIZE} ${Hires_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	Nsis7z::ExtractWithCallback "$INSTDIR\Hires.7z" $R9
	GetFunctionAddress $R9 Callback7z
	!insertmacro RemoveFilesAndSubDirs "$INSTDIR\Artwork\"
	RMDir /r "$INSTDIR\Artwork"
  	Rename "$INSTDIR\Artwork_detailed\" "$INSTDIR\Artwork\"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork" "(BU)" "GenericRead + GenericWrite"
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPAth" "$INSTDIR\Artwork"  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZNoart.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "CfgFile" "http://azcdn.blob.core.windows.net/config/AZNoart.cfg"		
SectionEnd

Section /o "No Graphics" g1o4
	SetOutPath "$INSTDIR"
	SectionIn 3
	DetailPrint "No Graphics..."
	SectionGetFlags 10 $9
	${If} ${SectionIsSelected} 1
		ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
		StrLen $6 $ARTPATH
		${If} $6 != 0
			goto hasArt0
		${EndIf}
		ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
		StrLen $6 $ARTPATH
		${If} $6 != 0
			goto hasArt0
		${EndIf}
		tryagain:
		System::Call '*(&t260) i.r0'		
		System::Call "*(i$HWNDPARENT, i, ir0, t'Select your existing Artwork folder or press Cancel to skip', i${BIF_RETURNONLYFSDIRS}, i, i, i) i.r1"
		System::Call "shell32::SHBrowseForFolder(i r1) i.r2"
		${If} $2 == 0
			MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to determine your Artwork folder location$\nYou must set an ArtPath string in the Allegiance\${VERSION2} registry key!"
		${Else}
			System::Call "shell32::SHGetPathFromIDList(i r2, t.r3)"
			FileOpen $4 "$3\introscreen.mdl" r
			FileRead $4 $5
			FileClose $4
			StrCmp $5 "//USEAZ1$\n" hasArt1
			MessageBox MB_ICONQUESTION|MB_RETRYCANCEL "$3 does not contain Allegiance Zone artwork files$\nDo you want to try again?" IDRETRY tryagain
			ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
			StrLen $6 $ARTPATH
			${If} $6 != 0
				goto hasArt2
			${EndIf}
			ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
			StrLen $6 $ARTPATH
			${If} $6 != 0
				goto hasArt2
			${EndIf}			
			MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to determine your Artwork location!$\nYou must set an ArtPath string in the Allegiance\${VERSION2} registry key"
			goto bailArt
			hasArt1:
			WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPath" "$3"
			WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "ArtPAth" "$3"  	
			hasArt2:			
		${EndIf}
		bailArt:
		System::Free $0
		System::Free $1	
		hasArt0:
	${EndIf}
SectionEnd
SectionGroupEnd

Section /o "Music"
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\2.gif"
	${Endif}
	AddSize 30000
	ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
	SetOutPath "$ARTPATH"
	DetailPrint "Music..."
	StrCpy $1 "$INSTDIR\Music.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Music_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Music_FILE_SIZE} ${Music_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Music_FILE_SIZE} ${Music_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Music.7z" $R9
	  GetFunctionAddress $R9 Callback7z
SectionEnd

Section /o "Program Databases"
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\screen.gif"
	${Endif}
	AddSize 70000
	SetOutPath "$INSTDIR"
	DetailPrint "Program Databases..."
	StrCpy $1 "$INSTDIR\Pdb.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Pdb_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Pdb_FILE_SIZE} ${Pdb_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Pdb_FILE_SIZE} ${Pdb_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Pdb.7z" $R9
	  GetFunctionAddress $R9 Callback7z
SectionEnd

Section /o "Artwork Tools"
	AddSize 5000
	SetOutPath "$INSTDIR\Tools"
	DetailPrint "Artwork Tools..."
	CreateDirectory "$INSTDIR\Tools"
	AccessControl::GrantOnFile "$INSTDIR\Tools" "(BU)" "GenericRead + GenericWrite"
	StrCpy $1 "$INSTDIR\Tools.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Tools_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Tools_FILE_SIZE} ${Tools_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Tools_FILE_SIZE} ${Tools_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Tools.7z" $R9
	  GetFunctionAddress $R9 Callback7z
  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Artwork Tools.lnk" "$INSTDIR\Tools"
  	CreateShortCut "$DESKTOP\Allegiance Artwork Tools.lnk" "$INSTDIR\Tools"
SectionEnd

Section /o "Server"
	${If} $IsWINE != "1"
	AnimGif::stop
	AnimGif::play /NOUNLOAD /HALIGN=Center /VALIGN=Center /FIT=BOTH /HWND=$BGHWND "$TEMP\screen.gif"
	${Endif}
	AddSize 110000
	SetOutPath "$INSTDIR\Server"
	DetailPrint "Server..."
	SectionIn 3
	SimpleFC::IsFirewallEnabled 
	Pop $0
	Pop $1
	${If} $1 == 1
		SimpleFC::AddApplication "AllSrv" "$INSTDIR\Server\AllSrv.exe" 0 2 "" 1
		DetailPrint "Added firewall exception."
		Pop $0
	${Endif}		
	CreateDirectory "$INSTDIR\Server"
	CreateDirectory "$INSTDIR\Server\Artwork"
	AccessControl::GrantOnFile "$INSTDIR\Server" "(BU)" "GenericRead + GenericWrite"
	AccessControl::GrantOnFile "$INSTDIR\Server\Artwork" "(BU)" "GenericRead + GenericWrite"
	StrCpy $1 "$INSTDIR\Server.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Server_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Server_FILE_SIZE} ${Server_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Server_FILE_SIZE} ${Server_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Server.7z" $R9
	  GetFunctionAddress $R9 Callback7z

	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}\Server" "ArtPath" "$INSTDIR\Server\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}\Server" "ArtPAth" "$INSTDIR\Server\Artwork"  		
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Server.lnk" "$INSTDIR\Server\AllSrvUI.exe"
  	CreateShortCut "$DESKTOP\Allegiance Server.lnk" "$INSTDIR\Server\AllSrvUI.exe"
  	nsExec::Exec "regsvr32 /s $INSTDIR\Server\AGC.dll"
	nsExec::Exec "$INSTDIR\Server\AllSrv.exe -RegServer"
SectionEnd

Section /o "Lobby"
	AddSize 2000
	SetOutPath "$INSTDIR\Lobby"
	DetailPrint "Lobby..."
	SimpleFC::IsFirewallEnabled 
	Pop $0
	Pop $1
	${If} $1 == 1
		SimpleFC::AddApplication "AllLobby" "$INSTDIR\Lobby\AllLobby.exe" 0 2 "" 1
		DetailPrint "Added firewall exception."
		Pop $0
	${Endif}		
	CreateDirectory "$INSTDIR\Lobby"
	AccessControl::GrantOnFile "$INSTDIR\Lobby" "(BU)" "GenericRead + GenericWrite"	
	StrCpy $1 "$INSTDIR\Lobby.7z"
	IfFileExists $1 +1 DoesntExist
	  Push $1
	  Call FileSizeNew
	  Pop $2
	  IntCmp $2 ${Lobby_FILE_SIZE} Success
	  MessageBox MB_YESNO "The file $1 already exists.$\nDo you want to resume the download?" /SD IDYES IDYES ResumeDL IDNO DoesntExist
	ResumeDL:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RESUME /RETRIES=8 /FILESIZE=${Lobby_FILE_SIZE} ${Lobby_FILE_URL} "$1"
	  Goto Done
	DoesntExist:
	    NSISdl::download /TIMEOUT=25000 /NODELETE /RETRIES=8 /FILESIZE=${Lobby_FILE_SIZE} ${Lobby_FILE_URL}  "$1"
	Done:
	  Pop $R0 
	  StrCmp $R0 "success" Success
	    MessageBox MB_OK "Download failed: $R0"
	  Quit
	Success:
	  Nsis7z::ExtractWithCallback "$INSTDIR\Lobby.7z" $R9
	  GetFunctionAddress $R9 Callback7z
	
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Lobby.lnk" "$INSTDIR\Lobby\AllLobby.exe"
  	CreateShortCut "$DESKTOP\AllLobby.lnk" "$INSTDIR\Lobby\AllLobby.exe"	
  	nsExec::Exec "$INSTDIR\Lobby\AllLobby.exe -RegServer"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\AllegianceZone.url" "InternetShortcut" "URL" "http://www.allegiancezone.com"
SectionEnd

Section -Post
  SetOutPath "$INSTDIR"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\Allegiance\${VERSION2}" "" "$INSTDIR\Allegiance.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayIcon" "$INSTDIR\Allegiance.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "URLInfoAbout" "http://www.allegiancezone.com"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "Publisher" "Allegiance Zone" 
SectionEnd

Section Uninstall
	nsExec::Exec "$INSTDIR\Server\AllSrv.exe -UnRegServer"
	nsExec::Exec "$INSTDIR\Lobby\AllLobby.exe -UnRegServer"
	nsExec::Exec "regsvr32 /u /s $INSTDIR\Server\AGC.dll"

    	SimpleFC::RemoveApplication "Allegiance";
    	SimpleFC::RemoveApplication "AllSrv";
    	SimpleFC::RemoveApplication "AllLobby";

 	!insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
	IfFileExists "$INSTDIR\Artwork\*.*" DeleteReg
	goto skipreg
	DeleteReg:
	ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
	StrCmp $ARTPATH "$INSTDIR\Artwork" matchedArt
	StrCmp $ARTPATH "$INSTDIR\Artwork\" matchedArt
	ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" ArtPath
	StrCmp $ARTPATH "$INSTDIR\Artwork" matchedArt
	StrCmp $ARTPATH "$INSTDIR\Artwork\" matchedArt
	goto skipreg
	matchedArt:
	DeleteRegValue HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "Artpath"
	DeleteRegValue HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION2}" "Artpath"

	skipreg:
	StrCmp $INSTDIR "" skipdel
	!insertmacro RemoveFilesAndSubDirs "$INSTDIR\"
	skipdel:
	
	  Delete "$DESKTOP\Allegiance.lnk"
	  Delete "$DESKTOP\Allegiance Server.lnk"
	  Delete "$DESKTOP\Allegiance Lobby.lnk"
	  Delete "$DESKTOP\Allegiance Artwork Tools.lnk"
	  Delete "$SMPROGRAMS\$ICONS_GROUP\Allegiance.lnk"
	  Delete "$SMPROGRAMS\$ICONS_GROUP\Allegiance Server.lnk"
	  Delete "$SMPROGRAMS\$ICONS_GROUP\Allegiance Lobby.lnk"
	  Delete "$SMPROGRAMS\$ICONS_GROUP\Artwork Tools.lnk"
	  Delete "$SMPROGRAMS\$ICONS_GROUP\Allegiance Training.lnk"
	  RMDir "$SMPROGRAMS\$ICONS_GROUP"
	  RMDir "$INSTDIR"

 	 DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone"
 	 DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\Allegiance\${VERSION2}"
  
	${GameExplorer_RemoveGame} all "$INSTDIR\Allegiance.exe" "$INSTDIR" "$INSTDIR\Allegiance.exe" "" 
	SetAutoClose true
SectionEnd

Function .onInstSuccess
  	  Delete "$INSTDIR\Lobby.7z"
  	  Delete "$INSTDIR\Client.7z"
  	  Delete "$INSTDIR\Minimal.7z"
  	  Delete "$INSTDIR\Regular.7z"
  	  Delete "$INSTDIR\Hires.7z"  
  	  Delete "$INSTDIR\Server.7z"
  	  Delete "$INSTDIR\Tools.7z"
  	  Delete "$INSTDIR\Music.7z" 	
  	  Delete "$INSTDIR\Pdb.7z"  	  
  	  ${If} $IsWINE == "1"
  	  	Exec "winetricks directplay"
  	  ${Endif}
FunctionEnd

Function .onInit
	!insertmacro IfKeyExists "HKLM" "SOFTWARE" "Wine"
	Pop $R0
	StrCpy $IsWINE $R0
	
    SetOutPath $TEMP
    ${If} $IsWINE != "1"
    File "${AZBP}\Stormy.skf"
    NSIS_SkinCrafter_Plugin::skin /NOUNLOAD "$TEMP\Stormy.skf"
    Delete "$TEMP\Stormy.skf"
    ${Endif}
  StrCpy $switch_overwrite 1
  BringToFront
  System::Call "kernel32::CreateMutexA(i 0, i 0, t '$(^Name)') i .r0 ?e"
  Pop $0
  StrCmp $0 0 launch
   StrLen $0 "$(^Name)"
   IntOp $0 $0 + 1
  loop:
    FindWindow $1 '#32770' '' 0 $1
    IntCmp $1 0 +4
    System::Call "user32::GetWindowText(i r1, t .r2, i r0) i."
    StrCmp $2 "$(^Name)" 0 loop
    System::Call "user32::ShowWindow(i r1,i 9) i."       
    System::Call "user32::SetForegroundWindow(i r1) i."  
    Abort
  launch:
  !insertmacro INSTALLOPTIONS_EXTRACT "installer.ini"
  StrCpy $1 ${g1o3}
  AccessControl::GrantOnRegKey HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance" "(BU)" "FullAccess"
  AccessControl::GrantOnRegKey HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance" "(BU)" "FullAccess"
  AccessControl::GrantOnFile "$INSTDIR" "(BU)" "GenericRead + GenericWrite"
  !insertmacro SetSectionFlag ${SecArtwork} ${SF_RO}
  SetCurInstType 0
FunctionEnd

Function .onSelChange
  !insertmacro StartRadioButtons $1
    !insertmacro RadioButton ${g1o1}
    !insertmacro RadioButton ${g1o2}
    !insertmacro RadioButton ${g1o3}
    !insertmacro RadioButton ${g1o4}
  !insertmacro EndRadioButtons	 
FunctionEnd

Function .onGUIEnd
	${If} $IsWINE != "1"
	NSIS_SkinCrafter_Plugin::destroy
	Delete "$TEMP\mainbkgnd2.gif"
	Delete "$TEMP\2.gif"	
	Delete "$TEMP\screen.gif"	
	Delete "$TEMP\bombrun.gif"	
	${Endif}
FunctionEnd

Function PreFinish
   	GetDlgItem $R0 $HWNDPARENT 1028
   	CreateFont $R1 "Tahoma" 1 700
   	SendMessage $R0 ${WM_SETFONT} $R1 0
	SendMessage $R0 ${WM_SETTEXT} 0 "STR: lol"
	GetDlgItem $0 $HWNDPARENT 1028
	GetDlgItem $1 $HWNDPARENT 1256	
	ShowWindow $0 0
	ShowWindow $1 0
FunctionEnd

Function ModifyCheckboxes
   	GetDlgItem $R0 $HWNDPARENT 1028
   	CreateFont $R1 "Tahoma" 1 700
   	SendMessage $R0 ${WM_SETFONT} $R1 0
	SendMessage $R0 ${WM_SETTEXT} 0 "STR: lol"
	GetDlgItem $0 $HWNDPARENT 1028
	GetDlgItem $1 $HWNDPARENT 1256	
	ShowWindow $0 0
	ShowWindow $1 0
	
	${IfNot} ${SectionIsSelected} 1
	    SendMessage $mui.FinishPage.Run ${BM_SETCHECK} ${BST_UNCHECKED} 0
	    EnableWindow $mui.FinishPage.Run 0 
	    SendMessage $mui.FinishPage.ShowReadme ${BM_SETCHECK} ${BST_UNCHECKED} 0
	    EnableWindow $mui.FinishPage.ShowReadme 0     
	    ShowWindow $mui.FinishPage.Run 0
	    ShowWindow $mui.FinishPage.ShowReadme 0
	${EndIf}
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd
