#Imago <imagotrigger@gmail.com>
# The subprocess from service.pl
#  Extracts and positions uploads, runs upgrade.pl
#   Sets notification folder back to ready state


use strict;
use File::Copy;

my $dir = "C:\\deploy";
my $lzma = "\"C:\\Program Files\\7-Zip\\7z.exe\"";

open(PID,$dir."\\process.pid");
my $pid = <PID>;
close(PID);
exit -1 if ($pid && $pid != $$);
open(PID,">".$dir."\\process.pid");
print PID $$;
close(PID);

copy($dir."\\AZDev.cfg",$dir."\\config\\AZ.cfg"); #<-- same thing now
copy($dir."\\AZDev.cfg",$dir."\\config\\AZDev.cfg");
copy($dir."\\FileList.txt",$dir."\\autoupdate\\Game\\FileList.txt");
copy($dir."\\serverlist.txt",$dir."\\autoupdate\\Game\\Server\\standalone\\FileList.txt");
copy($dir."\\motd.mdl",$dir."\\config\\club\\motd.mdl");	#<-- actual one used now USEAZ
copy($dir."\\motd.mdl",$dir."\\config\\beta\\motd.mdl");
copy($dir."\\events.mdl",$dir."\\config\\event\\events.mdl");
copy($dir."\\motd.mdl",$dir."\\config\\event\\details.mdl");
copy($dir."\\motd.mdl",$dir."\\config\\motd.mdl");

my $cmd = "$lzma x -y -o".$dir."\\autoupdate\\Game ".$dir."\\Game.7z";
system($cmd);
my $cmd = "$lzma x -y -o".$dir."\\autoupdate\\Game\\Server ".$dir."\\Server.7z";
system($cmd);

my $cmd = $dir."\\azure-sync.bat";
system($cmd);

print "waiting for lobby to become idle...\n";
my $cmd = "perl ".$dir."\\busy.pl";
system($cmd);


my $cmd = "perl ".$dir."\\upgrade.pl";
system($cmd);

move($dir."\\notify\\process", $dir."\\notify\\ready");
unlink $dir.'\\process.pid';
exit 0;