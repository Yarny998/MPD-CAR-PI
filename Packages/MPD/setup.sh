#!/bin/bash
#
## MPD
## This is the full installation script including compilation
#
# Website http://www.musicpd.org/
#
# Configuration file based on ARCHPHILE

pkgname=mpd
pkgver=1.2.3
pkgrel=1
declare -a depends=("mpd" "mpc")

echo "Installing $pkgname"

#Dependencies
for deppkg in "${depends[@]}"
do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $deppkg|grep "install ok installed")
    echo Checking for package: $deppkg
    if [ "" == "$PKG_OK" ]; then
        echo Installing package: $deppkg
        aptitude install $deppkg
    else
        echo Package already installed: $deppkg
    fi
done

cd /tmp

#Get the config file and service file
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPD/mpd.conf

# Install config files
install -Dm644  mpd.conf /etc/mpd.conf

#Enable and start the service
systemctl enable mpd.service
systemctl start mpd.service
systemctl status mpd.service

sleep 5

#Update the database
mpc update

#Cleanup
rm mpd.conf
