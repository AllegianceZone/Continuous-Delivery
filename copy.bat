copy E:\scanner\installers\artifacts\Allegiance.exe E:\alleg_build\Package\Client\Allegiance.exe /Y
copy E:\scanner\installers\artifacts\Reloader.exe E:\alleg_build\Package\Client\Reloader.exe /Y
copy E:\scanner\installers\artifacts\AllSrv.exe E:\alleg_build\Package\Server\AllSrv.exe /Y
copy E:\scanner\installers\artifacts\AllSrvUI.exe E:\alleg_build\Package\Server\AllSrvUI.exe /Y
copy E:\scanner\installers\artifacts\PigAccts.exe E:\alleg_build\Package\Server\PigAccts.exe /Y
copy E:\scanner\installers\artifacts\PigConfig.exe E:\alleg_build\Package\Server\PigConfig.exe /Y
copy E:\scanner\installers\artifacts\PigSrv.exe E:\alleg_build\Package\Server\PigSrv.exe /Y
copy E:\scanner\installers\artifacts\PigsLib.dll E:\alleg_build\Package\Server\PigsLib.dll /Y
copy E:\scanner\installers\artifacts\TCObj.dll E:\alleg_build\Package\Server\TCObj.dll /Y
copy E:\scanner\installers\artifacts\AutoUpdate.exe E:\alleg_build\Package\Server\AutoUpdate.exe /Y
copy E:\scanner\installers\artifacts\AGC.dll E:\alleg_build\Package\Server\AGC.dll /Y
copy E:\scanner\installers\artifacts\AllLobby.exe E:\alleg_build\Package\Lobby\AllLobby.exe /Y
copy E:\scanner\installers\artifacts\AllClub.exe E:\alleg_build\Package\Lobby\AllClub.exe /Y

copy E:\scanner\installers\artifacts\vcruntime140.dll E:\alleg_build\Package\redist\vcruntime140.dll /Y
copy E:\scanner\installers\artifacts\ucrtbase.dll E:\alleg_build\Package\redist\ucrtbase.dll /Y
copy E:\scanner\installers\artifacts\msvcp140.dll E:\alleg_build\Package\redist\msvcp140.dll /Y
copy E:\scanner\installers\artifacts\api-ms-* E:\alleg_build\Package\redist /Y

copy E:\alleg_build\Package\redist\* E:\alleg_build\Package\Client /Y
copy E:\alleg_build\Package\redist\* E:\alleg_build\Package\Server /Y
copy E:\alleg_build\Package\redist\* E:\alleg_build\Package\Lobby /Y

cd E:\alleg_build\Artwork
git pull "origin"
cd E:\alleg_build\Artwork_detailed
git pull "origin"
cd E:\alleg_build\Artwork_minimal
git pull "origin"

7z a -t7z E:\alleg_build\Package\Pdb_%1.7z E:\scanner\installers\artifacts\*.pdb -mx8 -m0=LZMA
7z a -t7z E:\alleg_build\Package\Client_%1.7z E:\alleg_build\Package\Client\* -x!*.pdb -xr!*.git -mx8 -m0=LZMA
7z a -t7z E:\alleg_build\Package\Server_%1.7z E:\alleg_build\Package\Server\* -x!*.pdb -xr!*.git -mx8 -m0=LZMA
7z a -t7z E:\alleg_build\Package\Lobby_%1.7z E:\alleg_build\Package\Lobby\* -x!*.pdb -xr!*.git -mx8 -m0=LZMA
7z a -t7z E:\alleg_build\Package\Music_%1.7z E:\alleg_build\Package\Music\* -x!*.pdb -xr!*.git -mx8 -m0=LZMA
7z a -t7z E:\alleg_build\Package\Tools_%1.7z E:\alleg_build\Package\Tools\* -x!*.pdb -xr!*.git -mx8 -m0=LZMA