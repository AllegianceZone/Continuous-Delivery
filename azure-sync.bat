@echo off
E:
cd E:\alleg_build\cdn
set /p key=<key.txt
echo starting cdn/autoupdate
"C:\Program Files (x86)\Microsoft SDKs\Azure\AZCopy\AzCopy" /Source:E:\alleg_build\cdn\autoupdate /Dest:http://azcdn.blob.core.windows.net/autoupdate /destkey:%key% /S /XO /Y
echo starting cdn/install
"C:\Program Files (x86)\Microsoft SDKs\Azure\AZCopy\AzCopy" /Source:E:\alleg_build\cdn\install /Dest:http://azcdn.blob.core.windows.net/install /destkey:%key% /S /XO /Y /NC:2
echo starting cdn/config
"C:\Program Files (x86)\Microsoft SDKs\Azure\AZCopy\AzCopy" /Source:E:\alleg_build\cdn\config /Dest:http://azcdn.blob.core.windows.net/config /destkey:%key% /S /XO /Y
"C:\Program Files (x86)\Microsoft SDKs\Azure\AZCopy\AzCopy" /Source:E:\alleg_build\Artwork_event\config /dest:http://azcdn.blob.core.windows.net/config /destkey:%key% /S /Y
echo done with azure cdn