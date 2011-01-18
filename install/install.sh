#!/bin/bash
echo "##########################################"
echo "#   Welcome to the MCWebmin installer!   #"	
echo "##########################################"
echo ""
echo "##########################################"
echo "#     This will install the latest       #"
echo "#    version of the MCWebmin software    #"
echo "##########################################"
echo "#########|Installer version 0.1|##########"
echo "##########################################"
echo
echo

ME="whoami"
if [ ! "$ME" = "root" ]; then
	echo "You must run this script as root (e.g. sudo install.sh)"
	exit
fi

echo "Would you like to install SUN Java? [Y/n]"
read INSTALLJAVA


#Instalation settings (do not change, if you dont know what you are doing)
DEPENDENCIES="zip unzip fastjar"
DOWNLOAD_LOCATION="http://s3.ndure.eu.s3.amazonaws.com"
USER="mcwebmin"
INSTALL_DIR="/usr/local/mcwebmin"

#Install java or not
if [ "$INSTALLJAVA" = "Y" ] || [ "$INSTALLJAVA" = "" ] || [ "$INSTALLJAVA" = "y" ]; then
	DEPENDENCIES="$DEPENDENCIES openjdk-6-jre-headless"
	INSTALLJAVA=true
fi

#Ask for web server
echo "What web server would you like to install/configure?"

OPTIONS="Apache2 Lighttpd[default] None"
select opt in $OPTIONS; do
	if [ "$opt" = "Apache2" ]; then
		DEPENDENCIES="$DEPENDENCIES apache2 php5"
		WEBSERVER="apache"
	elif [ "$opt" = "Lighttpd[default]" ]; then
		DEPENDENCIES="$DEPENDENCIES lighttpd"
		WEBSERVER="lighttpd"
	elif [ "$opt" = "None" ]; then
		echo "No webserver or configuration files will be installed!"
	elif [ "$opt" = "" ]; then
		DEPENDENCIES="$DEPENDENCIES lighttpd"
		WEBSERVER="lighttpd"
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
echo "Installing dependencies..."	
	apt-get -y install $DEPENDENCIES

#Download MCWebmin
echo "Downloading MCWebmin package"
	wget $DOWNLOAD_LOCATION/MCWebmin/MCWebmin.tar.gz

#Extract it
echo "Unpacking MCWebmin"
	tar -xf MCWebmin.tar.gz
echo "Done"

#Move it to the right directory
echo "Moving MCWebmin to $INSTALL_DIR"
	mv MCWebmin/ $INSTALL_DIR
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
		mv $INSTALL_DIR/install/lighttpd.conf /etc/lighttpd/lighttpd.conf
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
			
			echo "WARNING: MCWebmin is not designed to run under an Alias redirect. Altough this should not cause problems, we recommend using the VirtualHost option!"

			#Add selected user to the system
			USER="www-data"
			echo "Adding $USER to users"
			useradd $USER -M -d $INSTALL_DIR



			break
		else
			echo "Unknown entry, try again"
		fi
	done
fi

	


