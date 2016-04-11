#!/bin/bash
#
## Touchscreen
## This is the full installation script including compilation
#
## This installs xinput-callibrator from Tias
## It assumes use of a touchscreen module such as the arduino AR1100
## Instructions were from Engineering DIY
##     http://engineering-diy.blogspot.com.au/2013/01/adding-7inch-display-with-touchscreen.html
## Following the installation, follow the steps from the above site

pkgname=touchscreen
pkgver=1.0
pkgrel=1

echo "Installing $pkgname"

cd /tmp
mkdir $pkgname
cd $pkgname

#Get the main install base and compile
wget http://github.com/downloads/tias/xinput_calibrator/xinput_calibrator-0.7.5.tar.gz

#Compile
tar –xvf xinput_calibrator-0.7.5.tar.gz
cd xinput_calibrator-0.7.5
./configure
Make
Makeinstall

# Display help and exit
echo "You must now run Xinput_calibrator, then copy the output to /usr/share/X11/xorg.conf.d/01-input.conf"
echo "See http://engineering-diy.blogspot.com.au/2013/01/adding-7inch-display-with-touchscreen.html for details"
echo "It may also be helpful to addin EmulateThirdButton support. See Readme for more information"
sleep 5
#Cleanup
cd /tmp
rm -rI $pkgname
