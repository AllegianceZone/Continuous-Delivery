#Imago <imagotrigger@gmail.com>
# efficently watches for a folder name change to trigger a subprocess

use strict;
use Win32::ChangeNotify;

my $dir = "C:\\deploy";

my $mondir = $dir."\\notify";
my $cmd = "C:\\perl\\bin\\perl.exe ".$dir. "\\process.pl > ".$dir."\\process.log 2>&1" ;

my $WatchDir;

$WatchDir = new Win32::ChangeNotify( $mondir ,1 , FILE_NOTIFY_CHANGE_FILE_NAME);
if( ! $WatchDir )
{
    exit();
}

$WatchDir->reset();
while (1) {
	        my $Result = $WatchDir->wait( 120 * 1000 );
        	if( $Result ) {
			if (-e $mondir."\\process") {
				`$cmd`;
				#open(LOG,">".$dir."process.log");
				#open(CMD,"$cmd |");
				#while (<CMD>) {
				#	print LOG $_;
				#}
				#close CMD;
				#close LOG;
			}
         		$WatchDir->reset();
        	}
		sleep(60);
	}
$WatchDir->close();

exit 0;

__END__