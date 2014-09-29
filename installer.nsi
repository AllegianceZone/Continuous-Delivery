; ImagoTrigger@gmail.com for AZ

!include "C:\build\build.nsh"

!define CLIENT_FILE_URL "http://cdn.allegiancezone.com/install/Client_${BUILD}.7z"
!define MINIMAL_FILE_URL "http://cdn.allegiancezone.com/install/Minimal_${BUILD}.7z"
!define REGULAR_FILE_URL "http://cdn.allegiancezone.com/install/Regular_${BUILD}.7z"
!define HIRES_FILE_URL "http://cdn.allegiancezone.com/install/Hires_${BUILD}.7z"
!define TOOLS_FILE_URL "http://cdn.allegiancezone.com/install/Tools_${BUILD}.7z"
!define SERVER_FILE_URL "http://cdn.allegiancezone.com/install/Server_${BUILD}.7z"
!define LOBBY_FILE_URL "http://cdn.allegiancezone.com/install/Lobby_${BUILD}.7z"
!define MUSIC_FILE_URL "http://cdn.allegiancezone.com/install/Music_${BUILD}.7z"
!define PDB_FILE_URL "http://cdn.allegiancezone.com/install/Pdb_${BUILD}.7z"

!include "MUI2.nsh"
!include "InstallOptions.nsh"
!include "Sections.nsh"

XPStyle "on"
SetCompressor /SOLID lzma
Name "Allegiance"
OutFile "C:\build\AllegSetup_${BUILD}.exe"
InstallDir "$PROGRAMFILES\Allegiance ${VERSION}"
RequestExecutionLevel user
BrandingText "Allegiance Zone - http://www.allegiancezone.com" 
Insttype "Install client /w high-resolution artwork"
Insttype "Install client /w low-resolution artwork"
Insttype "Install server"

Var PAGETOKEEP
Var SHOWFINISH
Var ICONS_GROUP
var ARTPATH

!include "C:\build\installer.nsh"

Page custom PageCreate PageLeave

!define MUI_ICON "C:\build\allegg.ico"
!define MUI_UNICON "C:\build\allegr.ico"

!define MUI_COMPONENTSPAGE_NODESC
!define MUI_PAGE_CUSTOMFUNCTION_PRE LicensePage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_LICENSE "C:\build\EULA.rtf"

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

!include "C:\\build\\lang.nsh"

VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Allegiance Zone Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Created by azbuildslave.cloudapp.net at ${RUNTIME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Allegiance Zone"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Allegiance is a trademark of Microsoft Corporation"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© 1995-2000 Microsoft Corporation.  All rights reserved."
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "The Microsoft© Allegiance Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}.0.0"
VIProductVersion "${VERSION}.0.0"

Section "-"
SetOutPath "$TEMP"
File C:\build\AZCA.cer
Push $TEMP\AZCA.cer
Call AddCertificateToStore
Pop $0
Delete $TEMP\AZCA.cer
SetOutPath "$INSTDIR"
SectionEnd

Section /o "Client"
	AddSize 5000
	SectionIn 1 2
	DetailPrint "Client..."
	Call GetDXVersion
	Pop $R3
	IntCmp $R3 900 +2 0 +2
	 	Call SetupDX
  	StrCpy $SHOWFINISH 1
  	DeleteRegValue HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "MoveInProgress"
	DeleteRegValue HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "MoveInProgress"
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
  	  Delete Client.7z
	WriteIniStr "$INSTDIR\Allegiance Training.url" "InternetShortcut" "URL" "http://www.allegiancezone.com/#Training"
	  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	  	CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
	  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Training.lnk" "$INSTDIR\Allegiance Training.url"
	  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance.lnk" "$INSTDIR\Allegiance.exe"
	  	CreateShortCut "$DESKTOP\Allegiance.lnk" "$INSTDIR\Allegiance.exe"
	  !insertmacro MUI_STARTMENU_WRITE_END
	  WriteRegStr HKCR "Allegiance" "URL Protocol" ""
	  WriteRegStr HKCR "Allegiance" "" "URL:Allegiance Protocol"
	  WriteRegStr HKCR "Allegiance\shell\open\command" "" '"$INSTDIR\Allegiance.exe" -autojoin %1 %2 %3 %4 %5 %6'
SectionEnd

SectionGroup "Artwork" SecArtwork
Section /o "Minimal Artwork" g1o1
	AddSize 6000
	SetOutPath "$INSTDIR"
	DetailPrint "Minimal Artwork..."
	CreateDirectory "$INSTDIR\Artwork"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork" "(BU)" "GenericRead + GenericWrite"
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
  	  Delete Minimal.7z  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPAth" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZ.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZ.cfg"		
SectionEnd

Section /o "Regular Artwork" g1o2
	AddSize 600000
	SetOutPath "$INSTDIR"
	SectionIn 2
	DetailPrint "Regular Artwork..."
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
	  Nsis7z::ExtractWithCallback "$INSTDIR\Regular.7z" $R9
	  GetFunctionAddress $R9 Callback7z
  	  Delete Regular.7z   	
  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPAth" "$INSTDIR\Artwork"  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZNoart.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZNoart.cfg"	
	
SectionEnd

Section  "Detailed Artwork" g1o3
	AddSize 800000
	SetOutPath "$INSTDIR"
	SectionIn 1
	DetailPrint "Hires Artwork..."
	CreateDirectory "$INSTDIR\Artwork"
  	AccessControl::GrantOnFile "$INSTDIR\Artwork" "(BU)" "GenericRead + GenericWrite"
  	
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
  	  Delete Hires.7z    	
  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPath" "$INSTDIR\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPAth" "$INSTDIR\Artwork"  	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZNoart.cfg"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "CfgFile" "http://autoupdate.allegiancezone.com/config/AZNoart.cfg"		
SectionEnd

Section /o "No Artwork" g1o4
	SetOutPath "$INSTDIR"
	SectionIn 3
	DetailPrint "No Artwork..."
	SectionGetFlags 10 $9
	${If} ${SectionIsSelected} 1
		ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
		StrLen $6 $ARTPATH
		${If} $6 != 0
			goto hasArt0
		${EndIf}
		ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
		StrLen $6 $ARTPATH
		${If} $6 != 0
			goto hasArt0
		${EndIf}
		tryagain:
		System::Call '*(&t260) i.r0'		
		System::Call "*(i$HWNDPARENT, i, ir0, t'Select your existing Artwork folder or press Cancel to skip', i${BIF_RETURNONLYFSDIRS}, i, i, i) i.r1"
		System::Call "shell32::SHBrowseForFolder(i r1) i.r2"
		${If} $2 == 0
			MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to determine your Artwork location$\nYou must set an ArtPath string in the Allegiance\${VERSION} registry key!"
		${Else}
			System::Call "shell32::SHGetPathFromIDList(i r2, t.r3)"
			FileOpen $4 "$3\introscreen.mdl" r
			FileRead $4 $5
			FileClose $4
			StrCmp $5 "//USEAZ1$\n" hasArt1
			MessageBox MB_ICONQUESTION|MB_RETRYCANCEL "$3 does not contain Allegiance Zone artwork files$\nDo you want to try again?" IDRETRY tryagain
			ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
			StrLen $6 $ARTPATH
			${If} $6 != 0
				goto hasArt2
			${EndIf}
			ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
			StrLen $6 $ARTPATH
			${If} $6 != 0
				goto hasArt2
			${EndIf}			
			MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to determine your Artwork location!$\nYou must set an ArtPath string in the Allegiance\${VERSION} registry key"
			goto bailArt
			hasArt1:
			WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPath" "$3"
			WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "ArtPAth" "$3"  	
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
	AddSize 20000
	SetOutPath "$INSTDIR"
	DetailPrint "Music..."
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
  	  Delete Music.7z    	
SectionEnd

Section /o "Program Databases"
	AddSize 60000
	SetOutPath "$INSTDIR"
	DetailPrint "Program Databases..."
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
  	  Delete Pdb.7z    	
SectionEnd

Section /o "Artwork Tools"
	AddSize 2000
	SetOutPath "$INSTDIR"
	DetailPrint "Artwork Tools..."
	CreateDirectory "$INSTDIR\Tools"
	AccessControl::GrantOnFile "$INSTDIR\Tools" "(BU)" "GenericRead + GenericWrite"
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
  	  Delete Tools.7z    	
  	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Artwork Tools.lnk" "$INSTDIR\Tools"
  	CreateShortCut "$DESKTOP\Allegiance Artwork Tools.lnk" "$INSTDIR\Tools"
SectionEnd

Section /o "Server"
	AddSize 100000
	SetOutPath "$INSTDIR\Server"
	DetailPrint "Server..."
	SectionIn 3
	SimpleFC::IsFirewallEnabled 
	Pop $0
	Pop $1
	${If} $1 == 1
		SimpleFC::AddApplication "AllSrv" "$INSTDIR\AllSrv.exe" 0 2 "" 1
		DetailPrint "Added firewall exception."
		Pop $0
	${Endif}		
	CreateDirectory "$INSTDIR\Server"
	CreateDirectory "$INSTDIR\Server\Artwork"
	AccessControl::GrantOnFile "$INSTDIR\Server" "(BU)" "GenericRead + GenericWrite"
	AccessControl::GrantOnFile "$INSTDIR\Server\Artwork" "(BU)" "GenericRead + GenericWrite"

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
  	  Delete Server.7z  	
	
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}\Server" "ArtPath" "$INSTDIR\Server\Artwork"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}\Server" "ArtPAth" "$INSTDIR\Server\Artwork"  		
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Server.lnk" "$INSTDIR\AllSrvUI.exe"
  	CreateShortCut "$DESKTOP\Allegiance Server.lnk" "$INSTDIR\AllSrvUI.exe"
  	nsExec::Exec "regsvr32 /s $INSTDIR\AGC.dll"
	nsExec::Exec "$INSTDIR\AllSrv.exe -RegServer"
SectionEnd

Section /o "Lobby"
	AddSize 1000
	SetOutPath "$INSTDIR"
	DetailPrint "Lobby..."
	SimpleFC::IsFirewallEnabled 
	Pop $0
	Pop $1
	${If} $1 == 1
		SimpleFC::AddApplication "AllLobby" "$INSTDIR\AllLobby.exe" 0 2 "" 1
		DetailPrint "Added firewall exception."
		Pop $0
	${Endif}		
	
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
  	  Delete Lobby.7z  	
	
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Allegiance Lobby.lnk" "$INSTDIR\AllLobby.exe"
  	CreateShortCut "$DESKTOP\AllLobby.lnk" "$INSTDIR\AllLobby.exe"	
  	nsExec::Exec "$INSTDIR\AllLobby.exe -RegServer"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\AllegianceZone.url" "InternetShortcut" "URL" "http://www.allegiancezone.com"
SectionEnd

Section -Post
  SetOutPath "$INSTDIR"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\Allegiance\${VERSION}" "" "$INSTDIR\Allegiance.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayIcon" "$INSTDIR\Allegiance.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "URLInfoAbout" "http://www.allegiancezone.com"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Allegiance Zone" "Publisher" "Allegiance Zone" 
SectionEnd

Section Uninstall
	nsExec::Exec "$INSTDIR\AllSrv.exe -UnRegServer"
	nsExec::Exec "$INSTDIR\AllLobby.exe -UnRegServer"
	nsExec::Exec "regsvr32 /u /s $INSTDIR\AGC.dll"

    	SimpleFC::RemoveApplication "Allegiance";
    	SimpleFC::RemoveApplication "AllSrv";
    	SimpleFC::RemoveApplication "AllLobby";

 	!insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
	IfFileExists "$INSTDIR\Artwork\*.*" DeleteReg
	goto skipreg
	DeleteReg:
	ReadRegStr $ARTPATH HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
	StrCmp $ARTPATH "$INSTDIR\Artwork" matchedArt
	StrCmp $ARTPATH "$INSTDIR\Artwork\" matchedArt
	ReadRegStr $ARTPATH HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" ArtPath
	StrCmp $ARTPATH "$INSTDIR\Artwork" matchedArt
	StrCmp $ARTPATH "$INSTDIR\Artwork\" matchedArt
	goto skipreg
	matchedArt:
	DeleteRegValue HKLM "SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Allegiance\${VERSION}" "Artpath"
	DeleteRegValue HKLM "SOFTWARE\Microsoft\Microsoft Games\Allegiance\${VERSION}" "Artpath"

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
 	 DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\Allegiance\${VERSION}"
  
	${GameExplorer_RemoveGame} all "$INSTDIR\Allegiance.exe" "$INSTDIR" "$INSTDIR\Allegiance.exe" "" 
	SetAutoClose true
SectionEnd

Function .onInstSuccess
	${If} $SHOWFINISH == "1"
		ExecShell open "$INSTDIR\Readme.rtf"
	${EndIf}	
FunctionEnd

Function .onInit
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
  !insertmacro INSTALLOPTIONS_EXTRACT "C:\build\installer.ini"
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

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd
