#TODO
# - Make this the first step in the bitten recipe
# - Check for a drop file indicating if tools have been upgraded (if not, continue below)
# - pull https://github.com/AllegianceZone/Continuous-Delivery to C:\build\Continuous-Delivery
# - replace everything from C:\build\Continuous-Delivery to C:\build (dont need to take subdirectories)
# - ftp the contents of C:\build\Continuous-Delivery\az to allegiancezone.cloudapp.net:21122 /
# - LWP our way to admin session and POST C:\build\Continuous-Delivery\trac\bitten.xml to http://trac.allegiancezone.com/admin/bitten/configs/Allegiance
# - using same admin session from above invalidate our current build
# - drop a file indicating tools have been updated
# - kill bitten-slave, it will automatically restart and skip the tool updating/bitten-slave killing step
# - Make a second step in the bitten recipe that deletes our drop file indicating tools can be updated again
# - Profit?