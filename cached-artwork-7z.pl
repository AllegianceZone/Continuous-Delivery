use strict;

my $dir = "C:\\build\\Package\\Artwork_minimal";

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

open(LA,"C:\\lastart-minimal");
my $la = <LA>;
close LA;

print "$la vs $ts $files[0]\n";

if ($la ne "$ts $files[0]") {
	my $cmd = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\Package\\Minimal.7z C:\\build\\Package\\Artwork_minimal\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping minimal artwork 7z process, not changed!\n";
};

open(LA,">C:\\lastart-minimal");
print LA "$ts $files[0]";
close LA;



$dir = "C:\\build\\Package\\Artwork_detailed";

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

open(LA,"C:\\lastart-detailed");
my $la = <LA>;
close LA;

print "$la vs $ts $files[0]\n";

if ($la ne "$ts $files[0]") {
	my $cmd = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\Package\\Hires.7z C:\\build\\Package\\Artwork_detailed\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping detailed artwork 7z process, not changed!\n";
};

open(LA,">C:\\lastart-detailed");
print LA "$ts $files[0]";
close LA;



$dir = "C:\\build\\Package\\Artwork";

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

open(LA,"C:\\lastart-regular");
my $la = <LA>;
close LA;

print "$la vs $ts $files[0]\n";

if ($la ne "$ts $files[0]") {
	my $cmd = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\Package\\Regular.7z C:\\build\\Package\\Artwork\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping regular artwork 7z process, not changed!\n";
};

open(LA,">C:\\lastart-regular");
print LA "$ts $files[0]";
close LA;

