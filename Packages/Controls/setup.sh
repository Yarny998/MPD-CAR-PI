#!/bin/bash
#
## Controls
## This is the full installation script including compilation
#
## This installs 4 packages
##     A rotary encoder for volume control thanks to iqaudio
##     http://www.iqaudio.co.uk
##
##     A program to receive input from a switch
##     C program written by Chris Yarnold
##     
##     Listeners for mute from an external source (eg Bluetooth) and when the lights are turned on

pkgname=controls
pkgver=1.0
pkgrel=1
declare -a depends=("wiringpi")

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
mkdir $pkgname
cd $pkgname

#Get the main install base and compile
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/buttons.c
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/buttons.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/buttons.service

wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/mute.c
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/mute.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/mute.service

wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/lights.c
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/lights.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/lights.service

wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/IQAudio/IQ_rot.service
wget https://raw.githubusercontent.com/iqaudio/tools/master/IQ_rot.c

#Compile
gcc IQ_rot.c -oIQ_rot -lwiringPi -lasound
gcc buttons.c -obuttons -lwiringPi
gcc mute.c -omute -lwiringPi
gcc lights.c -olights -lwiringPi

# Install files
install -D -m755 IQ_rot /usr/bin/iqaudio/IQ_rot
install -D -m644 IQ_rot.service /etc/systemd/system/IQ_rot.service

install -D -m755 buttons /usr/bin/controls/buttons
install -D -m644 buttons.conf /etc/buttons.conf
install -D -m644 buttons.service /etc/systemd/system/buttons.service

install -D -m755 mute /usr/bin/controls/mute
install -D -m644 mute.conf /etc/mute.conf
install -D -m644 mute.service /etc/systemd/system/mute.service

install -D -m755 lights /usr/bin/controls/lights
install -D -m644 lights.conf /etc/lights.conf
install -D -m644 lights.service /etc/systemd/system/lights.service

# Start Services
systemctl enable IQ_rot.service
systemctl start IQ_rot.service &
systemctl status IQ_rot.service

systemctl enable buttons.service
systemctl start buttons.service
systemctl status buttons.service

systemctl enable mute.service
systemctl start mute.service
systemctl status mute.service

systemctl enable lights.service
systemctl start lights.service
systemctl status lights.service

#Cleanup
cd /tmp
rm -rI $pkgname
