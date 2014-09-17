#Imago <imagotrigger@gmail.com>
# Send a deployment cmopleted notification to TracBot

use strict;
use AnyEvent::JSONRPC::Lite::Client;

my $b = $ARGV[0];
my $c = $ARGV[1];

my $modtime = (stat("C:\\start"))[9];
my $thetime = (stat("C:\\finish"))[9];

my $duration = $thetime - $modtime;
$duration = sprintf("%u",$duration / 60);

my $msg = "b$b took $duration min. to deploy a new build. http://trac.allegiancezone.com/build/Allegiance/$b is now running on the beta lobby & server!";

my $client = AnyEvent::JSONRPC::Lite::Client->new( host => 'azforum.cloudapp.net',port => 49153);
my $res = $client->call( echo => $msg )->recv;
