@echo off
cd %2\Allegiance
git clean -fd
git checkout -f
git pull origin master
git checkout %1
cd %2\Artwork
git pull
cd %2\Artwork_minimal
git pull
cd %2\Artwork_detailed
git pull
