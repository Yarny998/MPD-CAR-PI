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

#Dependencies
aptitude install mpd mpc

cd /tmp

#Get the config file and service file
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPD/mpd.conf

# Install config files
install -Dm644  mpd.conf /etc/mpd.conf

#Enable and start the service
systemctl restart mpd.service
systemctl status mpd.service

#Cleanup
rm mpd.conf
