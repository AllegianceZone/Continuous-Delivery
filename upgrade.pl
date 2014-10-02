#Imago <imagotrigger@gmail.com>
# Stops server, replaces objects, Starts server
#  This file is for host azbuildslave

use strict;
use Win32::Process;

my $cmd = "";

print "Shutting down...\n";

open (PS,"C:\\build\\pslist.exe 2>crap AllSrv |");
my $pid = 0;
while (<PS>) {
	if ($_ =~ /AllSrv\s+(\d+)/) {
		$pid = $1;
		$cmd = "C:\\build\\pskill 2>crap $pid";
		print "Killing AllSrv executable $pid\n";
		`$cmd`;		
	}
}
close PS;

sleep(5) if ($pid);

open (PS,"C:\\build\\pslist.exe 2>crap AllClub |");
$pid = 0;
while (<PS>) {
	if ($_ =~ /AllClub\s+(\d+)/) {
		$pid = $1;
		$cmd = "C:\\build\\pskill 2>crap $pid";
		print "Killing AllClub executable $pid\n";
		`$cmd`;		
	}
}
close PS;


sleep(5) if ($pid);

print "Unregistering...\n";

$cmd = "C:\\AllegBeta\\PigAccts.exe -UnRegServer";
`$cmd`;

$cmd = "C:\\AllegBeta\\PigSrv.exe -UnRegServer";
`$cmd`;

$cmd = "C:\\AllegBeta\\AllSrv.exe -UnRegServer";
`$cmd`;

$cmd = "C:\\AllegBeta\\AllClub.exe -UnRegServer";
`$cmd`;

$cmd = "regsvr32 C:\\AllegBeta\\AGC.dll /u /s";
`$cmd`;

$cmd = "regsvr32 C:\\AllegBeta\\TCObj.dll /u /s";
`$cmd`;

$cmd = "regsvr32 C:\\AllegBeta\\PigsLib.dll /u /s";
`$cmd`;

sleep(2);

print "Copying files again...\n";

$cmd = "copy C:\\AGC.dll C:\\AllegBeta\\AGC.dll /Y";
`$cmd`;
$cmd = "copy C:\\AllSrv.exe C:\\AllegBeta\\AllSrv.exe /Y";
`$cmd`;
$cmd = "copy C:\\AGC.pdb C:\\AllegBeta\\AGC.pdb /Y";
`$cmd`;
$cmd = "copy C:\\AllSrv.pdb C:\\AllegBeta\\AllSrv.pdb /Y";
`$cmd`;
$cmd = "copy C:\\AllLobby.pdb C:\\AllegBeta\\AllLobby.pdb /Y";
`$cmd`;
$cmd = "copy C:\\AutoUpdate.exe C:\\AllegBeta\\AutoUpdate.exe /Y";
`$cmd`;
$cmd = "copy C:\\PigsLib.pdb C:\\AllegBeta\\PigsLib.pdb /Y";
`$cmd`;
$cmd = "copy C:\\PigsLib.dll C:\\AllegBeta\\PigsLib.dll /Y";
`$cmd`;
$cmd = "copy C:\\AllClub.exe C:\\AllegBeta\\AllClub.exe /Y";
`$cmd`;
$cmd = "copy C:\\AllClub.pdb C:\\AllegBeta\\AllClub.pdb /Y";
`$cmd`;
$cmd = "copy C:\\PigSrv.exe C:\\AllegBeta\\PigSrv.exe /Y";
`$cmd`;
$cmd = "copy C:\\PigSrv.pdb C:\\AllegBeta\\PigSrv.pdb /Y";
`$cmd`;
$cmd = "copy C:\\PigConfig.exe C:\\AllegBeta\\PigConfig.exe /Y";
`$cmd`;
$cmd = "copy C:\\PigConfig.pdb C:\\AllegBeta\\PigConfig.pdb /Y";
`$cmd`;
$cmd = "copy C:\\PigAccts.exe C:\\AllegBeta\\PigAccts.exe /Y";
`$cmd`;
$cmd = "copy C:\\PigAccts.pdb C:\\AllegBeta\\PigAccts.pdb /Y";
`$cmd`;
$cmd = "copy C:\\TCObj.pdb C:\\AllegBeta\\TCObj.pdb /Y";
`$cmd`;
$cmd = "copy C:\\TCObj.dll C:\\AllegBeta\\TCObj.dll /Y";
`$cmd`;

print "Re-registering...\n";

$cmd = "regsvr32 C:\\AllegBeta\\AGC.dll /s";
`$cmd`;

$cmd = "regsvr32 C:\\AllegBeta\\TCObj.dll /s";
`$cmd`;

$cmd = "regsvr32 C:\\AllegBeta\\PigsLib.dll /s";
`$cmd`;

$cmd = "C:\\AllegBeta\\AllSrv.exe -RegServer";
`$cmd`;

$cmd = "C:\\AllegBeta\\AllClub.exe -RegServer";
`$cmd`;

$cmd = "C:\\AllegBeta\\PigAccts.exe -RegServer pigs PigPass!";
`$cmd`;

$cmd = "C:\\AllegBeta\\PigSrv.exe -RegServer pigs PigPass!";
`$cmd`;


print "Restarting...\n";

$cmd = "C:\\AllegBeta\\AllClub.exe";
print "Starting AllClub executable\n";
my $ProcessObj = "";
Win32::Process::Create($ProcessObj,
				$cmd,
				"AllClub",
				0,
				NORMAL_PRIORITY_CLASS|CREATE_NEW_CONSOLE,
				"C:\\AllegBeta")|| die "Failed to start AllClub";

$cmd = "C:\\AllegBeta\\AllSrv.exe";
print "Starting AllSrv executable\n";
my $ProcessObj = "";
Win32::Process::Create($ProcessObj,
				$cmd,
				"AllSrv",
				0,
				NORMAL_PRIORITY_CLASS|CREATE_NEW_CONSOLE,
				"C:\\AllegBeta")|| die "Failed to start AllSrv";

exit 0;


