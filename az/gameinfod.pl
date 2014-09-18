#Imago <imagotrigger@gmail.com
# Lobby reports it's game info to itself, this is a daemon to deal /w it
#  Let's store the info in some swapspace

use strict;
use IO::Socket;
use Convert::Binary::C;
use Win32::SharedFileOpen qw(:DEFAULT $ErrStr);
use JSON;

my $sock = IO::Socket::INET->new(LocalPort => 2000, Proto => 'udp') or die "socket init: $@";      
my $c = new Convert::Binary::C;
my $json = JSON->new->allow_nonref;
$c->parse_file("C:\\deploy\\gameinfod.h");
$c->parse_file("C:\\deploy\\zgameinfo.h");
$c->configure(ByteOrder => 'BigEndian', LongSize  => 4, ShortSize => 2, UnsignedChars => 1,  Alignment => 4);
die "Couldn't load structure\n" if (!$c->def('ZGameServerInfoMsg'));
while (1) {
	open(LOG,">>C:\\deploy\\gameinfod.log");
	print LOG (localtime)."> Info: Listening...\n";
	close LOG;
	$sock ||= IO::Socket::INET->new(LocalPort => 2000, Proto => 'udp') or die "socket rest: $@";
	my $newmsg;
	while ($sock->recv($newmsg, 4340)) {
	    my $perl = $c->unpack('ZGameServerInfoMsg', $newmsg);
	    my %hash = %$perl;
	    my @info = @{$hash{info}};
	    my $lobby = $info[0];
		my @grd = $lobby->{gameRoomDescription}; my @grd2 = @{$grd[0]}; my $string;
		foreach (@grd2) { $string.=chr($_) } $lobby->{gameRoomDescription} = $string;
		@grd = $lobby->{gameInternalName}; @grd2 = @{$grd[0]}; my $string2;
		foreach (@grd2) { $string2.=chr($_) } $lobby->{gameInternalName} = $string2;
		@grd = $lobby->{gameFriendlyName}; @grd2 = @{$grd[0]}; my $string3;
		foreach (@grd2) { $string3.=chr($_) } $lobby->{gameFriendlyName} = $string3;
		@grd = $lobby->{setupToken}; @grd2 = @{$grd[0]}; my $string4;
		foreach (@grd2) { $string4.=chr($_) } $lobby->{setupToken} = $string4;
	    $lobby->{gameinfod} = time;
	    fsopen(MEM, "D:\\gameinfod.json", 'w', SH_DENYRW) or print LOG "Can't write 'gameinfod' and take read/write-lock: $ErrStr\n";
	    print MEM $json->pretty->encode($lobby);
	    close MEM;
	} 
	open(LOG,">C:\\deploy\\gameinfod.log");
	print LOG (localtime). "> Error: recv: $!\n";
	close LOG;
}
exit 0;