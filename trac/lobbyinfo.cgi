#!/usr/bin/perl

# ImagoTrigger@gmail.com
use common::sense;
use Convert::Binary::C::Cached;
use File::Slurp;
use JSON;
use CGI qw(:standard -nph);
use CGI::Carp qw (fatalsToBrowser); 
use Fcntl ':flock';

my $q = CGI->new;
print $q->header();
my $data = $q->param( 'POSTDATA' );
if (length $data < 36) {
	print read_file("lobbyinfo.json");
	exit 0;
};

my $c = new Convert::Binary::C::Cached->new(Cache => 'cache.c');
my $json = JSON->new->allow_nonref;
$c->parse_file("lobbyinfo.h");
$c->configure(Bitfields => {Engine => 'Microsoft'});
my $perl = $c->unpack('LobbyInfoMsg', $data);
my %hash = %$perl;

my $gamename = substr($data,$hash{ibszGameName},$hash{cbszGameName});
delete $hash{ibszGameName}, delete $hash{cbszGameName}, $hash{szGameName} = $gamename;
my $squadids = substr($data,$hash{ibrgSquadIDs},$hash{cbrgSquadIDs});
delete $hash{ibrgSquadIDs}, delete $hash{cbrgSquadIDs}, $hash{rgSquadIDs} = $squadids;
my $gdmfiles = substr($data,$hash{ibszGameDetailsFiles},$hash{cbszGameDetailsFiles});
delete $hash{ibszGameDetailsFiles}, delete $hash{cbszGameDetailsFiles}, $hash{szGameDetailsFiles} = $gdmfiles;
my $gdcfiles = substr($data,$hash{cbszIGCStaticFile},$hash{cbszIGCStaticFile});
delete $hash{cbszIGCStaticFile}, delete $hash{cbszIGCStaticFile}, $hash{szIGCStaticFile} = $gdcfiles;
my $servname = substr($data,$hash{ibszServerName},$hash{cbszServerName});
delete $hash{ibszServerName}, delete $hash{cbszServerName}, $hash{szServerName} = $servname;
my $servaddr = substr($data,$hash{ibszServerAddr},$hash{cbszServerAddr});
delete $hash{ibszServerAddr}, delete $hash{cbszServerAddr}, $hash{szServerAddr} = $servaddr;
my $srvadmin = substr($data,$hash{ibszPrivilegedUsers},$hash{cbszPrivilegedUsers});
delete $hash{ibszPrivilegedUsers}, delete $hash{cbszPrivilegedUsers}, $hash{szPrivilegedUsers} = $srvadmin;
my $servvers = substr($data,$hash{ibszServerVersion},$hash{cbszServerVersion});
delete $hash{ibszServerVersion}, delete $hash{cbszServerVersion}, $hash{szServerVersion} = $servvers;

$hash{lobbyinfod} = time;
my $js = $json->pretty->encode(\%hash);
open(my $MEM,'>lobbyinfo.json');
flock($MEM, LOCK_EX);
print $MEM $js;
close $MEM;

print $js;
exit 0;
