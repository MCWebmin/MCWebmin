#!/bin/bash
echo "##########################################"
echo "#   Welcome to the MCWebmin installer!   #"	
echo "##########################################"
echo ""
echo "##########################################"
echo "#     This will install the latest       #"
echo "#    version of the MCWebmin software    #"
echo "##########################################"
echo "#########|Installer version 0.2|##########"
echo "##########################################"
echo
echo


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Would you like to install SUN Java? [Y/n]"
read INSTALLJAVA


#Instalation settings (do not change, if you dont know what you are doing)
DEPENDENCIES="zip unzip fastjar"
DOWNLOAD_LOCATION="http://s3.ndure.eu"
USER="mcwebmin"
INSTALL_DIR="/usr/local/mcwebmin"

#Install java or not
if [ "$INSTALLJAVA" = "Y" ] || [ "$INSTALLJAVA" = "" ] || [ "$INSTALLJAVA" = "y" ]; then
	DEPENDENCIES="$DEPENDENCIES sun-java6-jre"
	INSTALLJAVA=true
fi

#Ask for web server
echo "What web server would you like to install/configure?"

OPTIONS="Apache2 Lighttpd[default] None"
select opt in $OPTIONS; do
	if [ "$opt" = "Apache2" ]; then
		DEPENDENCIES="$DEPENDENCIES apache2 php5 apache2-mpm-itk"
		WEBSERVER="apache"
		break
	elif [ "$opt" = "Lighttpd[default]" ]; then
		DEPENDENCIES="$DEPENDENCIES lighttpd"
		WEBSERVER="lighttpd"
		break
	elif [ "$opt" = "None" ]; then
		echo "No webserver or configuration files will be installed!"
		break
	elif [ "$opt" = "" ]; then
		DEPENDENCIES="$DEPENDENCIES lighttpd"
		WEBSERVER="lighttpd"
		break
	fi
done

echo "Would you like to update the system (recomended) [Y/n]?"
	read UPDATESYSTEM
#Update the system if user wants to do so
if [ "$UPDATESYSTEM" = "Y" ] || [ "$UPDATESYSTEM" = "" ] || [ "$UPDATESYSTEM" = "y" ]; then
	apt-get update
	apt-get -y upgrade
fi


#Install dependent paskage files

echo "Dependencies to be installed: $DEPENDENCIES"
read 
echo "Installing dependencies..."	
	apt-get -y install $DEPENDENCIES

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
	chown -r mcwebmin\: /usr/local/mcwebmin/
echo "Done"

#If Lighttpd selected for install, configure it here.
if [ $WEBSERVER = "lighttpd" ]; then
	wget -O lighttpd.conf $DOWNLOAD_LOCATION/MCWebmin/lighttpd.conf
	echo "Adding $USER to users"
	useradd $USER -M -d $INSTALL_DIR
	echo "Generating certificate"
	echo "Press enter on all cases, defaults are fine"
		openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
			chown mcwebmin:mcwebmin server.pem
			chmod 0600 server.pem
			mv server.pem $INSTALL_DIR/server.pem
	echo "Done, certificate is valid for 1 year"
	echo "Copying Lighttpd configuration"
		mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.bak
		mv lighttpd.conf /etc/lighttpd/lighttpd.conf
	echo "Done"
#If Apache2 selected, configure it here.
elif [ $WEBSERVER = "apache" ]; then
	echo "Do you want to configure apache to run minecraft as a VirtualHost (recommended, e.g. domain/subdomain: minecraft.example.net) or an Alias (e.g. example.com/minecraft)"
	OPTIONS="VirtualHost Alias"
	select opt in $OPTIONS; do
		if [ "$opt" = "VirtualHost" ]; then
			wget -O apache.vhost $DOWNLOAD_LOCATION/MCWebmin/apache.vhost
			echo "What domain do you want to use?"
				read DOMAIN
			echo "<VirtualHost *:80>" > $DOMAIN
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
			echo "Adding $USER to users"
			useradd $USER -M -d $INSTALL_DIR

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
			
			echo "WARNING: MCWebmin is not designed to run under an Alias redirect. Altough this should not cause problems, we recommend using the VirtualHost option! If you"

			#Add selected user to the system
			USER="www-data"

			break
		else
			echo "Unknown entry, try again"
		fi
	done
	#Restart Apache2
	/etc/init.d/apache2 restart
fi

#init.d configuration

echo "Starting init.d configuration"
wget $DOWNLOAD_LOCATION/MCWebmin/minecraft-init
echo "Moving the script to /etc/init.d"
	mv minecraft-init /etc/init.d/minecraft
	chmod +x /etc/init.d/minecraft
echo "Done"


echo "Would you like minecraft to start when the computer starts? [Y/n]"
	read AUTOSTART

if [ "$AUTOSTART" = "Y" ] || [ "$UAUTOSTART" = "" ] || [ "$AUTOSTART" = "y" ]; then
	update-rc.d minecraft defaults
fi


#Last minute adjustments




echo "Instalation completed, enjoy your new MCWebmin supported minecraft server!"









