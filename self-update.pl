use strict;
use Net::FTP;
use WWW::Mechanize;
use File::Slurp;

my $host = "allegiancezone.cloudapp.net";
my $tracurl = "http://trac.spacetechnology.net";

my $build = $ARGV[0];
my $azbp = $ARGV[1];

if (-e "C:\\self-updated") {
	print "Build & Deploy tool updates for this run:\n";
	open(LOG,"$azbp\\self-update.log");
	my @lines = <LOG>;
	close LOG;
	foreach (@lines) {print $_};
	exit 0;
} else {
	print "Build & Deploy tools getting updated first...\n";
}

my $cmd = "$azbp\\self-update.bat $azbp > $azbp\\self-update.log 2>&1";
`$cmd`;

open(LOG,"$azbp\\self-update.log");
my @lines = <LOG>;
close LOG;

$cmd = "copy $azbp\\Continuous-Delivery\\* $azbp /Y";
system($cmd);

$cmd = "copy $azbp\\Continuous-Delivery\\Package\\Tools\\* $azbp\\Package\\Tools /Y";
system($cmd);
$cmd = "copy $azbp\\Continuous-Delivery\\Package\\Music\\* $azbp\\Package\\Music /Y";
system($cmd);
$cmd = "copy $azbp\\Continuous-Delivery\\Package\\Client\\* $azbp\\Package\\Client /Y";
system($cmd);
$cmd = "copy $azbp\\Continuous-Delivery\\Package\\Server\\* $azbp\\Package\\Server /Y";
system($cmd);
$cmd = "copy $azbp\\Continuous-Delivery\\Package\\Lobby\\* $azbp\\Package\\Lobby /Y";
system($cmd);

print "Uploading deploy scripts to allegiancezone...\n";
open(PWD,"C:\\pass.txt");
my $pass = <PWD>;
close PWD;
my $ftp = Net::FTP->new($host, Debug => 0, Port => 21122) or die "Cannot connect to $host $@";
$ftp->login("deploy",$pass) or die "Cannot login ", $ftp->message;
opendir(DIR, "$azbp\\Continuous-Delivery\\az\\");
my @files = readdir(DIR); 
closedir DIR;
foreach (@files) {
	next if ($_ =~ /^\./);
	next if ($_ =~ /\.exe/);
	next if (-d "$azbp\\Continuous-Delivery\\az\\$_");
	$ftp->put("$azbp\\Continuous-Delivery\\az\\$_") or die "put failed ", $ftp->message;
}
$ftp->quit();

my $restart = 0;
if (grep $_ =~ /bitten\.xml/, @lines) {
	print "Logging into bitten...\n";
	open(PWD,"C:\\admin.txt");
	my $admin = <PWD>;
	close PWD;
	my $xml = read_file("$azbp\\Continuous-Delivery\\trac\\bitten.xml") ;
	my $mech = WWW::Mechanize->new();
	$mech->get("$tracurl/login");
	$mech->form_id("acctmgr_loginform");
	$mech->field("user", "builder");
	$mech->field("password", $admin);
	$mech->field("referer", "$tracurl/build/Allegiance/$build"); 
	$mech->submit();
	print "Invalidating build...\n";
	$mech->form_number(2);
	$mech->submit();
	print "Loading recipe page...\n";
	$mech->get("$tracurl/admin/bitten/configs/Allegiance");
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
	open (PS,"$azbp\\pslist.exe 2>crap python |");
	my $pid = 0;
	while (<PS>) {
		if ($_ =~ /python\s+(\d+)/) {
			$pid = $1;
		}
	}
	close PS;
	if ($pid != 0) {
		my $cmd = "$azbp\\pskill 2>crap $pid";
		print "Killing Python executable $pid\n";
		`$cmd`;
		sleep(3);
	}
}
print "Ok!\n";
