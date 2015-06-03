use strict;
use File::Copy;

my $build = $ARGV[0];
my $azbp = $ARGV[1];
my $szp = $ARGV[2];

my $lastbuild = $build;
while(! -e "$azbp\\Package\\Regular_${lastbuild}.7z") {
	$lastbuild = $lastbuild - 1;
	if ($lastbuild <= 1) {
		print "couldn't find a last build!\n";
		last;
	}
}

my $dir = "$azbp\\Package\\Artwork_minimal";

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
	my $cmd = "\"$szp\" a -t7z $azbp\\Package\\Minimal_${build}.7z $azbp\\Package\\Artwork_minimal\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping minimal artwork 7z process, not changed!\n";
	copy("$azbp\\Package\\Minimal_${lastbuild}.7z","$azbp\\Package\\Minimal_${build}.7z") if ($lastbuild != $build);
};

open(LA,">C:\\lastart-minimal");
print LA "$ts $files[0]";
close LA;



$dir = "$azbp\\Package\\Artwork_detailed";

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
	my $cmd = "\"$szp\" a -t7z $azbp\\Package\\Hires_${build}.7z $azbp\\Package\\Artwork_detailed\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping detailed artwork 7z process, not changed!\n";
	copy("$azbp\\Package\\Hires_${lastbuild}.7z","$azbp\\Package\\Hires_${build}.7z") if ($lastbuild != $build);
};

open(LA,">C:\\lastart-detailed");
print LA "$ts $files[0]";
close LA;



$dir = "$azbp\\Package\\Artwork";

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
	my $cmd = "\"$szp\" a -t7z $azbp\\Package\\Regular_${build}.7z $azbp\\Package\\Artwork\\ -xr!*.git -mx9 -mmt=off";
	system($cmd);
} else {
	print "skipping regular artwork 7z process, not changed!\n";
	copy("$azbp\\Package\\Regular_${lastbuild}.7z","$azbp\\Package\\Regular_${build}.7z") if ($lastbuild != $build);
};

open(LA,">C:\\lastart-regular");
print LA "$ts $files[0]";
close LA;

