#Imago <imagotrigger@gmail.com>
# Inserts CRC and size info into AZBeta.cfg

use strict;
use File::Copy;

my $azbp = $ARGV[0];

print "Updating AZDev.cfg\n";

unlink "$azbp\\FileList.txt";
my $cmd5 = "$azbp\\crc32.exe $azbp\\list.txt";

#unlink "C:\\list.txt_";
#my $cmd6 = "$azbp\\mscompress.exe $azbp\\list.txt";
#`$cmd6`;
#move("$azbp\\list.txt_","$azbp\\FileList.txt");
copy("$azbp\\list.txt","$azbp\\FileList.txt");

my $crc0 = `$cmd5`;
chomp $crc0;
my $size0 = (stat("$azbp\\list.txt"))[7];

unlink "$azbp\\AutoUpdate\\FileList.txt";
my $cmd3 = "$azbp\\crc32.exe $azbp\\betalist.txt";
unlink "C:\\betalist.txt_";
my $cmd4 = "$azbp\\mscompress.exe $azbp\\betalist.txt";
`$cmd4`;
move("$azbp\\betalist.txt_","$azbp\\AutoUpdate\\FileList.txt");
my $crc = `$cmd3`;
chomp $crc;
#my $size = (stat("$azbp\\AutoUpdate\\Filelist.txt"))[7] + 1;
my $size = (stat("$azbp\\betalist.txt"))[7];

$cmd3 = "$azbp\\crc32.exe $azbp\\motd.mdl";
my $crc2 = `$cmd3`;
chomp $crc2;

$cmd3 = "$azbp\\crc32.exe $azbp\\serverlist.txt";
my $crc3 = `$cmd3`;
chomp $crc3;
my $size2 = (stat("$azbp\\serverlist.txt"))[7];

my $cmd0 = "$azbp\\upx.exe -q -9 -f -o C:\\AutoUpdate.exe $azbp\\Allegiance\\x86\\AutoUpdate.exe";
`$cmd0`;

$cmd3 = "$azbp\\crc32.exe C:\\AutoUpdate.exe";
my $crc4 = `$cmd3`;
chomp $crc4; 

open(CFG,">$azbp\\AZNoart.cfg");

print CFG qq{[Allegiance]
PublicLobby=imago.buildvideogames.com
PublicMessageURL=http://azcdn.blob.core.windows.net/config/beta/motd.mdl
LobbyClientPort=2302
LobbyServerPort=2303
FilelistSite=http://azcdn.blob.core.windows.net
FilelistDirectory=/autoupdate/Noart
FileListCRC = $crc0
FilelistSize = $size0
PublicMessageCRC = $crc2
TrainingURL=http://allegiancezone.com/#/Training
ZoneAuthGUID={00000000-0000-0000-C000-000000000046}
ZAuth=allegiancezone.cloudapp.net
UsePassport=0
PassportUpdateURL=http://allegiancezone.com
ZoneEventsURL=http://azcdn.blob.core.windows.net/config/event/events.mdl
ZoneEventDetailsURL=http://azcdn.blob.core.windows.net/config/event/
ClubLobby=allegiancezone.cloudapp.net
Club=allegiancezone.cloudapp.net
ClubMessageURL=http://azcdn.blob.core.windows.net/config/club/motd.mdl
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
Site=http://azcdn.blob.core.windows.net
AutoUpdateURL=http://azcdn.blob.core.windows.net/autoupdate/Game/Server/standalone/AutoUpdate.exe
AutoUpdateCRC=$crc4
Directory=/autoupdate/Game/Server
FileListCRC = $crc3
FilelistSize = $size2


; THIS IS A VALID CONFIG FILE

};
close CFG;

open(CFG,">$azbp\\AZDev.cfg");

print CFG qq{[Allegiance]
PublicLobby=imago.buildvideogames.com
PublicMessageURL=http://azcdn.blob.core.windows.net/config/beta/motd.mdl
LobbyClientPort=2302
LobbyServerPort=2303
FilelistSite=http://azcdn.blob.core.windows.net
FilelistDirectory=/autoupdate/Game
FileListCRC = $crc
FilelistSize = $size
PublicMessageCRC = $crc2
TrainingURL=http://allegiancezone.com/#/Training
ZoneAuthGUID={00000000-0000-0000-C000-000000000046}
ZAuth=allegiancezone.cloudapp.net
UsePassport=0
PassportUpdateURL=http://allegiancezone.com
ZoneEventsURL=http://azcdn.blob.core.windows.net/config/event/events.mdl
ZoneEventDetailsURL=http://azcdn.blob.core.windows.net/config/event/
ClubLobby=allegiancezone.cloudapp.net
Club=allegiancezone.cloudapp.net
ClubMessageURL=http://azcdn.blob.core.windows.net/config/club/motd.mdl
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
Site=http://azcdn.blob.core.windows.net
AutoUpdateURL=http://azcdn.blob.core.windows.net/autoupdate/Game/Server/standalone/AutoUpdate.exe
AutoUpdateCRC=$crc4
Directory=/autoupdate/Game/Server
FileListCRC = $crc3
FilelistSize = $size2


; THIS IS A VALID CONFIG FILE

};
close CFG;
exit 0;
