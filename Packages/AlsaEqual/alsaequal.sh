#!/bin/bash
#
## Mongoose
## This is the full installation script including compilation
#

pkgname=alsaequal
pkgver=0.6
pkgrel=2

#Dependencies for mongoose
aptitude install caps libasound2-dev

cd /tmp

#Get the main install base and compile
wget http://www.thedigitalmachine.net/tools/$pkgname-$pkgver.tar.bz2
tar -xvf $pkgname-$pkgver.tar.bz2

cd $pkgname

# Patch some files (per ArchPhil playground install
# Makefile
sed 's/-m 644 $(SND/-m 755 $(SND/' -i Makefile

#ctl_equal.c
sed 's/module = "Eq"/module = "Eq10"/' -i ctl_equal.c
sed 's/if(equal->klass->PortDescriptors\[index\] !=/if(equal->klass->PortDescriptors\[index\] \&/' -i ctl_equal.c
sed 's/(LADSPA_PORT_INPUT | LADSPA_PORT_CONTROL)) {/(LADSPA_PORT_INPUT | LADSPA_PORT_CONTROL) == 0) {/' -i ctl_equal.c

#pcm_equal.c
sed 's/module = "Eq"/module = "Eq10"/' -i pcm_equal.c

#Compile
make
install -dm755 "/usr/lib/alsa-lib"
make install
cp /usr/lib/alsa-lib/*so /usr/lib/arm-linux-gnueabihf/alsa-lib

#Cleanup
cd /tmp
rm $pkgname-$pkgver.tar.bz2
rm -r $pkgname

#Get the config file and service file
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/AlsaEqual/asound.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/AlsaEqual/.alsaequal.bin.1

# Install files
install -D -m644 asound.conf "/etc/asound.conf"
install -D -m644 .alsaequal.bin.1 "/var/lib/mpd/.alsaequal.bin.1"

#make a copy of the standard settings
cp /var/lib/mpd/.alsaequal.bin /var/lib/mpd/.alsaequal.bin.std

#Cleanup
rm asound.conf
rm .alsaequal.bin.1
