#!/bin/bash
#
## i2select
## This is the full installation script
#
## I2Select is a package from ArchPhile.
## http://archphile.org
## It has a Arch installer, but not for Debian
## This script replicates the installer for Debian for now

pkgname=i2select
pkgver=1
pkgrel=1

cd /tmp

mkdir -p $pkgdir/opt/i2select/

#Get the main files
wget https://raw.githubusercontent.com/archphile/packages/master/i2select/i2select -O /usr/bin/i2select
wget https://raw.githubusercontent.com/archphile/packages/master/i2select/unmute.orig -O /opt/i2select/unmute.orig
wget https://raw.githubusercontent.com/archphile/packages/master/i2select/unmute.berryplus -O /opt/i2select/unmute.berryplus 
#wget https://raw.githubusercontent.com/archphile/packages/master/i2select/mpd.conf.i2s -O /opt/i2select/mpd.conf.i2s
#wget https://raw.githubusercontent.com/archphile/packages/master/i2select/mpd.conf.orig -O /opt/i2select/mpd.conf.orig
wget https://raw.githubusercontent.com/archphile/packages/master/i2select/config.txt.orig -O /opt/i2select/config.txt.orig

#For now, we will use the MPD conf for this project.
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPD/mpd.conf -O /opt/i2select/mpd.conf.i2s
cp /opt/i2select/mpd.conf.i2s /opt/i2select/mpd.conf.orig

chmod +x "$pkgdir"/usr/bin/i2select
chmod +x "$pkgdir"/opt/i2select/unmute.berryplus

/usr/bin/i2select
