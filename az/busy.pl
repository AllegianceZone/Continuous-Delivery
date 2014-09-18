#Imago <imagotrigger@gmail.com
# Waits for lobby to become idle before exiting OK

use strict;
use Win32::SharedFileOpen qw(:DEFAULT $ErrStr);
use JSON;

my $Max_Time      = 10;    # Try opening the file for up to 10 seconds
my $Retry_Timeout = 500;   # Wait 500 milliseconds between each try

my $lobby = GetGameInfo();
my $numnotplaying = $lobby->{numNotPlaying};    
my $numplayers = $lobby->{numPlayers};     
if ($numplayers > $numnotplaying) {
	my $itrs = 0;
	do {
		exit 1 if ($itrs > 514); #exit ERROR after 3 hours
		$lobby = GetGameInfo();
		$numnotplaying = $lobby->{numNotPlaying};    
		$numplayers = $lobby->{numPlayers};  
		sleep(21) if ($numplayers > $numnotplaying);
		$itrs++;
	} while ($numplayers > $numnotplaying);
}
exit 0;

sub GetGameInfo {
	local $/;
	fsopen(FH, "D:\\gameinfod.json", 'r', SH_DENYNO) or die "Can't read 'gameinfod' after retrying for $Max_Time secs: $ErrStr\n";
	my $json = <FH>;
	close FH;
	return decode_json( $json );
}