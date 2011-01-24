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
echo "#########|Installer version 0.6|########"
echo "##########################################"
echo
echo


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


#Ask for Linux Distro?
#Need to make this automatic. Use "cat /etc/*-release" and then something else
echo "Are you running Debian based Linux with apt (Debian or Ubuntu) or RHEL based Linux with yum (Red Hat, CentOS, Fedora)?"
	select DISTRO in Debian RHEL; do
		echo "Selected $DISTRO"
		break
	done

#Check if user wants to install Java
echo "Would you like to install OpenJDK (Java)? [Y/n]"
	read INSTALLJAVA

#Installation settings (do not change, unless you know what you are doing)
DEPENDENCIES="zip unzip screen wget openssl"
DOWNLOAD_LOCATION="http://s3.ndure.eu" #No last /
SERVER_DOWNLOAD_LOCATION="http://s3.ndure.eu/MCWebmin/minecraft_server.jar"
USER="mcwebmin"
INSTALL_DIR="/usr/local/mcwebmin" #No last /

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

echo "Would you like MCWebmin to start when the computer starts? [Y/n]"
	read AUTOSTARTWEB

echo "Would you like to download the newest version of minecraft_server.jar? [Y/n]"
	read DOWNLOADMINECRAFT


#Ask for web server
echo "What web server would you like to install/configure?"

OPTIONS="Apache2 Lighttpd[default] None"
select opt in $OPTIONS; do
	if [ "$opt" = "Apache2" ]; then
		if [ "$DISTRO" = "Debian" ]; then
			DEPENDENCIES="$DEPENDENCIES apache2 php5 php5-cgi apache2-mpm-itk"
			WEBSERVER="apache"
		elif [ "$DISTRO" = "RHEL" ]; then
			DEPENDENCIES="$DEPENDENCIES httpd php php-cli"
			WEBSERVER="apache"
		fi
			break
	elif [ "$opt" = "Lighttpd[default]" ] || [ "$opt" = "" ]; then
		if [ "$DISTRO" = "Debian" ]; then
			DEPENDENCIES="$DEPENDENCIES lighttpd php5-cgi"
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
	wget $DOWNLOAD_LOCATION/MCWebmin/MCWebmin.tar.gz

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

#If Lighttpd selected for install, configure it here.
if [ $WEBSERVER = "lighttpd" ]; then
	wget -O lighttpd.conf $DOWNLOAD_LOCATION/MCWebmin/lighttpd.conf
	echo "Adding $USER to users"
	useradd -d $INSTALL_DIR $USER
	chown -R $USER:$USER $INSTALL_DIR
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
	echo "Making Lighttpd Folders"
		mkdir /var/run/lighttpd/
		mkdir /var/log/lighttpd/
	echo "Changing Ownership of folders"
		chown -R $USER:$USER /var/log/lighttpd/
		chown -R $USER:$USER /var/run/lighttpd/
	echo "Done"
	#Reload configuration
	/etc/init.d/lighttpd reload

#If Apache2 selected, configure it here.
elif [ $WEBSERVER = "apache" ]; then
	echo "Do you want to configure apache to run minecraft as a VirtualHost (recommended, e.g. domain/subdomain/port: minecraft.example.net) or an Alias (e.g. example.com/minecraft)"
	OPTIONS="VirtualHost Alias"
	select opt in $OPTIONS; do
		if [ "$opt" = "VirtualHost" ]; then
			wget -O apache.vhost $DOWNLOAD_LOCATION/MCWebmin/apache.vhost
			echo "What domain do you want MCWebmin to answer to?"
				read DOMAIN
			echo "What port would you like to use? [80]"
				read MCWPORT	
			if [ "$MCWPORT" = "" ]; then
				MCWPORT="80"
			fi
			echo "<VirtualHost *:$MCWPORT>" > $DOMAIN
			echo "	ServerName $DOMAIN" >> $DOMAIN
			echo "Your email address (optional):"
				read EMAILADDR
					if [ ! $EMAILADDR = "" ]; then
						echo "	ServerAdmin $EMAILADDR" >> $DOMAIN
					fi
			cat apache.vhost >> $DOMAIN
			rm apache.vhost

			#Move to virtual host to the apache sites-available dir
			mv $DOMAIN /etc/apache2/sites-available/

			#Enable the VH
			a2ensite $DOMAIN			

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
