#Imago <imagotrigger@gmail.com>
# Inserts build time/ver info into the MODTD

use strict;
use POSIX qw(strftime);

print "Updating MOTD\n";

my $now = strftime("%Y/%m/%d %H:%M:%S",localtime(time));
my ($build, $revision) = @ARGV;
my $modtime= (stat("C:\\build\\Package\\Release.7z"))[9];
my $notoctal = strftime( '%y.%m.%d', localtime($modtime));

my $mdl = qq{use "effect";
use "font";
use "model";

yellow = Color(0.978, 0.773, 0);
lightgray = Color(0.6,0.6,0.6);
gray = Color(0.4,0.4,0.4);
darkgray = Color(0.2,0.2,0.2);
outline = Color(0.6,0.0,0.0);


// BEGIN PROGRAM GENERATED SECTION

logo = ImportImage("nebplnt02bmp", true);

txtBanner = "Welcome to the Allegiance Zone server\\n";
txtUpdated = "Current builds: $notoctal (b${build}_$revision)\\nMake sure you are using the latest: Press Esc and compare with the above\\n\\n";
txtPrimaryHdg = "This message last updated $now\\nAZ R8 beta has been released";
txtPrimaryTxt = "\\nWatch this space for AZ R8 beta updates\\nP-Core v6 IS OUT!\\n";
txtSecondaryHdg = "\\nBeta Test Wed's are NOT BACK\\n\\n";
txtSecondaryTxt = "\\nCome to irc.quakenet.org #FreeAllegiance!\\n";
txtDetails = "AZ Team Members\\n--------------------------\\nAstn\\nImago\\n---------------------\\nWith special thanks to all previous devs and server admins.\\nogg decoder by Xiph.org";
txtPadding      = "\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n";

// END PROGRAM GENERATED SECTION


imgLogo = TranslateImage(logo,Point(Subtract(260,Divide(PointX(ImageSize(logo)),2)),Subtract(0,Divide(PointY(ImageSize(logo)),2))));

imgBanner = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, white, txtBanner),Point(5,0)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(4,-1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(5,-1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(6,-1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(4,0)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(6,0)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(4,1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(5,1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, outline, txtBanner),Point(6,1)),
   TranslateImage(StringImage(JustifyCenter, 511, hugeBoldFont, darkgray, txtBanner),Point(7,-2))
]);

imgUpdated = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, yellow, txtUpdated), Point(5,Subtract(0,PointY(ImageSize(imgBanner))))),
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, black, txtUpdated), Point(6,Subtract(-1,PointY(ImageSize(imgBanner)))))
]);

imgPrimaryHdg = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, lgBoldVerdana, yellow, txtPrimaryHdg), Point(5,Subtract(0,PointY(ImageSize(imgUpdated))))),
   TranslateImage(StringImage(JustifyCenter, 511, lgBoldVerdana, black, txtPrimaryHdg),Point(6,Subtract(-1,PointY(ImageSize(imgUpdated)))))
]);

imgPrimaryTxt = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, lgBoldVerdana, white, txtPrimaryTxt), Point(5,Subtract(0,PointY(ImageSize(imgPrimaryHdg))))),
   TranslateImage(StringImage(JustifyCenter, 511, lgBoldVerdana, black, txtPrimaryTxt),Point(6,Subtract(-1,PointY(ImageSize(imgPrimaryHdg)))))
]);

imgSecondaryHdg = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, yellow, txtSecondaryHdg), Point(5,Subtract(0,PointY(ImageSize(imgPrimaryTxt))))),
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, black, txtSecondaryHdg), Point(6,Subtract(-1,PointY(ImageSize(imgPrimaryTxt)))))
]);

imgSecondaryTxt = GroupImage

([
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, white, txtSecondaryTxt), Point(5,Subtract(0,PointY(ImageSize(imgSecondaryHdg))))),
   TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, black, txtSecondaryTxt),   Point(6,Subtract(-1,PointY(ImageSize(imgSecondaryHdg)))))
]);

imgDetails = GroupImage

([
   TranslateImage(StringImage(JustifyLeft, 511, medBoldVerdana, white, txtDetails), Point(5,Subtract(0,PointY(ImageSize(imgSecondaryTxt))))),
   TranslateImage(StringImage(JustifyLeft, 511, medBoldVerdana, black, txtDetails), Point(6,Subtract(-1,PointY(ImageSize(imgSecondaryTxt)))))
]);

imgPadding = TranslateImage(StringImage(JustifyCenter, 511, medBoldVerdana, white, txtPadding), Point(5,Subtract(0,PointY(ImageSize(imgDetails)))));


textImage = GroupImage([imgBanner,imgUpdated,imgPrimaryHdg,imgPrimaryTxt,imgSecondaryHdg,imgSecondaryTxt,imgDetails,imgPadding,imgLogo]);

textPosition = Point(5, Subtract(PointY(ImageSize(textImage)),200));

image = TranslateImage(textImage,textPosition);


// The following line is required (and preferably be at the end):
// THIS IS A VALID MESSAGE OF THE DAY FILE  

};

open(MOTD,">C:\\build\\motd.mdl");
print MOTD $mdl;
close MOTD;

exit 0;
