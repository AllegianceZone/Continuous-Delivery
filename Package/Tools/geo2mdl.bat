FOR /F "tokens=1,3* delims=," %%G IN (geo.txt) DO call makegeo %%G
echo Lens batch error is normal (30/60/90 instead of static!)
mdlc -compressanim 4 4 animlaunchbmp animlaunch.mdl
mdlc -compressanim 4 4 animloadoutbmp animloadout.mdl
mdlc -compressanim 4 4 animradarbmp animradar.mdl
mdlc -compressanim 4 4 animinvestbmp animinvest.mdl
mdlc -compressanim 2 4 animsectorbmp animsector.mdl
mdlc -compressanim 1 3 animteambmp animteam.mdl
mdlc fontsource font.mdl