#!/bin/bash
#Origin: http://s3.ndure.eu/MCWebmin/install.sh
echo "##########################################"
echo "#   Welcome to the MCWebmin installer!   #"	
echo "##########################################"
echo ""
echo "##########################################"
echo "#     This will install the latest       #"
echo "#    version of the MCWebmin software    #"
echo "##########################################"
echo "#########|Installer version 0.7.2|########"
echo "##########################################"
echo
echo


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Installation settings (do not change, unless you know what you are doing)
DEPENDENCIES="zip unzip screen wget openssl python" #Will not get installed if already installed
DOWNLOAD_LOCATION="http://cf.mcwebmin.com" #No last /
SERVER_DOWNLOAD_LOCATION="http://www.minecraft.net/download/minecraft_server.jar"
USER="mcwebmin"
INSTALL_DIR="/usr/local/mcwebmin" #No last /
#Import Distribution information file
. /etc/*-release

#Check if system is 64bit
if [ $(getconf LONG_BIT) = 64 ]; then
	BIT="x86_64"
else
	BIT="x86"
fi

#Detect linux Distro. If unsuccessful, ask for it.
#Only works for Ubuntu :/
if [ "$DISTRIB_ID" = "Debian" ] || [ "$DISTRIB_ID" = "Ubuntu" ]; then
	echo "Detected $DISTRIB_ID."
	DISTRO="Debian"
else
	echo "Could not detect Linux Distribution, or distribution not supported"
	echo "Are you running Debian based Linux with apt (Debian or Ubuntu) or RHEL based Linux with yum (Red Hat, CentOS, Fedora)?"
		select DISTRO in Debian RHEL; do
			echo "Selected $DISTRO"
			break
		done
fi

#Check if user wants to install Java
echo "Would you like to install OpenJDK (Java)? [Y/n]"
	read INSTALLJAVA

#Install java or not
if [ "$INSTALLJAVA" = "Y" ] || [ "$INSTALLJAVA" = "" ] || [ "$INSTALLJAVA" = "y" ]; then
	if [ "$DISTRO" = "Debian" ]; then
		DEPENDENCIES="$DEPENDENCIES openjdk-6-jre-headless"
		INSTALLJAVA=true
	elif [ "$DISTRO" = "RHEL" ]; then
		DEPENDENCIES="$DEPENDENCIES java-1.6.0-openjdk"
	fi
fi

echo "Would you like to update the system (recommended) [Y/n]?"
	read UPDATESYSTEM

echo "Would you like Minecraft to start when the computer starts? [Y/n]"
	read AUTOSTARTMC

#echo "Would you like MCWebmin to start when the computer starts? [Y/n]"
#	read AUTOSTARTWEB

echo "Would you like to download the newest version of minecraft_server.jar? [Y/n]"
	read DOWNLOADMINECRAFT

#Not finished yet
echo "Would you like to install the basic configuration? [Y/n]"
echo "Permissions Plugin"
echo "Essentials Plugin"
	read INSTALL_CONF_BASIC

#Not finished yet
echo "Would you like to install the magic pack? [Y/n]"
echo "Spells Plugin"
echo "Wand Plugin"
	read INSTALL_CONF_MAGIC

#Not finished yet
echo "Would you like to install the anti-grief pack?"
echo "Guardian Plugin"
echo ""

echo "Apart from installing the plugins, the script will also install a custom configuration for them, which you can later eddit."


#Ask for web server
echo "What web server would you like to install/configure?"

OPTIONS="Apache2 Lighttpd[default] None"
select opt in $OPTIONS; do
	if [ "$opt" = "Apache2" ]; then
		if [ "$DISTRO" = "Debian" ]; then
			DEPENDENCIES="$DEPENDENCIES libapache2-mod-php5 php5-cli php5-common php5-cgi" #apache2-mpm-itk
			WEBSERVER="apache"
		elif [ "$DISTRO" = "RHEL" ]; then
			DEPENDENCIES="$DEPENDENCIES httpd php php-cli"
			WEBSERVER="apache"
		fi
			break
	elif [ "$opt" = "Lighttpd[default]" ] || [ "$opt" = "" ]; then
		if [ "$DISTRO" = "Debian" ]; then
			DEPENDENCIES="$DEPENDENCIES lighttpd php5-cli php5-cgi"
			WEBSERVER="lighttpd"
			break
		elif [ "$DISTRO" = "RHEL" ]; then
			DEPENDENCIES="$DEPENDENCIES lighttpd php php-cli"
			WEBSERVER="lighttpd"	
		fi
		
	elif [ "$opt" = "None" ]; then
		echo "No webserver or configuration files will be installed!"
		break
	fi
done


#Set multiplexer password
echo "Set your multiplexer password (the one you will use to connect to this minecraft server)"
read -s -p "Password: " MULTIPLEXER_PASS


#Update the system if user wants to do so
if [ "$UPDATESYSTEM" = "Y" ] || [ "$UPDATESYSTEM" = "" ] || [ "$UPDATESYSTEM" = "y" ]; then
	if [ $DISTRO = "Debian" ]; then
		apt-get update
		apt-get -y upgrade
	elif [ $DISTRO = "RHEL" ]; then
		yum update
		yum upgrade
	fi
fi

#Install dependent paskage files
echo "Installing dependencies..."
if [ $DISTRO = "Debian" ]; then
	apt-get -y install $DEPENDENCIES
elif [ $DISTRO = "RHEL" ]; then
	yum -y install $DEPENDENCIES
fi

#Download MCWebmin
echo "Downloading MCWebmin package"
	wget -O MCWebmin.tar.gz $DOWNLOAD_LOCATION/MCWebmin/MCWebmin.tar.gz

#Extract it
echo "Unpacking MCWebmin"
	tar -xf MCWebmin.tar.gz
echo "Done"
echo "Removing the archive"
	rm MCWebmin.tar.gz
echo "Done"

#Move it to the right directory
echo "Moving MCWebmin to $INSTALL_DIR"
	mv MCWebmin/ $INSTALL_DIR
echo "Done"

#Install c10t, latest version.
echo "Installing c10t"
#	wget -q http://toolchain.eu/minecraft/c10t/releases/CURRENT
#	C10T_VERSION="cat CURRENT" #- not working
#	rm CURRENT
	
	#Install 64 or 32 bit
	wget -O c10t.tar.gz http://toolchain.eu/minecraft/c10t/releases/c10t-1.5-linux-$BIT.tar.gz
	tar -xf c10t.tar.gz
	mv c10t-*/ c10t
	mv c10t/ $INSTALL_DIR/

#Make multiplexer configuration
#I am lazy
echo "[java]" > mineremote.ini
echo "heap_max = 1024M" >> mineremote.ini
echo "gui = false" >> mineremote.ini
echo "heap_min = 1024M" >> mineremote.ini
echo "server = ./craftbukkit.jar" >> mineremote.ini
echo "" >> mineremote.ini
echo "[remote]" >> mineremote.ini
echo "socktype = tcp" >> mineremote.ini
echo "password = $MULTIPLEXER_PASS" >> mineremote.ini
echo "listenaddr = 127.0.0.1" >> mineremote.ini
#Move it to the right dir
mv mineremote.ini $INSTALL_DIR/minecraft/mineremote.ini

#If Lighttpd selected for install, configure it here.
if [ $WEBSERVER = "lighttpd" ]; then
	#Download configuration
	wget -O lighttpd.conf.org $DOWNLOAD_LOCATION/MCWebmin/lighttpd.conf
	echo "Adding $USER to users"
	useradd -d $INSTALL_DIR $USER
	chown -R $USER:$USER $INSTALL_DIR
	
	#Set Lighttpd port
	echo "What port would you like to use for Lighttpd? [80]"
		read LIGHTTPDPORT

	if [ "$LIGHTTPDPORT" = "" ]; then
				LIGHTTPDPORT="80"
	fi
	
	echo "server.port                 = $LIGHTTPDPORT" > lighttpd.conf
	cat lighttpd.conf.org >> lighttpd.conf
	rm lighttpd.conf.org
	
	#Generate certificate
	echo "Generating certificate"
	echo "#############################################"
	echo "#Press enter on all cases, defaults are fine#"
	echo "#############################################"
		openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
			chown $USER:$USER server.pem
			chmod 0600 server.pem
			mv server.pem $INSTALL_DIR/server.pem
	echo "Done, certificate is valid for 1 year"
	echo "Copying Lighttpd configuration"
		mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.bak
		mv lighttpd.conf /etc/lighttpd/lighttpd.conf
	echo "Changing Ownership of folders"
		chown -R $USER:$USER /var/log/lighttpd/
		chown -R $USER:$USER /var/run/lighttpd/
	echo "Done"
	#Reload configuration
	/etc/init.d/lighttpd reload

#If Apache2 selected, configure it here.
elif [ $WEBSERVER = "apache" ]; then
	echo "Do you want to configure apache to run MCWebmin as a VirtualHost (recommended, e.g. domain/subdomain/port: minecraft.example.net) or an Alias (e.g. example.com/minecraft)"
	OPTIONS="VirtualHost Alias"
	select opt in $OPTIONS; do
		if [ "$opt" = "VirtualHost" ]; then
			wget -O apache.vhost $DOWNLOAD_LOCATION/MCWebmin/apache.vhost
			echo "What domain do you want MCWebmin to answer to (optional)?"
				read DOMAIN
			echo "What port would you like to use? [80]"
				read APACHEPORT	
			if [ "$APACHEPORT" = "" ]; then
				APACHEPORT="80"
			fi
			
			#Set virtual host file name
			if [ -z "$DOMAIN" ]; then
				VHOST_FILE="mcwebmin.vhost"
			else
				VHOST_FILE=$DOMAIN
			fi
			
			#Add Listen directive
			if [ "$APACHEPORT" != "80" ]; then
				echo "Listen $APACHEPORT" > $VHOST_FILE
			fi

			#Add config start
			echo "<VirtualHost *:$APACHEPORT>" >> $VHOST_FILE

			if [ "$DOMAIN" != "" ]; then				
				echo "	ServerName $DOMAIN" >> $VHOST_FILE
			fi

			echo "Your email address (optional):"
				read EMAILADDR
					if [ ! $EMAILADDR = "" ]; then
						echo "	ServerAdmin $EMAILADDR" >> $VHOST_FILE
					fi

			cat apache.vhost >> $VHOST_FILE
			rm apache.vhost

			#Move to virtual host to the apache sites-available dir
			mv $VHOST_FILE /etc/apache2/sites-available/

			#Enable the VH
			a2ensite $VHOST_FILE			

			#Add selected user to the system
			useradd -d $INSTALL_DIR $USER
			chown -R $USER:$USER $INSTALL_DIR
			
			break
		elif [ "$opt" = "Alias" ]; then
			wget -O apache.alias $DOWNLOAD_LOCATION/MCWebmin/apache.alias
			echo "What Alias do you want to use? [/minecraft]"
				read WHICHALIAS
					if [ "$WHICHALIAS" = "" ]; then
						ALIAS="/minecraft"
					fi
			echo "	Alias $ALIAS /usr/local/mcwebmin/www" > minecraft.conf
			cat apache.alias >> minecraft.conf
			rm apache.alias
			
			echo "WARNING: MCWebmin is not designed to run under an Alias redirect."
			echo "Altough this should not cause problems, we recommend using the VirtualHost option!"

			#Add selected user to the system
			USER="www-data"

			break
		else
			echo "Unknown entry, try again"
		fi
	done
	#Restart Apache2
	/etc/init.d/apache2 reload
fi

#init.d configuration
echo "Starting init.d configuration"
wget $DOWNLOAD_LOCATION/MCWebmin/minecraft-init
echo "Moving the script to /etc/init.d"
	mv minecraft-init /etc/init.d/minecraft
	chmod +x /etc/init.d/minecraft
echo "Done"

#Add init.d script to startup, if requested by user
if [ "$AUTOSTARTMC" = "Y" ] || [ "$AUTOSTARTMC" = "" ] || [ "$AUTOSTARTMC" = "y" ]; then
	update-rc.d minecraft defaults
fi

#Update minecraft if user wanted to
if [ "$DOWNLOADMINECRAFT" = "Y" ] || [ "$DOWNLOADMINECRAFT" = "" ] || [ "$DOWNLOADMINECRAFT" = "y" ]; then
	wget -O $INSTALL_DIR/minecraft/minecraft_server.jar.update $SERVER_DOWNLOAD_LOCATION

	if [ -f $INSTALL_DIR/minecraft/minecraft_server.jar.update ]; then
		mv $INSTALL_DIR/minecraft/minecraft_server.jar.update $INSTALL_DIR/minecraft/minecraft_server.jar
		chown $USER\: $INSTALL_DIR/minecraft/minecraft_server.jar
		echo "Minecraft successfully updated."
	else
		echo "Minecraft update could not be downloaded."
	fi
fi


#Last minute adjustments
/etc/init.d/minecraft start

echo
echo
echo
echo "Instalation completed, enjoy your new MCWebmin supported minecraft server!"

exit
