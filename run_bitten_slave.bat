@echo off
rem #Imago <imagotrigger@gmail.com> - Runs the bitten slave "dameon"

:wut
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

call bitten-slave -f slaveconf.ini --log=bitten.log http://trac.spacetechnology.net/builds
goto wut
