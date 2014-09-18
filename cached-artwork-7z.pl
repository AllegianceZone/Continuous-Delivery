use strict;

my $dir = "C:\\build\\Package\\Artwork";

opendir(DIR, $dir) or die "Can't open $dir $!";
my @files = readdir(DIR);
closedir(DIR);

my @del_indexes = reverse(grep { $files[$_] =~ /^\./ } 0..$#files);
foreach my $item (@del_indexes) {
	splice (@files,$item,1);
}

my %h = map(($_, -M "$dir\\$_"), @files);
my @files = sort { $h{$a} <=> $h{$b} } @files;

my $ts = (stat($dir."\\".$files[0]))[9];
my $time = localtime($ts);

open(LA,"C:\\lastart");
my $la = <LA>;
close LA;

print "$la vs $ts $files[0]\n";

if ($la ne "$ts $files[0]") {
	my $cmd = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\Package\\Artwork.7z C:\\build\\Package\\Artwork\\ -xr!*.git -mx9 --mmt=off";
	system($cmd);
} else {
	print "skipping artwork 7z process, not changed!\n";
};

open(LA,">C:\\lastart");
print LA "$ts $files[0]";
close LA;

