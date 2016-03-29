#!/bin/bash
#
## MPDScribble
## This is the full installation script including compilation
#
## This installs MPDScribble to scrobble MPD plays to LAST.FMa number of files to show coverart and other backgrounds
## while MPD plays music files

pkgname=mpdscribble
pkgver=1.0
pkgrel=1
declare -a depends=('libglib2.0-dev' 'libcurl4-openssl-dev')

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
wget http://www.musicpd.org/download/mpdscribble/0.22/mpdscribble-0.22.tar.bz2

# Extract installation
tar -xf mpdscribble-0.22.tar.bz2
cd mpdscribble-0.22

# Compile and install
mkdir /var/lib/mpd/mpdscribble
mkdir /var/log/mpdscribble
./configure --sysconfdir=/etc --enable-debug
make install

# Install and start the service
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPDScribble/mpdscribble.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPDScribble/mpdscribble.service

install -D -m644 mpdscribble.conf /etc/mpdscribble.conf
install -D -m755 mpdscribble.service /etc/systemd/system/mpdscribble.service
systemctl enable mpdscribble.service
systemctl start mpdscribble.service
systemctl status mpdscribble.service

# Cleanup
cd /tmp
rm -rI $pkgname

# Further Instructions
echo "You must hash and insert your last.fm username and password into /etc/mpdscribble.conf"
sleep 5
