use strict;
use Win32::ChangeNotify;
use Storable;
use Net::GitHub::V3;
use Try::Tiny;
use WebService::Gitter;
use File::Copy;

open(PWD,"C:\\pass.txt");
my $gitpass = <PWD>;
close PWD;

open(PWD,"C:\\token.txt");
my $gitterpass = <PWD>;
close PWD;

open(PWD,"C:\\emailpass.txt");
my $emailpass = <PWD>;
close PWD;


my %counter;
try {
	%counter = %{retrieve('E:\\scanner\\build\\alleg_counter.txt')};
} catch {
	$counter{build} = 0;
	store \%counter, 'E:\\scanner\\build\\alleg_counter.txt';
};
print "build counter is at ". $counter{build}."\n";
our $dir = "E:\\scanner\\installers\\alleg_incoming";

 my $findfile = sub {
	 opendir(my $DH, $dir) or die "Error opening $dir: $!";
	 my %files = map { $_ => (stat("$dir\\$_"))[9] } grep(! /^\.\.?$/, readdir($DH));
	 closedir($DH);
	 my @sorted_files = sort { $files{$b} <=> $files{$a} } (keys %files);
	 foreach (@sorted_files) {
	 	if ($_ =~ /\.7z/i) {
	 		return $_;
	 	}
	 }
 };


my $WatchDir;

$WatchDir = new Win32::ChangeNotify( $dir ,0 , FILE_NOTIFY_CHANGE_FILE_NAME);
if( ! $WatchDir )
{
    exit();
}
breakout:
$WatchDir->reset();
while (1) {
	        my $Result = $WatchDir->wait( 120 * 1000 );
        	if( $Result > 0 ) {
        		print "make an installer...\n";
        		my %counter = %{retrieve('E:\\scanner\\build\\alleg_counter.txt')};
        		system("E:\\scanner\\sync_alleg.bat"); #hard coded stupid ;-)
        		sleep 120;
        		open(VER,"E:\\scanner\\installers\\alleg_version.txt");
        		my $ver = <VER>;
        		close VER;
        		$ver =~ s/^\s*(.*?)\s*$/$1/;
        		my $count = $counter{build};  
        		if (-e "E:\\scanner\\installers\\AllegSetup_b${count}_${ver}.exe") {
        			print "this installer already exists...\n";
        			$WatchDir->reset();
        			next;
        		}        		
        		print "now...\n";
        		my $file = &$findfile();
        		goto breakout if (!$file);
        		print "deal with $file\n";
        		system("rmdir /S /Q E:\\scanner\\installers\\artifacts");
        		sleep 3;
        		print "unzip..\n";
        		system("7z x $dir\\$file -oE:\\scanner\\installers");
        		$counter{build}++;
        		store \%counter, 'E:\\scanner\\build\\alleg_counter.txt';
        		$count++;
        		my $build = $file;
        		$build =~ s/\.7z//gi;		
        		
        		print "copying files...\n";
        		system("E:\\Continuous-Delivery\\copy.bat $count");
        		print "making lists...\n";
        		system("E:\\Continuous-Delivery\\makelist.pl E:\\alleg_build 7z");
        		print "caching artwork...\n";
        		system("E:\\Continuous-Delivery\\cached-artwork-7z.pl $count E:\\alleg_build 7z");
        		print "creating build file for # $build\n";
        		system("E:\\Continuous-Delivery\\nsis-build.pl $build $count $ver E:\\alleg_build");
        		print "creating installer for version $ver\n";
        		system("E:\\NSIS\\makensis.exe /V2 E:\\alleg_build\\installer.nsi");
        		sleep 1;
        		print "updating motd\n";
        		system("E:\\Continuous-Delivery\\makemotd.pl $count $ver E:\\alleg_build");
        		print "updating cfg\n";
        		system("E:\\Continuous-Delivery\\makecfg.pl E:\\alleg_build");
        		
        		print "setting up for AZCopy\n";
        		$dir = "E:\\alleg_build";
        		copy($dir."\\AZDev.cfg",$dir."\\cdn\\config\\AZ.cfg"); #<-- same thing now
			copy($dir."\\AZDev.cfg",$dir."\\cdn\\config\\AZDev.cfg");
			copy($dir."\\AZNoart.cfg",$dir."\\cdn\\config\\AZNoart.cfg");
			
			copy($dir."\\motd.mdl",$dir."\\cdn\\config\\club\\motd.mdl");	#<-- actual one used now USEAZ
			copy($dir."\\motd.mdl",$dir."\\cdn\\config\\beta\\motd.mdl");
			copy($dir."\\motd.mdl",$dir."\\cdn\\config\\motd.mdl");
			
			copy($dir."\\FileList.txt",$dir."\\cdn\\autoupdate\\Game\\FileList.txt");
			copy($dir."\\serverlist.txt",$dir."\\cdn\\autoupdate\\Game\\Server\\standalone\\FileList.txt");
			
			copy($dir."\\events.mdl",$dir."\\cdn\\config\\event\\events.mdl");
			copy($dir."\\details.mdl",$dir."\\cdn\\config\\event\\details.mdl");
			
			copy($dir."\\Package\\Regular_$count.7z",$dir."\\cdn\\install\\Regular_$count.7z");
			copy($dir."\\Package\\Hires_$count.7z",$dir."\\cdn\\install\\Hires_$count.7z");
			copy($dir."\\Package\\Minimal_$count.7z",$dir."\\cdn\\install\\Minimal_$count.7z");
			copy($dir."\\Package\\Tools_$count.7z",$dir."\\cdn\\install\\Tools_$count.7z");
			copy($dir."\\Package\\Music_$count.7z",$dir."\\cdn\\install\\Music_$count.7z");
			copy($dir."\\Package\\Lobby_$count.7z",$dir."\\cdn\\install\\Lobby_$count.7z");
			copy($dir."\\Package\\Server_$count.7z",$dir."\\cdn\\install\\Server_$count.7z");
			copy($dir."\\Package\\Client_$count.7z",$dir."\\cdn\\install\\Client_$count.7z");
			copy($dir."\\Package\\Pdb_$count.7z",$dir."\\cdn\\install\\Pdb_$count.7z");
			copy($dir."\\Package\\AllegSetup_$count.exe",$dir."\\cdn\\install\\AllegSetup_$count.exe");
			copy($dir."\\Package\\AllegSetup_$count.exe",$dir."\\cdn\\install\\AllegSetup_latest.exe");
			
						
			my $cmd = "7z x -y -o".$dir."\\cdn\\autoupdate\\Game ".$dir."\\Autoupdate\\Game.7z";
			system($cmd);
			my $cmd = "7z x -y -o".$dir."\\cdn\\autoupdate\\Game\\Server ".$dir."\\Autoupdate\\Server.7z";
			system($cmd);
			my $cmd = "7z x -y -o".$dir."\\cdn\\autoupdate\\Noart ".$dir."\\Autoupdate\\Noart.7z";
			system($cmd);
			
			my $cmd = "E:\\Continuous-Delivery\\azure-sync.bat";
			system($cmd);
        		
        		print "publishing github release\n";
			my $gh = Net::GitHub::V3->new( login => "imagotrigger", pass => $gitpass);
			$gh->repos->set_default_user_repo('AllegianceZone', 'Allegiance');
			my $doupload = 1;
			our $release;
			try {
			$release = $gh->repos->create_release({
				"tag_name" => "${build}_b${count}",
				"target_commitish" => "$ver",
				"name" => "Allegiance Installer",
				"body" => "A Windows installer for Allegiance $build rev. $ver build# $count",
				"draft" => \0,
			    });
			} catch {
				$doupload = 0;
				print "this release already exists...\n";
			};
			  
			  
			if ($doupload) {
				copy($dir."\\Package\\AllegSetup_${count}.exe","E:\\scanner\\installers\\AllegSetup_b${count}_${ver}.exe");
				open F, "E:\\scanner\\installers\\AllegSetup_b${count}_${ver}.exe";
				binmode F;
				my $file = do { local $/; <F> };
				close F;
				my $asset = $gh->repos->upload_asset($release->{id}, "AllegSetup_b${count}_${ver}.exe", 'application/octet-stream',$file);
			
				#send email...
				my $cmd = qq{E:\\sendEmail.exe -o tls=yes -f imagotrigger\@gmail.com -t imagotrigger\@gmail.com -cc imagotrigger\@gmail.com -s smtp.gmail.com:587 -xu imagotrigger\@gmail.com -xp $emailpass -u "Allegiance build completed!" -m "Completed build # $count for $build $ver\n\nftp://imago.buildvideogames.com:2121/AllegSetup_b${count}_${ver}.exe\n\nhttps://github.com/AllegianceZone/Allegiance/releases"};
				my $ret = `$cmd`;
				print $ret . "\n";
						
				print "completed build # $count for $build $ver\n";
				my $git = WebService::Gitter->new(api_key => $gitterpass);
				$git->send_message('597fb2fed73408ce4f6f89af', "Completed build # $count for $build $ver - https://github.com/AllegianceZone/Allegiance/releases");
			}
         		$WatchDir->reset();
        	}
		sleep(60);
	}
$WatchDir->close();

exit 0;

__END__


