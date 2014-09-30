@echo off
rem imagotrigger@gmail.com
echo Building art (this will take a while!)
call bmp2mdl.bat
echo Finished bmps, starting geos (this will take a while!)
call geo2mdl.bat
echo All done (phew!)