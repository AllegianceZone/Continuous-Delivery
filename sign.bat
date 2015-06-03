rem #Imago <imagotrigger@gmail.com> Signs the build's objects

@echo off
if not defined DevEnvDir (
	if defined VS100COMNTOOLS (
		call "%VS100COMNTOOLS%..\..\VC\vcvarsall.bat" x86
	)
)
if not defined DevEnvDir (
	if defined VS120COMNTOOLS (
		call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86
	)
)

signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\AllSrvUI\AllSrvUI.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\FedSrv\Allsrv.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\Reloader\Reloader.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\AutoUpdate\AutoUpdate.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\Lobby\AllLobby.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\WinTrek\Allegiance.exe
signtool sign -a -v -s Mine -n "Allegiance Zone Development" -t http://timestamp.verisign.com/scripts/timestamp.dll %2\Allegiance\%3\%1\AGC\AGC.dll
