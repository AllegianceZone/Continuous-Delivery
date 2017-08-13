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

my ($azbp,$szp) = @ARGV;

my $dontcompress_re = ".avi|.ogg|.png|.ffe|faohbstac.mdl|ta_drac_tp.mdl";

my @lines;

if (-e "$azbp\\betalist.txt") {
open(LIST,"$azbp\\betalist.txt");
@lines = <LIST>;
close LIST;
}

my %files = ();
my @changed;

foreach my $line (@lines) {
	my @vals = split(' ',$line);
	$files{$vals[4]} = $vals[3];
}

my ($num_of_files,$num_of_dirs,$depth) = dircopy("$azbp\\Artwork","$azbp\\Package\\Artwork\\");
print "Copied $num_of_files files in $num_of_dirs directories from Artwork to Package\\Artwork\n";

my ($num_of_files,$num_of_dirs,$depth) = dircopy("$azbp\\Artwork_minimal","$azbp\\Package\\Artwork_minimal\\");
print "Copied $num_of_files files in $num_of_dirs directories from Artwork_minimal to Package\\Artwork_minimal\n";

my ($num_of_files,$num_of_dirs,$depth) = dircopy("$azbp\\Artwork_detailed","$azbp\\Package\\Artwork_detailed\\");
print "Copied $num_of_files files in $num_of_dirs directories from Artwork_detailed to Package\\Artwork_detailed\n";

# No longer needed, our build is and always will be compatible
#my ($num_of_files,$num_of_dirs,$depth) = dircopy("$azbp\\Allegiance\\artwork","$azbp\\Package\\Artwork\\");
#print "Copied $num_of_files files in $num_of_dirs directories ($depth deep) from Allegiance\\artwork to Package\\Artwork\n";

opendir(DIR, "$azbp\\Package\\Artwork\\");
my @art = readdir(DIR); 
closedir DIR;

print "number of assets: ".(scalar @art)."\n";

foreach my $file (@art) {
	next if ($file =~ /^\./);
	my $cmd = "$azbp\\crc32.exe $azbp\\Package\\Artwork\\$file";
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

open(LIST,">$azbp\\betalist.txt");
foreach my $line (@lines) {
	my @vals = split(/\s/,$line);
	my $file = $vals[4];
	next if ($file eq 'Allegiance.exe');
	next if ($file eq 'Allegiance.pdb');
	next if ($file eq 'Reloader.exe');
	next if ($file eq 'inputmap1.mdl');
	if (grep { $file eq $_ } @changed) {
		my $cmd = "$azbp\\crc32.exe $azbp\\Package\\Artwork\\$file";
		my $cmd2 = "$azbp\\mscompress.exe $azbp\\Package\\Artwork\\$file";
		my ($modtime,$size)= (stat("$azbp\\Package\\Artwork\\$file"))[9,7];
		next if (!$size);
		my $crc = `$cmd`;
		chomp $crc;
		$size = sprintf("%09d",$size);
		my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
		my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
		print LIST "$dt $size $crc2 $file\n";
		if ($size < 2048 || $file =~ /$dontcompress_re/i) {
			copy("$azbp\\Package\\Artwork\\${file}","$azbp\\AutoUpdate\\Game\\$file");
		} else {
			`$cmd2`;
			move("$azbp\\Package\\Artwork\\${file}_","$azbp\\AutoUpdate\\Game\\$file");		
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
		my $cmd = "$azbp\\crc32.exe $azbp\\Package\\Artwork\\$file";
		my $cmd2 = "$azbp\\mscompress.exe $azbp\\Package\\Artwork\\$file";
		my ($modtime,$size)= (stat("$azbp\\Package\\Artwork\\$file"))[9,7];
		next if (!$size);
		next if ($file eq 'inputmap1.mdl');
		my $crc = `$cmd`;
		chomp $crc;
		$size = sprintf("%09d",$size);
		my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
		my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
		print LIST "$dt $size $crc2 $file\n";
		if ($size < 2048 || $file =~ /$dontcompress_re/i) {
			copy("$azbp\\Package\\Artwork\\${file}","$azbp\\AutoUpdate\\Game\\$file");
		} else {
			`$cmd2`;
			move("$azbp\\Package\\Artwork\\${file}_","$azbp\\AutoUpdate\\Game\\$file");		
		}
}

close LIST;

print "Appending client binaries to Filelist...\n";

open(LIST,">>$azbp\\betalist.txt");
my @objs = ("$azbp\\Package\\Client\\Allegiance.exe");
foreach my $file (@objs) {
	my $cmd = "$azbp\\crc32.exe $file";
	my $cmd2 = "$azbp\\mscompress.exe $file";
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
	move("${file}_","$azbp\\AutoUpdate\\Game\\$bin");
}
close LIST;

open(LIST,">$azbp\\list.txt");
my @objs = ("$azbp\\Package\\Client\\Allegiance.exe");
foreach my $file (@objs) {
	my $cmd = "$azbp\\crc32.exe $file";
	my $cmd2 = "$azbp\\mscompress.exe $file";
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
	move("${file}_","$azbp\\AutoUpdate\\Noart\\$bin");
}
close LIST;


print "Compressing Game Files for AU...\n";
my $cmd3 = "\"$szp\" a -t7z $azbp\\AutoUpdate\\Game.7z $azbp\\AutoUpdate\\Game\\* -xr!*Server -mx0 -m0=LZMA";
system($cmd3);
$cmd3 = "\"$szp\" a -t7z $azbp\\AutoUpdate\\Noart.7z $azbp\\AutoUpdate\\Noart\\* -xr!*Server -mx0 -m0=LZMA";
system($cmd3);

#TODO only changed like client...
open(LIST,">$azbp\\serverlist.txt");
print "Creating server list (cvh, igc, txt)\n";
foreach my $file (@art) {
	next if ($file =~ /^\./);
	next if ($file !~ /\.igc|\.txt|\.cvh|\.ini/i);
	my $cmd = "$azbp\\crc32.exe $azbp\\Package\\Artwork\\$file";
	my $cmd2 = "$azbp\\mscompress.exe $azbp\\Package\\Artwork\\$file";
	my ($modtime,$size)= (stat("$azbp\\Package\\Artwork\\$file"))[9,7];
	next if (!$size);
	my $crc = `$cmd`;
	chomp $crc;
	$size = sprintf("%09d",$size);
	my $dt = strftime("%Y/%m/%d %H:%M:%S",localtime($modtime + (3600 * $offset)));
	my $crc2 = "0" x ( 8 - length($crc) ) . $crc; 
	print LIST "$dt $size $crc2 $file\n";
	if ($size < 2048 || $file =~ /$dontcompress_re/i) {
		copy("$azbp\\Package\\Artwork\\${file}","$azbp\\AutoUpdate\\Game\\Server\\$file");
	} else {
		`$cmd2`;
		move("$azbp\\Package\\Artwork\\${file}_","$azbp\\AutoUpdate\\Game\\Server\\$file");
	}
	copy("$azbp\\Package\\Artwork\\${file}","$azbp\\Package\\Server\\Artwork\\$file");
}
close LIST;

print "Appending server binaries' to serverlist...\n";
open(LIST,">>$azbp\\serverlist.txt");
my @objs = ("$azbp\\Package\\Server\\AllSrv.exe","$azbp\\Package\\Server\\AGC.dll","$azbp\\Package\\Server\\AllSrvUI.exe");
foreach my $file (@objs) {
	my $cmd = "$azbp\\crc32.exe $file";
	my $cmd2 = "$azbp\\mscompress.exe $file";
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
	move("${file}_","$azbp\\AutoUpdate\\Game\\Server\\$bin");
	next if ($file =~ /\.pdb/);
	copy("${file}","$azbp\\Package\\Server\\$bin");
}
close LIST;

print "Compressing Server Files for AU...\n";
my $cmd3 = "\"$szp\" a -t7z $azbp\\AutoUpdate\\Server.7z $azbp\\AutoUpdate\\Game\\Server\\* -mx0 -m0=LZMA";
system($cmd3);
exit 0;
