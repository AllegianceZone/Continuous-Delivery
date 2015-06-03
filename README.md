Continuous-Delivery
===================

Reliable Software Releases through Build, Test, and Deployment Automation

Edgewall's Python based "Trac/Bitten" system; Specific for hosting on Microsoft Azure vm azbuildslave from C:\build


Everything except Python, the python bitten script, Perl, the Perl modules, NSIS and the NSIS plugins are included.



===================
```
HOWTO to setup an az build slave...

STEP 1 - install the following:
	1. visual studio
	2. directx sdk
	3. git
		3a. http://git-scm.com - be sure to select "Use from Windows command prompt"
	4. nsis
		4a. plugins:
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
	5. python
		5a. win32svn (for setuptools)
		5b. windows bitten script - execute: easy_install http://svn.edgewall.org/repos/bitten/trunk/
		5c. add <Your Python>\Scripts to PATH environment variable
	6. perl
		6a. perl modules:
			ppm install File::Slurp
			ppm install AnyEvent::JSONRPC::Lite	
			ppm install Win32::AbsPath
			ppm install Spreadsheet::Read
			ppm install File::Copy::Recursive
	7. 7-zip
		
STEP 2 - git clone https://github.com/AllegianceZone/Continuous-Delivery.git build
	1. go into the build folder
		1a. delete the .git subfolder
		2a. clone again, execute: git clone https://github.com/AllegianceZone/Continuous-Delivery.git Continuous-Delivery
		3a. git clone https://github.com/AllegianceZone/Allegiance.git Allegiance
		3b. make an x86 folder in your Allegiance subfolder
		4a. go back up to root of build folder and get the artwork:
			git clone https://github.com/AllegianceZone/Artwork.git Artwork
			git clone -b minimal https://github.com/AllegianceZone/Artwork.git Artwork_minimal
			git clone -b detailed https://github.com/AllegianceZone/Artwork.git Artwork_detailed

STEP 3 - post your az trac username (http://allegiancezone.com/trac) and windows computer name of slave to http://allegiancezone.com/forum

STEP 4 - look for a reply
	1. wait untill `build admin` permissions are added to your az trac account and you are given the code signing certificate, private key and password files

STEP 5 - install cert and password files
	1. from the directory you cloned in STEP 2 execute the following:
	     certutil -user -addstore Root AZCA.cer
	     makecert -pe -n "CN=Allegiance Zone Development" -a sha256 -cy end -ss Mine -sky signature -ic AZCA.cer -iv AZCA.pvk -sv MySPC.pvk MySPC.cer
	2. Copy the admin.txt and pass.txt files from STEP 4 to the root of the C:\ drive
	
STEP 6 - make a C:\AllegBeta\Artwork with minimum server files (~40MB simply copy Artwork_minimal and the cvh, txt and igcs from Artwork)
	1. run server.reg

STEP 7 - copy slaveconf.sample.ini to slaveconf.ini and configure accordingly

STEP 8 - execute run_bitten_slave.bat
	1. agree to the sysinternal licenses that popup when pskill/etc utilities run for the first time


Your machine will now automaticaly publish a build and run/update a server with bots when https://github.com/AllegianceZone/Allegiance gets pushed
```
