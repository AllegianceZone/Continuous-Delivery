@echo off
C:
cd C:\deploy
set /p key=<key.txt
AzCopy C:\deploy\autoupdate https://azcdn.blob.core.windows.net/autoupdate /destkey:%key% /S /XO /Y
AzCopy C:\deploy\install https://azcdn.blob.core.windows.net/install /destkey:%key% /S /Y
AzCopy C:\deploy\config https://azcdn.blob.core.windows.net/config /destkey:%key% /S /XO /Y
