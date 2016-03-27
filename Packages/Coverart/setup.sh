#!/bin/bash
#
## Controls
## This is the full installation script including compilation
#
## This installs a number of files to show coverart and other backgrounds
## while MPD plays music files

pkgname=coverart
pkgver=1.0
pkgrel=1
declare -a depends=('x11-xserver-utils' 'gxmessage' 'imagemagick')

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
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/coverart.sh
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/YMPD
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/autostart
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/art.tar

# Install files
install -D -m755 -o=mpd -g=audio coverart.sh /var/lib/mpd/coverart.sh
install -D -m755 -o=mpd -g=audio YMPD /var/lib/mpd/Desktop/YMPD
install -D -m644 -o=mpd -g=audio autostart /var/lib/mpd/.config/lxsession/LXDE/autostart
tar -xf art.tar /var/lib/mpd

#Cleanup
cd /tmp
rm -rI $pkgname