#!/bin/bash

#DIRECTORY="/usr/local/mcwebmin/"

#cd $DIRECTORY

#Download minecraft server
if [ ! -e "minecraft_server.jar" ]
then
    wget http://minecraft.net/download/minecraft_server.jar
    echo "Download completed!"
else
    echo "It exists, moving on"
fi

# Download Hey0 Mod
if [ ! -e "hmod.zip" ]
then
    wget -O hmod.zip http://hey0.net/get.php?dl=serverbeta
    echo "Download completed!"
else
    echo "It exists, moving on"
fi


unzip hmod.zip -d hmod/

# Adds hmod to minecraft_server.jar
unzip hmod/bin/Minecraft_Mod.jar -d hmodjar/
cd hmodjar/
rm Main.class
jar uvf ../minecraft_server.jar ./*
cd ..

# Update manifest - not sure if needed, must test
jar umf hmod_manifest minecraft_server.jar

mkdir plugins/

# Clean up
rm -r hmod/ hmodjar/ hmod.zip
