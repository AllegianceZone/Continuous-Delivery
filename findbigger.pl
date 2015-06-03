use strict;

my $azbp = $ARGV[0];

opendir(DIR,"$azbp\\AutoUpdate\\Game\\");
my @files = readdir DIR;
closedir DIR;

open(LIST,"$azbp\\betalist.txt");
my @lines = <LIST>;
close LIST;

foreach my $file (@files) {
	next if $file =~ /^\./;
	my $size = (stat("$azbp\\Autoupdate\\Game\\$file"))[7];
	foreach my $line (@lines) {
		my ($listsize,$listfile) = (split(/\s/,$line))[2,4];
		if ($listfile eq $file) {
			print "$file got bigger!!!\n" if ($size > $listsize);
		}
	}
	
}
