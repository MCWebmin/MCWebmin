#!/bin/bash

#DIRECTORY="/usr/local/mcwebmin/"

#cd $DIRECTORY

#Download minecraft server
if [ ! -e "minecraft_server.jar" ]
then
    wget http://minecraft.net/download/minecraft_server.jar
    echo "Download completed"
else
    echo "It exists"
fi

#Download runecraft
if [ ! -e "runecraft_latest.zip" ]
then
    wget http://llama.cerberusstudios.net/runecraft_latest.zip
    echo "Download completed"
else
    echo "It exists"
fi

# Unzips runecraft to a directory
unzip runecraft_latest.zip -d runecraft/
# Adds all of the files to the minecraft jar
cd runecraft/
jar uvf ../minecraft_server.jar ./*
cd ..
# Cleans up
rm -r runecraft/ runecraft_latest.zip

