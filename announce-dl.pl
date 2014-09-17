#Imago <imagotrigger@gmail.com>
# Send a download announcment to TracBot

use strict;
use AnyEvent::JSONRPC::Lite::Client;

my $b = $ARGV[0];
my $c = $ARGV[1];
my $step= $ARGV[2];
my $msg; my $duration;

$msg = "b$b ".$step;

my $client = AnyEvent::JSONRPC::Lite::Client->new( host => 'azforum.cloudapp.net',port => 49153);
my $res = $client->call( echo => $msg )->recv;
