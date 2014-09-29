#Imago <imagotrigger@gmail.com>
# Send files to AZ FTP /w a ChangeNotiy folder
#  Waits for remote completion notification
#   Displays file size and md5 hex. hash of the build's Beta Allegiance.exe

use strict;
use Net::FTP;
use Digest::MD5;

open(PWD,"C:\\pass.txt");
my $pass = <PWD>;
close PWD;

print "Uploading files to AZ\n";

my $host = "allegiancezone.cloudapp.net";
my $file = "C:\\Allegiance.exe";
open(FILE, $file) or die "Can't open '$file': $!";
binmode(FILE);
my $hash = Digest::MD5->new->addfile(*FILE)->hexdigest;
close FILE;
my $size= (stat("C:\\Allegiance.exe"))[7];
my $ftp = Net::FTP->new($host, Debug => 1, Port => 21122, Timeout => 9999) or die "Cannot connect to $host $@";

    $ftp->login("deploy",$pass)
      or die "Cannot login ", $ftp->message;
       $ftp->put("C:\\build\\AZDev.cfg")
      or die "put failed ", $ftp->message;
       $ftp->put("C:\\build\\AZNoart.cfg")
      or die "put failed ", $ftp->message;      
       $ftp->put("C:\\build\\motd.mdl")
      or die "put failed ", $ftp->message; 
       $ftp->put("C:\\build\\events.mdl")
      or die "put failed ", $ftp->message;    
       $ftp->put("C:\\build\\details.mdl")
      or die "put failed ", $ftp->message;        
       $ftp->put("C:\\build\\serverlist.txt")
      or die "put failed ", $ftp->message;  
       $ftp->put("C:\\build\\Allegiance\\src\\Lobby\\zgameinfo.h")
      or die "put failed ", $ftp->message;  
       $ftp->binary;     
       $ftp->put("C:\\build\\AutoUpdate\\FileList.txt")
      or die "put failed ", $ftp->message;
       $ftp->put("C:\\build\\FileList.txt","autoupdate\\Noart\\FileList.txt")
      or die "put failed ", $ftp->message;
       $ftp->put("C:\\build\\AutoUpdate\\Game.7z")
      or die "put failed ", $ftp->message;   
       $ftp->put("C:\\build\\AutoUpdate\\Noart.7z")
      or die "put failed ", $ftp->message;         
       $ftp->put("C:\\build\\AutoUpdate\\Server.7z")
      or die "put failed ", $ftp->message; 
       $ftp->put("C:\\build\\Allegiance\\objs10\\FZRetail\\Lobby\\AllLobby.exe")
      or die "put failed ", $ftp->message;       
       $ftp->put("C:\\build\\Allegiance\\objs10\\FZRetail\\Lobby\\AllLobby.pdb")
      or die "put failed ", $ftp->message;


       $ftp->put("C:\\AutoUpdate.exe","autoupdate\\Game\\Server\\standalone\\AutoUpdate.exe")
      or die "put failed ", $ftp->message;   

	my $build = $ARGV[0];
	my $rev = $ARGV[1];

	# PRODUCTION 
      #$ftp->put("C:\\build\\Package\\Alleg_b".$build."_".$rev.".exe","install\\Alleg_b".$build."_".$rev.".exe") or die "put failed ", $ftp->message;    
      #$ftp->put("C:\\build\\Package\\Alleg_b".$build."_".$rev.".exe","install\\latest.exe") or die "put failed ", $ftp->message;    
      #$ftp->put("C:\\build\\Package\\AllegPDB_b".$build."_".$rev.".exe","install\\AllegPDB_b".$build."_".$rev.".exe") or die "put failed ", $ftp->message;    
      
      	# BETA
      $ftp->put("C:\\build\\Package\\AllegSetup_".$build.".exe","install\\AllegSetup_".$build.".exe") or die "put failed ", $ftp->message;        
      $ftp->put("C:\\build\\Package\\Minimal_".$build."7z","install\\Minimal_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Regular_".$build."7z","install\\Regular_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Hires_".$build."7z","install\\Hires_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Client_".$build."7z","install\\Client_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Server_".$build."7z","install\\Server_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Lobby_".$build."7z","install\\Lobby_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Tools_".$build."7z","install\\Tools_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Music_".$build."7z","install\\Music_".$build.".7z") or die "put failed ", $ftp->message;    
      $ftp->put("C:\\build\\Package\\Pdb_".$build."7z","install\\Pdb_".$build.".7z") or die "put failed ", $ftp->message;    
  
 print "Files uploaded OK\n";
$ftp->rename("notify/ready","notify/process") or die "notify failed ", $ftp->message;
print "Waiting for AZ to upgrade & mirror\n";
my $count = 0;
my $bfail = 0;
while (1) {
	$count++;
	my @dirs = $ftp->ls('notify');
	if ($dirs[0] eq 'notify/ready') {
		last;
	}
	sleep(30);
	if ($count > 240) {
		$bfail = 1;
		last;
	}
}

 $ftp->ascii;     
 
        $ftp->get("process.log","C:\\build\\process.log")
      or die "get log failed ", $ftp->message;      

if ($bfail) {
	print "Remote deployment process did not return to a ready state\n";
	exit 1;
} else {
	print "Finished! Here is the log:\n";
	open(LOG,"C:\\build\\process.log");
	while (<LOG>) {
		print "$host>\t".$_;
	}
	close LOG;
}

$ftp->quit();

print "Allegiance.exe - hash: $hash size: $size\n";

exit 0;