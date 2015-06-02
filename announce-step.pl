#Imago <imagotrigger@gmail.com>
# Send a step completed announcment to TracBot

use strict;
use AnyEvent::JSONRPC::Lite::Client;

my $b = $ARGV[0];
my $c = $ARGV[1];
my $step= $ARGV[2];
my $msg; my $duration;

if ($step) {
my $modtime = (stat("C:\\stepstart"))[9];
my $thetime = (stat("C:\\stepend"))[9];

$duration = $thetime - $modtime;
if ($duration >= 60) {
	$duration = sprintf("%u",$duration / 60);
	if ($duration == 1) {
		$duration = $duration." minute";
	} else {
		$duration = $duration." minutes";
	}
} else {
	$duration = sprintf("%u",$duration);
	if ($duration == 1) {
		$duration = $duration." second";
	} else {
		$duration = $duration." seconds";
	}	
}
}
my $open = 'stepstart';
open(TOUCH,">C:\\$open");
print "\n";
close TOUCH;

if ($step)  {
	$msg = "b$b Om nom nom took $duration - $step";
} else {
	$msg = "b$b Sending a slave to work on revision $c at http://trac.spacetechnology.net/build/Allegiance/$b";	
}

my $client = AnyEvent::JSONRPC::Lite::Client->new( host => 'azforum.cloudapp.net',port => 49153);
my $res = $client->call( echo => $msg )->recv;

