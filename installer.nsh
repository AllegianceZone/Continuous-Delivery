!include 'FileFunc.nsh'
!insertmacro Locate
Var switch_overwrite
;==================
; MoveFile macro
;==================

!macro MoveFile sourceFile destinationFile

!define MOVEFILE_JUMP ${__LINE__}

; Check source actually exists

    IfFileExists "${sourceFile}" +3 0
    SetErrors
    goto done_${MOVEFILE_JUMP}

; Add message to details-view/install-log

    DetailPrint "Moving/renaming file: ${sourceFile} to ${destinationFile}"

; If destination does not already exists simply move file

    IfFileExists "${destinationFile}" +3 0
    rename "${sourceFile}" "${destinationFile}"
    goto done_${MOVEFILE_JUMP}

; If overwriting without 'ifnewer' check

    ${If} $switch_overwrite == 1
	delete "${destinationFile}"
	rename "${sourceFile}" "${destinationFile}"
	delete "${sourceFile}"
	goto done_${MOVEFILE_JUMP}
    ${EndIf}

; If destination already exists

    Push $R0
    Push $R1
    Push $R2
    push $R3

    GetFileTime "${sourceFile}" $R0 $R1
    GetFileTime "${destinationFile}" $R2 $R3

    IntCmp $R0 $R2 0 older_${MOVEFILE_JUMP} newer_${MOVEFILE_JUMP}
    IntCmp $R1 $R3 older_${MOVEFILE_JUMP} older_${MOVEFILE_JUMP} newer_${MOVEFILE_JUMP}

    older_${MOVEFILE_JUMP}:
    delete "${sourceFile}"
    goto time_check_done_${MOVEFILE_JUMP}

    newer_${MOVEFILE_JUMP}:
    delete "${destinationFile}"
    rename "${sourceFile}" "${destinationFile}"
    delete "${sourceFile}" ;incase above failed!

    time_check_done_${MOVEFILE_JUMP}:

    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0

done_${MOVEFILE_JUMP}:

!undef MOVEFILE_JUMP

!macroend

!macro IfKeyExists ROOT MAIN_KEY KEY
  Push $R0
  Push $R1
  Push $R2
 
  # XXX bug if ${ROOT}, ${MAIN_KEY} or ${KEY} use $R0 or $R1
 
  StrCpy $R1 "0" # loop index
  StrCpy $R2 "0" # not found
 
  ${Do}
    EnumRegKey $R0 ${ROOT} "${MAIN_KEY}" "$R1"
    ${If} $R0 == "${KEY}"
      StrCpy $R2 "1" # found
      ${Break}
    ${EndIf}
    IntOp $R1 $R1 + 1
  ${LoopWhile} $R0 != ""
 
  ClearErrors
 
  Exch 2
  Pop $R0
  Pop $R1
  Exch $R2
!macroend


Function FileSizeNew 
  Exch $0
  Push $1
  FileOpen $1 $0 "r"
  FileSeek $1 0 END $0
  FileClose $1
  Pop $1
  Exch $0
FunctionEnd

!define BIF_RETURNONLYFSDIRS 0x00000001

!macro GetCleanDir INPUTDIR
  !define Index_GetCleanDir 'GetCleanDir_Line${__LINE__}'
  Push $R0
  Push $R1
  StrCpy $R0 "${INPUTDIR}"
  StrCmp $R0 "" ${Index_GetCleanDir}-finish
  StrCpy $R1 "$R0" "" -1
  StrCmp "$R1" "\" ${Index_GetCleanDir}-finish
  StrCpy $R0 "$R0\"
${Index_GetCleanDir}-finish:
  Pop $R1
  Exch $R0
  !undef Index_GetCleanDir
!macroend

!macro RemoveFilesAndSubDirs DIRECTORY
  !define Index_RemoveFilesAndSubDirs 'RemoveFilesAndSubDirs_${__LINE__}'
   Push $R0
  Push $R1
  Push $R2
   !insertmacro GetCleanDir "${DIRECTORY}"
  Pop $R2
  FindFirst $R0 $R1 "$R2*.*"
${Index_RemoveFilesAndSubDirs}-loop:
  StrCmp $R1 "" ${Index_RemoveFilesAndSubDirs}-done
  StrCmp $R1 "." ${Index_RemoveFilesAndSubDirs}-next
  StrCmp $R1 ".." ${Index_RemoveFilesAndSubDirs}-next
  IfFileExists "$R2$R1\*.*" ${Index_RemoveFilesAndSubDirs}-directory
  ; file
  Delete "$R2$R1"
  goto ${Index_RemoveFilesAndSubDirs}-next
${Index_RemoveFilesAndSubDirs}-directory:
  ; directory
  RMDir /r "$R2$R1"
${Index_RemoveFilesAndSubDirs}-next:
  FindNext $R0 $R1
  Goto ${Index_RemoveFilesAndSubDirs}-loop
${Index_RemoveFilesAndSubDirs}-done:
  FindClose $R0
  Pop $R2
  Pop $R1
  Pop $R0
  !undef Index_RemoveFilesAndSubDirs
!macroend

Function Callback7z
  Pop $R8
  Pop $R9
  SetDetailsPrint textonly
  DetailPrint "Installing $R8 / $R9..."
  SetDetailsPrint both
FunctionEnd

!macro SendDlgItemMessage DLG ITEM MSG WPARAM LPARAM
  Push $R0
  GetDlgItem $R0 ${DLG} ${ITEM}
  SendMessage $R0 ${MSG} ${WPARAM} ${LPARAM}
  Pop $R0
!macroend

Function PageCreate
  !insertmacro MUI_HEADER_TEXT "$(READYPAGE_TITLE)" "$(READYPAGE_SUBTITLE)"
  !insertmacro INSTALLOPTIONS_DISPLAY "installer.ini"
FunctionEnd

Function PageLeave
  !insertmacro INSTALLOPTIONS_READ $R0 "installer.ini" "Settings" "State"
  ${Select} $R0
    ${Case} 0
      StrCpy $PAGETOKEEP "none"
    ${Case} 1
      StrCpy $PAGETOKEEP "license"
    ${Case} 3
      StrCpy $PAGETOKEEP "directory"
      SendMessage $HWNDPARENT 0x408 2 0
    ${Case} 5
      StrCpy $PAGETOKEEP "components"
      SendMessage $HWNDPARENT 0x408 3 0
    ${Case} 7
      StrCpy $PAGETOKEEP "startmenu"
      SendMessage $HWNDPARENT 0x408 4 0      
    ${Default}
      Abort
  ${EndSelect}
FunctionEnd

Function CommonPage_Show
  ${If} $PAGETOKEEP != "license"
    GetDlgItem $R0 $HWNDPARENT 1
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:OK"
  ${EndIf}
FunctionEnd

Function CommonPage_Leave
  SendMessage $HWNDPARENT ${WM_COMMAND} 3 0
  Abort
FunctionEnd

Function LicensePage_Pre
  Push "license"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

Function DirectoryPage_Pre
  Push "directory"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

Function ComponentsPage_Pre
  Push "components"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

Function StartMenuPage_Pre
  Push "startmenu"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

; Push textual page id and it returns 1 if the page should be skipped
Function ShouldSkipPage
  Exch $R0
  ${If} $PAGETOKEEP == $R0
    StrCpy $R0 0
  ${Else}
    StrCpy $R0 1
  ${EndIf}
  Exch $R0
FunctionEnd

Function GetDXVersion
	Push $0
	Push $1

	ClearErrors
	ReadRegStr $0 HKLM "Software\Microsoft\DirectX" "Version"
	IfErrors noDirectX

	StrCpy $1 $0 2 5    ; get the minor version
	StrCpy $0 $0 2 2    ; get the major version
	IntOp $0 $0 * 100   ; $0 = major * 100 + minor
	IntOp $0 $0 + $1
	Goto done

	noDirectX:
	StrCpy $0 0

	done:
	Pop $1
	Exch $0
FunctionEnd

Function SetupDX
	DetailPrint "DX Setup..."
	SetOutPath "$TEMP"
	ExecWait "$TEMP\dxwebsetup.exe"
	Delete "$TEMP\dxwebsetup.exe"
	SetOutPath "$INSTDIR"
FunctionEnd

Var GameExplorer_ContextId
!define GameExplorer_AddGame "!insertmacro GameExplorer_AddGame"
!define GameExplorer_AddPlayTask "!insertmacro GameExplorer_AddPlayTask"
!define GameExplorer_AddSupportTask "!insertmacro GameExplorer_AddSupportTask"
!define GameExplorer_RemoveGame "!insertmacro GameExplorer_RemoveGame"
 
!macro GameExplorer_AddGame CONTEXT GDF INSTDIR RUNPATH RUNARGS SAVEGAMEEXT
  DetailPrint "GameExplorer_AddGame..."
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  SetOutPath $PLUGINSDIR
  !ifndef GAME_EXPLORER_DLL_EXISTS
    !ifdef GAME_EXPLORER_HELPER_PATH
      File "/oname=GameuxInstallHelper.dll" "${GAME_EXPLORER_HELPER_PATH}"
    !else
     File "GameuxInstallHelper.dll"
    !endif
    !define GAME_EXPLORER_DLL_EXISTS
  !endif
  !if "${CONTEXT}" == "current"
    StrCpy $GameExplorer_ContextId 2
  !else if  "${CONTEXT}" == "all"
    StrCpy $GameExplorer_ContextId 3
  !else
    !error 'Context must be "current" or "all"'
  !endif
  System::Call 'GameuxInstallHelper::GenerateGUID(g .r0)'
  !ifndef GAME_EXPLORER_GUID_DECLARED
    Var /GLOBAL GameExplorer_GUID
    !define GAME_EXPLORER_GUID_DECLARED
  !endif
  ${If} $0 != "{00000000-0000-0000-0000-000000000000}"
    StrCpy $GameExplorer_GUID $0
    StrCpy $1 "${GDF}"
    StrCpy $2 "${INSTDIR}"
    System::Call "GameuxInstallHelper::AddToGameExplorerA(t r1, t r2, i $GameExplorer_ContextId, g r0)"
    StrCpy $3 "${RUNPATH}"
    StrCpy $4 "${RUNARGS}"
    !ifndef GAME_EXPLORER_PLAYTASK_NUM_DECLARED
      Var /GLOBAL GameExplorer_PlaytaskNum
      !define GAME_EXPLORER_PLAYTASK_NUM_DECLARED
    !endif
    StrCpy $GameExplorer_PlaytaskNum 0
    !ifndef GAME_EXPLORER_SUPPORTTASK_NUM_DECLARED
      Var /GLOBAL GameExplorer_SupporttaskNum
      !define GAME_EXPLORER_SUPPORTTASK_NUM_DECLARED
    !endif
    StrCpy $GameExplorer_SupporttaskNum 0
    System::Call "GameuxInstallHelper::RegisterWithMediaCenterA(t r1, t r2, i $GameExplorer_ContextId, t r3, t r4, i 1)" 
    !if "${SAVEGAMEEXT}" != ""
      StrCpy $2 "${SAVEGAMEEXT}"
      !if "${RUNARGS}" != ""
        StrCpy $4 "${RUNARGS} $\"%1$\""
      !else
        StrCpy $4 '"%1"'
      !endif
      System::Call "GameuxInstallHelper::SetupRichSavedGamesA(t r2, t r3, t r4)"
    !endif
  ${EndIf}
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
!macroend
 
!macro GameExplorer_AddPlayTask TASKNAME RUNPATH RUNARGS
  Push $0
  Push $1
  Push $2
  StrCpy $0 "${TASKNAME}"
  StrCpy $1 "${RUNPATH}"
  StrCpy $2 "${RUNARGS}"
  !ifndef GAME_EXPLORER_GUID_DECLARED
    Var /GLOBAL GameExplorer_GUID
    !define GAME_EXPLORER_GUID_DECLARED
  !endif
  !ifndef GAME_EXPLORER_PLAYTASK_NUM_DECLARED
    Var /GLOBAL GameExplorer_PlaytaskNum
    !define GAME_EXPLORER_PLAYTASK_NUM_DECLARED
  !endif
  System::Call "GameuxInstallHelper::CreateTaskA(i $GameExplorer_ContextId, g '$GameExplorer_GUID', i 0, i $GameExplorer_PlaytaskNum, t r0, t r1, t r2)"
  IntOp $GameExplorer_PlaytaskNum $GameExplorer_PlaytaskNum + 1
  Pop $2
  Pop $1
  Pop $0
!macroend
 
!macro GameExplorer_AddSupportTask TASKNAME SUPPORTPATH
  Push $0
  Push $1
  StrCpy $0 "${TASKNAME}"
  StrCpy $1 "${SUPPORTPATH}"
  !ifndef GAME_EXPLORER_GUID_DECLARED
    Var /GLOBAL GameExplorer_GUID
    !define GAME_EXPLORER_GUID_DECLARED
  !endif
  !ifndef GAME_EXPLORER_SUPPORTTASK_NUM_DECLARED
    Var /GLOBAL GameExplorer_SupporttaskNum
    !define GAME_EXPLORER_SUPPORTTASK_NUM_DECLARED
  !endif
  System::Call "GameuxInstallHelper::CreateTaskA(i $GameExplorer_ContextId, g '$GameExplorer_GUID', i 0, i $GameExplorer_SupporttaskNum, t r0, t r1, '')"
  IntOp $GameExplorer_SupporttaskNum $GameExplorer_SupporttaskNum + 1
  Pop $1
  Pop $0
!macroend
 
!macro GameExplorer_RemoveGame CONTEXT GDF INSTDIR RUNPATH SAVEGAMEEXT
  Push $0
  Push $1
  Push $2
  Push $3
  !if "${CONTEXT}" == "current"
    StrCpy $GameExplorer_ContextId 2
  !else if  "${CONTEXT}" == "all"
    StrCpy $GameExplorer_ContextId 3
  !else
    !error 'Context must be "current" or "all"'
  !endif
  SetOutPath $PLUGINSDIR
  !ifndef UNGAME_EXPLORER_DLL_EXISTS
    !ifdef GAME_EXPLORER_HELPER_PATH
      File "/oname=GameuxInstallHelper.dll" "${GAME_EXPLORER_HELPER_PATH}"
    !else
      File "GameuxInstallHelper.dll"
    !endif
    !define UNGAME_EXPLORER_DLL_EXISTS
  !endif
  StrCpy $1 "${GDF}"
  System::Call "GameuxInstallHelper::RetrieveGUIDForApplicationA(t r1, g .r0)"
  System::Call "GameuxInstallHelper::RemoveTasks(g r0)"
  System::Call "GameuxInstallHelper::RemoveFromGameExplorer(g r0)"
  StrCpy $2 "${INSTDIR}"
  StrCpy $3 "${RUNPATH}"
  System::Call "GameuxInstallHelper::UnRegisterWithMediaCenterA(t r2, i $GameExplorer_ContextId, t r3, i 0)"
  !if "${SAVEGAMEEXT}" != ""
    StrCpy $2 "${SAVEGAMEEXT}"
    System::Call "GameuxInstallHelper::RemoveRichSavedGamesA(t r2)"
  !endif
  Pop $3
  Pop $2
  Pop $1
  Pop $0
!macroend

!define CERT_QUERY_OBJECT_FILE 1
!define CERT_QUERY_CONTENT_FLAG_ALL 16382
!define CERT_QUERY_FORMAT_FLAG_ALL 14
!define CERT_STORE_PROV_SYSTEM 10
!define CERT_STORE_OPEN_EXISTING_FLAG 0x4000
!define CERT_SYSTEM_STORE_LOCAL_MACHINE 0x20000
!define CERT_STORE_ADD_ALWAYS 4

Function AddCertificateToStore
  Exch $0
  Push $1
  Push $R0
  System::Call "crypt32::CryptQueryObject(i ${CERT_QUERY_OBJECT_FILE}, w r0, i ${CERT_QUERY_CONTENT_FLAG_ALL}, i ${CERT_QUERY_FORMAT_FLAG_ALL}, i 0, i 0, i 0, i 0, i 0, i 0, *i .r0) i .R0"
  ${If} $R0 <> 0
    System::Call "crypt32::CertOpenStore(i ${CERT_STORE_PROV_SYSTEM}, i 0, i 0, i ${CERT_STORE_OPEN_EXISTING_FLAG}|${CERT_SYSTEM_STORE_LOCAL_MACHINE}, w 'ROOT') i .r1"
    ${If} $1 <> 0
      System::Call "crypt32::CertAddCertificateContextToStore(i r1, i r0,i ${CERT_STORE_ADD_ALWAYS}, i 0) i .R0"
      System::Call "crypt32::CertFreeCertificateContext(i r0)"
      ${If} $R0 = 0
        StrCpy $0 "Unable to add certificate to certificate store"
      ${Else}
        StrCpy $0 "success"
      ${EndIf}
      System::Call "crypt32::CertCloseStore(i r1, i 0)"
    ${Else}
      System::Call "crypt32::CertFreeCertificateContext(i r0)"
      StrCpy $0 "Unable to open certificate store"
    ${EndIf}
  ${Else}
    StrCpy $0 "Unable to open certificate file"
  ${EndIf}
  Pop $R0
  Pop $1
  Exch $0
FunctionEnd

