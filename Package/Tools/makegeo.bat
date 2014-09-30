@echo off

rem %1 base file name (no path or extention)
rem %2 mdl build action (see template if's below)
rem %3 frame number (mostly 1)
rem %4 set to 1 to skip progressive mesh and flatten convex hulls


If Not Exist %1_static.x copy %1.x %1_static.x
If not %2 == 4 xmunge -flatten %3 %1_static.x %1flat.x
if not "%4" == "1" goto makepm
:backfrompm
If %2 == 0 goto dolowtemplate
If %2 == 1 goto doregtemplate
If %2 == 2 goto dostatictemplate
If %2 == 3 goto donolodtemplate
If %2 == 4 goto dotextonly
:backfromtemplate
mdlc -optimize %1source %1
if not "%4" == "1" (goto extractpm) else (goto flatcvh)
:bounds
xmunge -bound %3 %1_bound.x %1
cvh -bound %1
:done
@echo finished %1
goto quit


:dolowtemplate
echo > %1source.mdl use "effect"; frame = ModifiableNumber(%3); object = LODGeo(ImportXFile("%1.x", frame),[ (64, ImportXFile("%1_static", frame)),(32, ImportXFile("%1_a", frame)),(8, ImportXFile("%1-low", frame)) ]);
goto :backfromtemplate

:doregtemplate
echo > %1source.mdl use "effect"; frame = ModifiableNumber(%3); object = LODGeo(ImportXFile("%1.x", frame),[ (64, ImportXFile("%1_static", frame)),(32, ImportXFile("%1_a", frame)),(8, ImportXFile("%1_b", frame)) ]);
goto :backfromtemplate

:dostatictemplate
echo > %1source.mdl use "effect"; frame = ModifiableNumber(%3); object = LODGeo(ImportXFile("%1.x", frame),[ (64, ImportXFile("%1_static", frame)) ]);
goto :backfromtemplate

:donolodtemplate
echo > %1source.mdl use "effect"; frame = ModifiableNumber(%3); object = ImportXFile("%1.x", frame);
goto :backfromtemplate

:dotextonly
if %1 == lens (mdlc %1text %1.mdl) else (mdlc -optimize %1text %1)
goto :done

:makepm
call convpm %1flat
xmunge -reduce 0.5   %1flat_pm.x %1_a.x
xmunge -reduce 0.01  %1flat_pm.x %1_b.x
goto :backfrompm

:extractpm
xmunge -extract %3 %1.x %1
If Exist %1_bound.x goto bounds
cvh -extract %1
goto done

:flatcvh
cvh -flatten %1
goto :done


:quit