use strict;

my ($ver, $build, $revision) = @ARGV;

my $now_string = localtime;
my $client_size = (stat("C:\\build\\Package\\Client_${build}.7z"))[7];
my $min_size = (stat("C:\\build\\Package\\Minimal_${build}.7z"))[7];
my $reg_size = (stat("C:\\build\\Package\\Regular_${build}.7z"))[7];
my $hires_size = (stat("C:\\build\\Package\\Hires_${build}.7z"))[7];
my $tool_size = (stat("C:\\build\\Package\\Tools_${build}.7z"))[7];
my $server_size = (stat("C:\\build\\Package\\Server_${build}.7z"))[7];
my $lobby_size = (stat("C:\\build\\Package\\Lobby_${build}.7z"))[7];
my $music_size = (stat("C:\\build\\Package\\Music_${build}.7z"))[7];
my $pdb_size = (stat("C:\\build\\Package\\Pdb_${build}.7z"))[7];

open(BUILD,">C:\\build\\build.nsh");
print BUILD qq{
!define VERSION "$ver"
!define BUILD "$build"
!define REVISION "$revision"
!define RUNTIME "$now_string"
!define CLIENT_FILE_SIZE $client_size
!define MINIMAL_FILE_SIZE $min_size
!define REGULAR_FILE_SIZE $reg_size
!define HIRES_FILE_SIZE $hires_size
!define TOOLS_FILE_SIZE $tool_size
!define SERVER_FILE_SIZE $server_size
!define LOBBY_FILE_SIZE $lobby_size
!define MUSIC_FILE_SIZE $music_size
!define PDB_FILE_SIZE $pdb_size
};
close BUILD;
exit 0;