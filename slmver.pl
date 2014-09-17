#Imago <imagotrigger@gmail.com>
# Inserts the current date into src/Inc/slmver.h

use strict;
use POSIX qw(strftime);
use File::Copy;
use Data::Dumper;

my $date = "";
foreach my $word ( split('\s',strftime( '%y %m %d', localtime ))) {
	my $oct = sprintf("%o",$word);
	$oct = '0'.$oct if ($oct < 10);
	$date = $date.$oct
}
print "Setting build time to $date\n";
open(H,"C:\\build\\Allegiance\\src\\Inc\\slmver.h");
my @lines = <H>;
close H;
move("C:\\build\\Allegiance\\src\\Inc\\slmver.h","C:\\build\\Allegiance\\src\\Inc\\slmver-prev.h");
open(H,">C:\\build\\Allegiance\\src\\Inc\\slmver.h");
foreach my $line (@lines) {
	if ($line =~ /#define rup/) {
		print H "#define rup	$date //set by slmver.pl\n";
	} else {
		print H $line;
	}
}
close(H);
exit 0;