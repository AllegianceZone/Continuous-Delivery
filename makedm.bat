@echo off
copy %1\Allegiance\src\Pigs\PigAccts\PigAccts.ini C:\AllegBeta\PigAccts.ini /Y
cd /D %1\Allegiance\src\Pigs\Scripts
perl CreatePigs.pl dm
rem perl CreatePig.pl 1
