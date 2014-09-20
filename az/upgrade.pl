#Imago <imagotrigger@gmail.com>
#Stops lobby/server, replaces objects, Starts lobby/server
#BETA
use strict;
use Win32::OLE;

my $dir = "C:\\deploy";
my $host = "AllegianceZone";
my $serverpath = "C:\\Server";
my $lobbypath = "C:\\Lobby";
my $audir = "$dir\\autoupdate";


my $sl = Win32::OLE->GetObject("WinNT://$host/AllLobby,service");
if ($sl && $sl->Status() == 4) {
	print "Stopping AllLobby service\n";	
	$sl->Stop();
	sleep(6);
}

my $gi = Win32::OLE->GetObject("WinNT://$host/gameinfod,service");
if ($gi && $gi->Status() == 4) {
	print "Stopping gameinfod service\n";	
	$gi->Stop();
	sleep(3);
}

unlink "D:\\gameinfod.json";

if ($sl && $sl->Status == 4) {
	print "Services wouldn't shut down!\n";
	exit 1;	
}

my $cmd = "expand $audir\\Game\\Server\\AGC.dll $serverpath\\AGC.dll";
system($cmd);
my $cmd = "expand $audir\\Game\\Server\\AllSrvUI.exe $serverpath\\AllSrvUI.exe";
system($cmd);
my $cmd = "expand $audir\\Game\\Server\\AllSrv.exe $serverpath\\AllSrv.exe";
system($cmd);
my $cmd = "expand $audir\\Game\\Server\\AGC.pdb $serverpath\\AGC.pdb";
system($cmd);
my $cmd = "expand $audir\\Game\\Server\\AllSrvUI.pdb $serverpath\\AllSrvUI.pdb";
system($cmd);
my $cmd = "expand $audir\\Game\\Server\\AllSrv.pdb $serverpath\\AllSrv.pdb";
system($cmd);
my $cmd = "copy $dir\\AllLobby.exe $lobbypath\\AllLobby.exe /Y";
system($cmd);
my $cmd = "copy $dir\\AllLobby.pdb $lobbypath\\AllLobby.pdb /Y";
system($cmd);
my $cmd = "copy $dir\\Microsoft.ServiceBus.dll $lobbypath\\Microsoft.ServiceBus.dll /Y";
system($cmd);
my $cmd = "copy $dir\\Microsoft.ServiceBus.xml $lobbypath\\Microsoft.ServiceBus.xml /Y";
system($cmd);
my $cmd = "copy $dir\\Microsoft.WindowsAzure.Configuration.dll $lobbypath\\Microsoft.WindowsAzure.Configuration.dll /Y";
system($cmd);
my $cmd = "copy $dir\\Microsoft.WindowsAzure.Configuration.xml $lobbypath\\Microsoft.WindowsAzure.Configuration.xml /Y";
system($cmd);
my $cmd = "copy $dir\\Newtonsoft.Json.dll $lobbypath\\Newtonsoft.Json.dll /Y";
system($cmd);
my $cmd = "copy $dir\\Newtonsoft.Json.xml $lobbypath\\Newtonsoft.Json.xml /Y";
system($cmd);
my $cmd = "regsvr32 $serverpath\\AGC.dll /u /s";
system($cmd);
my $cmd = "regsvr32 $serverpath\\AGC.dll /s";
system($cmd);


print "Starting Lobby service\n";
$gi->start();
$sl->Start();
sleep(20);

exit 0;


