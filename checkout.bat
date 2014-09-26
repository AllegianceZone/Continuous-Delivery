@echo off
cd C:\build\Allegiance
git clean -fd
git checkout -f
git pull origin master
git checkout %1
cd C:\build\Artwork
git pull
cd C:\build\Artwork_minimal
git pull