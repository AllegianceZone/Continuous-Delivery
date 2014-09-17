rem #Imago <imagotrigger@gmail.com> Signs the build's installer

@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

signtool sign /v /s Mine /n "Allegiance Zone Development" /d "Allegiance 1.%2 Installer" /du "http://www.allegiancezone.com" /t "http://timestamp.verisign.com/scripts/timstamp.dll" C:\build\Package\%1