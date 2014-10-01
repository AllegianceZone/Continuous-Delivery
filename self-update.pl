use strict;
use Net::FTP;
use WWW::Mechanize;
use File::Slurp;

my $host = "allegiancezone.cloudapp.net";
my $build = $ARGV[0];

if (-e "C:\\self-updated") {
	print "Build & Deploy tool updates for this run:\n";
	foreach (@lines) {print $_};
	exit 0;
} else {
	print "Build & Deploy tools getting updated first...\n";
}

my $cmd = "C:\\build\\self-update.bat > C:\\build\\self-update.log 2>&1";
system($cmd);

open(LOG,"C:\\build\\self-update.log");
my @lines = <LOG>;
close LOG;

$cmd = "copy C:\\build\\Continuous-Delivery\\* C:\\build /Y";
system($cmd);

$cmd = "copy C:\\build\\Continuous-Delivery\\Package\\Tools\\* C:\\build\\Package\\Tools /Y";
system($cmd);
$cmd = "copy C:\\build\\Continuous-Delivery\\Package\\Music\\* C:\\build\\Package\\Music /Y";
system($cmd);
$cmd = "copy C:\\build\\Continuous-Delivery\\Package\\Client\\* C:\\build\\Package\\Client /Y";
system($cmd);
$cmd = "copy C:\\build\\Continuous-Delivery\\Package\\Server\\* C:\\build\\Package\\Server /Y";
system($cmd);
$cmd = "copy C:\\build\\Continuous-Delivery\\Package\\Lobby\\* C:\\build\\Package\\Lobby /Y";
system($cmd);

print "Uploading deploy scripts to allegiancezone...\n";
open(PWD,"C:\\pass.txt");
my $pass = <PWD>;
close PWD;
my $ftp = Net::FTP->new($host, Debug => 0, Port => 21122) or die "Cannot connect to $host $@";
$ftp->login("deploy",$pass) or die "Cannot login ", $ftp->message;
opendir(DIR, "C:\\build\\Continuous-Delivery\\az\\");
my @files = readdir(DIR); 
closedir DIR;
foreach (@files) {
	next if ($_ =~ /^\./);
	next if ($_ =~ /\.exe/);
	next if (-d "C:\\build\\Continuous-Delivery\\az\\$_");
	$ftp->put("C:\\build\\Continuous-Delivery\\az\\$_") or die "put failed ", $ftp->message;
}
$ftp->quit();

my $restart = 0;
if (grep $_ =~ /bitten\.xml/, @lines) {
	print "Logging into bitten...\n";
	open(PWD,"C:\\admin.txt");
	my $admin = <PWD>;
	close PWD;
	my $xml = read_file("C:\\build\\Continuous-Delivery\\trac\\bitten.xml") ;
	my $mech = WWW::Mechanize->new();
	$mech->get("http://trac.allegiancezone.com/login");
	$mech->form_id("acctmgr_loginform");
	$mech->field("user", "admin");
	$mech->field("password", $admin);
	$mech->field("referer", "http://trac.allegiancezone.com/build/Allegiance/$build"); 
	$mech->submit();
	print "Invalidating build...\n";
	$mech->form_number(2);
	$mech->submit();
	print "Loading recipe page...\n";
	$mech->get("http://trac.allegiancezone.com/admin/bitten/configs/Allegiance");
	print "Saving new recipe...\n";
	$mech->form_id("modconfig");
	$mech->field("recipe",$xml);
	$mech->click_button(name=>'save');
	$restart = 1;
};

open(TOUCH,">C:\\self-updated");
print "\n";
close TOUCH;

if ($restart) {
	print "Restarting the bitten-slave...\n";
	open (PS,"C:\\build\\pslist.exe 2>crap python |");
	my $pid = 0;
	while (<PS>) {
		if ($_ =~ /python\s+(\d+)/) {
			$pid = $1;
		}
	}
	close PS;
	if ($pid != 0) {
		my $cmd = "C:\\build\\pskill 2>crap $pid";
		print "Killing Python executable $pid\n";
		`$cmd`;
		sleep(3);
	}
}
print "Ok!\n";