#!/bin/bash

export TOOLCHAINS=swift

cd ..

rm -r ./.build 
rm -r ./WatsonWeatherBot.xcodeproj
rm -r ./Kitura-Build
sudo rm -r ./Packages

# the line below may need to be invoked so uncomment if needed
git submodule add -f https://github.com/IBM-Swift/Kitura-Build.git

swift build -X

make run

