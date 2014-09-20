#Imago <imagotrigger@gmail.com>
# Creates client and server filelists
#  Archives the list and targets for deploy.pl
#TODO artwork subdirectory support!


use strict;
use Net::FTP;
use POSIX qw(strftime);
use File::Copy;
use Data::Dumper;
use File::Copy::Recursive qw(dircopy);

my $offset = strftime("%z", localtime());
if ($offset =~ /Daylight/i) {
	$offset = 5;
} else {
	$offset = 6;
}

my $dontcompress_re = ".avi|.ogg|.png|.ffe";

my @lines;

if (-e "C:\\build\\betalist.txt") {
open(LIST,"C:\\build\\betalist.txt");
@lines = <LIST>;
close LIST;
}

my %files = ();
my @changed;

foreach my $line (@lines) {
	my @vals = split(' ',$line);
	$files{$vals[4]} = $vals[3];
}

my ($num_of_files,$num_of_dirs,$depth) = dircopy("C:\\build\\Artwork","C:\\build\\Package\\Artwork\\");
print "Copied $num_of_files files in $num_of_dirs directories ($depth deep) from Artwork to Package\\Artwork\n";
my ($num_of_files,$num_of_dirs,$depth) = dircopy("C:\\build\\Allegiance\\artwork","C:\\build\\Package\\Artwork\\");
print "Copied $num_of_files files in $num_of_dirs directories ($depth deep) from Allegiance\\artwork to Package\\Artwork\n";

opendir(DIR, "C:\\build\\Package\\Artwork\\");
my @art = readdir(DIR); 
closedir DIR;

print "number of assets: ".(scalar @art)."\n";

foreach my $file (@art) {
	next if ($file =~ /^\./);
	my $cmd = "C:\\build\\crc32.exe C:\\build\\Package\\Artwork\\$file";
	my $crc = `$cmd`;
	chomp $crc;
	my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
	if (!exists $files{$file} || $files{$file} != $crc2) {
		next if $file eq 'blank1.mml';
		next if $file eq 'blank2.mml';
		push(@changed,$file);
	}
}

print "Changed artwork:\n";
print Dumper(\@changed);
print Dumper(scalar @changed);

open(LIST,">C:\\build\\betalist.txt");
foreach my $line (@lines) {
	my @vals = split(/\s/,$line);
	my $file = $vals[4];
	next if ($file eq 'Allegiance.exe');
	next if ($file eq 'Reloader.exe');
	next if ($file eq 'inputmap1.mdl');
	if (grep { $file eq $_ } @changed) {
		my $cmd = "C:\\build\\crc32.exe C:\\build\\Package\\Artwork\\$file";
		my $cmd2 = "C:\\build\\mscompress.exe C:\\build\\Package\\Artwork\\$file";
		my ($modtime,$size)= (stat("C:\\build\\Package\\Artwork\\$file"))[9,7];
		next if (!$size);
		my $crc = `$cmd`;
		chomp $crc;
		$size = sprintf("%09d",$size);
		my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
		my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
		print LIST "$dt $size $crc2 $file\n";
		if ($size < 2048 || $file =~ /$dontcompress_re/i) {
			copy("C:\\build\\Package\\Artwork\\${file}","C:\\build\\AutoUpdate\\Game\\$file");
		} else {
			`$cmd2`;
			move("C:\\build\\Package\\Artwork\\${file}_","C:\\build\\AutoUpdate\\Game\\$file");		
		}
		#my $index = 0; my $count = scalar @changed; $index++ until $changed[$index] eq $file or $index==$count; splice(@changed, $index, 1);
		my @del_indexes = reverse(grep { $changed[$_] eq $file } 0..$#changed);
		foreach my $item (@del_indexes) {
		   splice (@changed,$item,1);
		}
	} else {
		print LIST $line;
	}
}

print "still have ".(scalar @changed). " new files to deal with...\n";

foreach my $file (@changed) {
		my $cmd = "C:\\build\\crc32.exe C:\\build\\Package\\Artwork\\$file";
		my $cmd2 = "C:\\build\\mscompress.exe C:\\build\\Package\\Artwork\\$file";
		my ($modtime,$size)= (stat("C:\\build\\Package\\Artwork\\$file"))[9,7];
		next if (!$size);
		next if ($file eq 'inputmap1.mdl');
		my $crc = `$cmd`;
		chomp $crc;
		$size = sprintf("%09d",$size);
		my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
		my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
		print LIST "$dt $size $crc2 $file\n";
		if ($size < 2048 || $file =~ /$dontcompress_re/i) {
			copy("C:\\build\\Package\\Artwork\\${file}","C:\\build\\AutoUpdate\\Game\\$file");
		} else {
			`$cmd2`;
			move("C:\\build\\Package\\Artwork\\${file}_","C:\\build\\AutoUpdate\\Game\\$file");		
		}
}

close LIST;

print "Appending client binaries to Filelist...\n";

open(LIST,">>C:\\build\\betalist.txt");
my @objs = ("C:\\Allegiance.exe","C:\\Reloader.exe");
foreach my $file (@objs) {
	my $cmd = "C:\\build\\crc32.exe $file";
	my $cmd2 = "C:\\build\\mscompress.exe $file";
	my ($modtime,$size)= (stat("$file"))[9,7];
	next if (!$size);
	my $crc = `$cmd`;
	chomp $crc;
	$size = sprintf("%09d",$size);
	my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
	my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
	my $bin = "Gurgle.crap";
	if ($file =~ /.*\\([^\\]+$)/) {
		$bin = $1;
	}	
	print LIST "$dt $size $crc2 $bin\n";
	`$cmd2`;
	move("${file}_","C:\\build\\AutoUpdate\\Game\\$bin");
}
close LIST;

print "Compressing Game Files for AU...\n";
my $cmd3 = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\AutoUpdate\\Game.7z C:\\build\\AutoUpdate\\Game\\* -xr!*Server -mx0 -mmt=off";
system($cmd3);

copy("C:\\build\\betalist.exe", "C:\\build\\External\FileList.txt");

#TODO only changed like client...
open(LIST,">C:\\build\\serverlist.txt");
print "Creating server list (cvh, igc, txt)\n";
foreach my $file (@art) {
	next if ($file =~ /^\./);
	next if ($file !~ /\.igc|\.txt|\.cvh/i);
	my $cmd = "C:\\build\\crc32.exe C:\\build\\Package\\Artwork\\$file";
	my $cmd2 = "C:\\build\\mscompress.exe C:\\build\\Package\\Artwork\\$file";
	my ($modtime,$size)= (stat("C:\\build\\Package\\Artwork\\$file"))[9,7];
	next if (!$size);
	my $crc = `$cmd`;
	chomp $crc;
	$size = sprintf("%09d",$size);
	my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
	my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
	print LIST "$dt $size $crc2 $file\n";
	if ($size < 2048 || $file =~ /$dontcompress_re/i) {
		copy("C:\\build\\Package\\Artwork\\${file}","C:\\build\\AutoUpdate\\Game\\Server\\$file");
	} else {
		`$cmd2`;
		move("C:\\build\\Package\\Artwork\\${file}_","C:\\build\\AutoUpdate\\Game\\Server\\$file");
	}
}
close LIST;

print "Appending server binaries' to serverlist...\n";
open(LIST,">>C:\\build\\serverlist.txt");
my @objs = ("C:\\AllSrv.exe","C:\\AllSrv.pdb","C:\\AGC.dll","C:\\AGC.pdb","C:\\AllSrvUI.exe","C:\\AllSrvUI.pdb","C:\\AutoUpdate.pdb");
foreach my $file (@objs) {
	my $cmd = "C:\\build\\crc32.exe $file";
	my $cmd2 = "C:\\build\\mscompress.exe $file";
	my ($modtime,$size)= (stat("$file"))[9,7];
	next if (!$size);
	my $crc = `$cmd`;
	chomp $crc;
	$size = sprintf("%09d",$size);
	my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
	my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
	my $bin = "Gurgle.crap";
	if ($file =~ /.*\\([^\\]+$)/) {
		$bin = $1;
	}	
	print LIST "$dt $size $crc2 $bin\n";
	`$cmd2`;
	move("${file}_","C:\\build\\AutoUpdate\\Game\\Server\\$bin");
}
close LIST;

print "Compressing Server Files for AU...\n";
my $cmd3 = "\"C:\\Program Files\\7-Zip\\7z.exe\" a -t7z C:\\build\\AutoUpdate\\Server.7z C:\\build\\AutoUpdate\\Game\\Server\\* -mx0 -mmt=off";
system($cmd3);
exit 0;

