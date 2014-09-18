#Imago <imagotrigger@gmail.com>
# Stops server, replaces objects, Starts server
#  This file is for host azbuildslave

use strict;
use Win32::Process;

open (PS,"C:\\build\\pslist.exe 2>crap AllSrv |");
my $pid = 0;
while (<PS>) {
	if ($_ =~ /AllSrv\s+(\d+)/) {
		$pid = $1;
	}
}
close PS;

if ($pid != 0) {
	my $cmd = "C:\\build\\pskill 2>crap $pid";
	print "Killing AllSrv executable $pid\n";
	`$cmd`;
	sleep(5);
	my $cmd = "regsvr32 C:\\AllegBeta\\AGC.dll /u /s";
	`$cmd`;
}

my $cmd = "copy C:\\AGC.dll C:\\AllegBeta\\AGC.dll /Y";
`$cmd`;
my $cmd = "copy C:\\AllSrv.exe C:\\AllegBeta\\AllSrv.exe /Y";
`$cmd`;
my $cmd = "copy C:\\AGC.pdb C:\\AllegBeta\\AGC.pdb /Y";
`$cmd`;
my $cmd = "copy C:\\AllSrv.pdb C:\\AllegBeta\\AllSrv.pdb /Y";
`$cmd`;
my $cmd = "copy C:\\AllLobby.pdb C:\\AllegBeta\\AllLobby.pdb /Y";
`$cmd`;

my $cmd = "regsvr32 C:\\AllegBeta\\AGC.dll /s";
`$cmd`;

my $cmd = "C:\\AllegBeta\\AllSrv.exe";
print "Starting AllSrv executable\n";
my $ProcessObj = "";
Win32::Process::Create($ProcessObj,
				$cmd,
				"AllSrv",
				0,
				NORMAL_PRIORITY_CLASS|CREATE_NEW_CONSOLE,
				"C:\\AllegBeta")|| die "Failed to start AllSrv";

exit 0;


