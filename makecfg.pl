#Imago <imagotrigger@gmail.com>
# Inserts CRC and size info into AZBeta.cfg

use strict;
use File::Copy;

print "Updating AZDev.cfg\n";

unlink "C:\\build\\FileList.txt";
my $cmd5 = "C:\\build\\crc32.exe C:\\build\\list.txt";

#unlink "C:\\list.txt_";
#my $cmd6 = "C:\\build\\mscompress.exe C:\\build\\list.txt";
#`$cmd6`;
#move("C:\\build\\list.txt_","C:\\build\\FileList.txt");
copy("C:\\build\\list.txt","C:\\build\\FileList.txt");

my $crc0 = `$cmd5`;
chomp $crc0;
my $size0 = (stat("C:\\build\\list.txt"))[7];

unlink "C:\\build\\AutoUpdate\\FileList.txt";
my $cmd3 = "C:\\build\\crc32.exe C:\\build\\betalist.txt";
unlink "C:\\betalist.txt_";
my $cmd4 = "C:\\build\\mscompress.exe C:\\build\\betalist.txt";
`$cmd4`;
move("C:\\build\\betalist.txt_","C:\\build\\AutoUpdate\\FileList.txt");
my $crc = `$cmd3`;
chomp $crc;
#my $size = (stat("C:\\build\\AutoUpdate\\Filelist.txt"))[7] + 1;
my $size = (stat("C:\\build\\betalist.txt"))[7];

$cmd3 = "C:\\build\\crc32.exe C:\\build\\motd.mdl";
my $crc2 = `$cmd3`;
chomp $crc2;

$cmd3 = "C:\\build\\crc32.exe C:\\build\\serverlist.txt";
my $crc3 = `$cmd3`;
chomp $crc3;
my $size2 = (stat("C:\\build\\serverlist.txt"))[7];

my $cmd0 = "C:\\build\\upx.exe -q -9 -f -o C:\\AutoUpdate.exe C:\\build\\Allegiance\\x86\\AutoUpdate.exe";
`$cmd0`;

$cmd3 = "C:\\build\\crc32.exe C:\\AutoUpdate.exe";
my $crc4 = `$cmd3`;
chomp $crc4; 

open(CFG,'>C:\\build\\AZNoart.cfg');

print CFG qq{[Allegiance]
PublicLobby=allegiancezone.cloudapp.net
PublicMessageURL=http://autoupdate.allegiancezone.com/config/beta/motd.mdl
LobbyClientPort=2302
LobbyServerPort=2303
FilelistSite=http://autoupdate.allegiancezone.com
FilelistDirectory=/autoupdate/Noart
FileListCRC = $crc0
FilelistSize = $size0
PublicMessageCRC = $crc2
TrainingURL=http://allegiancezone.com/#/Training
ZoneAuthGUID={00000000-0000-0000-C000-000000000046}
ZAuth=allegiancezone.cloudapp.net
UsePassport=0
PassportUpdateURL=http://allegiancezone.com
ZoneEventsURL=http://autoupdate.allegiancezone.com/config/event/events.mdl
ZoneEventDetailsURL=http://autoupdate.allegiancezone.com/config/event/details.mdl
ClubLobby=allegiancezone.cloudapp.net
Club=allegiancezone.cloudapp.net
ClubMessageURL=http://autoupdate.allegiancezone.com/config/club/motd.mdl
ClubMessageCRC=$crc2


[Cores]
zone_core=AZ 1.25
dn_000460=DN 4.60
GoDII_04=GoD II 0.4
sw_a103=Starwars 1.03a
rps55=RPS 5.5
RTc006a=EoR 6.0a
PC2_019=PookCore II b19
VoS000090=VoS
cc_09=CC 9
cc_09b=CC 9b
PCore005b=P-Core v0.5b
PCore006=P-Core v0.6

[OfficialCores]
PCore006=P-Core v0.6

[OfficialServers]
allegiancezone=191.236.96.140
azbuildslave=191.239.1.217

[AllSrvUI]
Site=http://autoupdate.allegiancezone.com
AutoUpdateURL=http://autoupdate.allegiancezone.com/autoupdate/Game/Server/standalone/AutoUpdate.exe
AutoUpdateCRC=$crc4
Directory=/autoupdate/Game/Server
FileListCRC = $crc3
FilelistSize = $size2


; THIS IS A VALID CONFIG FILE

};
close CFG;

open(CFG,'>C:\\build\\AZDev.cfg');

print CFG qq{[Allegiance]
PublicLobby=allegiancezone.cloudapp.net
PublicMessageURL=http://autoupdate.allegiancezone.com/config/beta/motd.mdl
LobbyClientPort=2302
LobbyServerPort=2303
FilelistSite=http://autoupdate.allegiancezone.com
FilelistDirectory=/autoupdate/Game
FileListCRC = $crc
FilelistSize = $size
PublicMessageCRC = $crc2
TrainingURL=http://allegiancezone.com/#/Training
ZoneAuthGUID={00000000-0000-0000-C000-000000000046}
ZAuth=allegiancezone.cloudapp.net
UsePassport=0
PassportUpdateURL=http://allegiancezone.com
ZoneEventsURL=http://autoupdate.allegiancezone.com/config/event/events.mdl
ZoneEventDetailsURL=http://autoupdate.allegiancezone.com/config/event/details.mdl
ClubLobby=allegiancezone.cloudapp.net
Club=allegiancezone.cloudapp.net
ClubMessageURL=http://autoupdate.allegiancezone.com/config/club/motd.mdl
ClubMessageCRC=$crc2


[Cores]
zone_core=AZ 1.25
dn_000460=DN 4.60
GoDII_04=GoD II 0.4
sw_a103=Starwars 1.03a
rps55=RPS 5.5
RTc006a=EoR 6.0a
PC2_019=PookCore II b19
VoS000090=VoS
cc_09=CC 9
cc_09b=CC 9b
PCore005b=P-Core v0.5b
PCore006=P-Core v0.6

[OfficialCores]
PCore006=P-Core v0.6

[OfficialServers]
allegiancezone=191.236.96.140
azbuildslave=191.239.1.217

[AllSrvUI]
Site=http://autoupdate.allegiancezone.com
AutoUpdateURL=http://autoupdate.allegiancezone.com/autoupdate/Game/Server/standalone/AutoUpdate.exe
AutoUpdateCRC=$crc4
Directory=/autoupdate/Game/Server
FileListCRC = $crc3
FilelistSize = $size2


; THIS IS A VALID CONFIG FILE

};
close CFG;
exit 0;