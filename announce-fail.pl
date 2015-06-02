#Imago <imagotrigger@gmail.com>
# Send a ms-build.pl failure announcment to TracBot

use strict;
use AnyEvent::JSONRPC::Lite::Client;

my $b = $ARGV[0];
my $c = $ARGV[1];

my $msg = "b$b oh noes FAILED compiling $c project! See http://trac.spacetechnology.net/build/Allegiance/$b for details";

my $client = AnyEvent::JSONRPC::Lite::Client->new( host => 'azforum.cloudapp.net',port => 49153);
my $res = $client->call( echo => $msg )->recv;
