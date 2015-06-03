rem #Imago <imagotrigger@gmail.com> Signs the build's installer

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

signtool sign /v /a /s Mine /n "Allegiance Zone Development" /d "Allegiance 1.%2 Installer" /du "http://www.allegiancezone.com" /t "http://timestamp.verisign.com/scripts/timstamp.dll" %3\Package\%1
