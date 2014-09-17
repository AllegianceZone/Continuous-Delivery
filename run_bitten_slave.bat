@echo off
rem #Imago <imagotrigger@gmail.com> - Runs the bitten slave "dameon"

:wut
if not defined DevEnvDir (
	call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
)
cd C:\build
call C:\Python27\Scripts\bitten-slave --log=bitten.log http://trac.allegiancezone.com/builds
goto wut