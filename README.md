Continuous-Delivery
===================

Reliable Software Releases through Build, Test, and Deployment Automation

Edgewall's Python based "Trac/Bitten" system; Specific for hosting on Microsoft Azure vm azbuildslave from C:\build


Everything except Python, the python bitten script, Perl, the Perl modules, NSIS and the NSIS plugins are included.




=======================

nsis plugins:
animgif
skincrafter
simplefc
logex
inetc
nsis7z
nsisarray
nsisurllib
md5dll
nsisos
dialogex
inetload
accesscontrol
stack

make a C:\AllegBeta\Artwork with server files (~40MB)
del .git
add <Your Python>\Scripts to PATH
install 7zip
copy slaveconf.sample.ini to slaveconf.ini and configure accordingly
ppm install File::Slurp
ppm install AnyEvent::JSONRPC::Lite
C:\pass.txt
C:\admin.txt
checkout self - git clone https://github.com/AllegianceZone/Continuous-Delivery.git Continuous-Delivery
checkout to Artworks
	git clone https://github.com/AllegianceZone/Artwork.git Artwork
	git clone -b minimal https://github.com/AllegianceZone/Artwork.git Artwork_minimal
	git clone -b detailed https://github.com/AllegianceZone/Artwork.git Artwork_detailed
copy External
checkout Allegiance
ppm install Win32::AbsPath
ppm install Spreadsheet::Read
run server.reg
ppm install File::Copy::Recursive
make an x86 folder in your allegiance checkout
agree to the sysinternal licenses that popup when pskill/etc run
install AZCA.cer to trusted root

