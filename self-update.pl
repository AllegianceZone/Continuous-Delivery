use strict;

my $build = $ARGV[0];

if (-e "C:\\self-updated") {
	print "Build & Deploy tools were updated!\n";
	exit 0;
} else {
	print "Build & Deploy tools getting updated first...\n";
}

my $cmd = "C:\\build\\self-update.bat";
system($cmd);
$cmd = "copy C:\\build\\Continuous-Delivery\\* C:\\build /Y";
system($cmd);

#TODO
# - ftp the contents of C:\build\Continuous-Delivery\az to allegiancezone.cloudapp.net:21122 /
# - LWP our way to admin session and POST C:\build\Continuous-Delivery\trac\bitten.xml to http://trac.allegiancezone.com/admin/bitten/configs/Allegiance
# - using same admin session from above and invalidate our current build

open(TOUCH,">C:\\self-updated");
print "\n";
close TOUCH;

#TODO
# - kill bitten-slave, it will automatically restart and skip the tool updating/bitten-slave killing step
# - Profit?