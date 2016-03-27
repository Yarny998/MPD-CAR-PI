#!/bin/bash
#
## Controls
## This is the full installation script including compilation
#
## This installs 2 packages
## One to control a rotary encoder for volume control thanks to iqaudio
## http://www.iqaudio.co.uk
## The other is a program to receive input from a switch
## C program written by Chris Yarnold

pkgname=controls
pkgver=1.0
pkgrel=1
declare -a depends=("wiringpi")

#Dependencies
for deppkg in "${depends[@]}"
do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $deppkg|grep "install ok installed")
    echo Checking for package: $deppkg
    if [ "" == "$PKG_OK" ]; then
        echo Installing package: $deppkg
        sptitude install $deppkg
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
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/IQAudio/IQ_rot.service
wget https://raw.githubusercontent.com/iqaudio/tools/master/IQ_rot.c

#Compile
gcc IQ_rot.c -oIQ_rot -lwiringPi -lasound
gcc buttons.c -obuttons -lwiringPi

# Install files
install -D -m755 IQ_rot /usr/bin/iqaudio/IQ_rot
install -D -m644 IQ_rot.service /etc/systemd/system/IQ_rot.service
install -D -m755 buttons /usr/bin/buttons/buttons
install -D -m644 buttons.conf /etc/buttons.conf
install -D -m644 buttons.service /etc/systemd/system/buttons.service

systemctl enable IQ_rot.service
systemctl start IQ_rot.service &
systemctl status IQ_rot.service

systemctl enable buttons.service
systemctl start buttons.service
systemctl status buttons.service

#Cleanup
cd /tmp
rm -rI $pkgname
