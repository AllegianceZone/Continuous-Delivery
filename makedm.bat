@echo off
C:
copy C:\build\Allegiance\src\Pigs\PigAccts\PigAccts.ini C:\AllegBeta\PigAccts.ini /Y
cd C:\build\Allegiance\src\Pigs\Scripts
rem perl CreatePigs.pl dm
perl CreatePig.pl 1