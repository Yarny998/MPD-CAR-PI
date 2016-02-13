#!/bin/bash
#
## YMPD
## This is the full installation script including compilation
#
# Website www.ympd.org

pkgname=ympd
pkgver=1.2.3
pkgrel=1
pkgpath="https://github.com/notandy/ympd/archive"
pkgfile="master.zip"
unzipdir="ympd-master"

#Dependencies
aptitude install cmake libmpdclient-dev

cd /tmp

#Get the main install base and compile
wget https://github.com/notandy/ympd/archive/master.zip
unzip master.zip
cd $unzipdir
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr
make install

cd /tmp

#Get the config file and service file
wget https://raw.githubusercontent.com/notandy/ympd/master/contrib/ympd.service
wget https://raw.githubusercontent.com/notandy/ympd/master/contrib/ympd.default

#Change web port
sed '/WEB_PORT=8080/c WEB_PORT=80' -i ympd.default

# Install files
install -Dm644  ympd.service /etc/systemd/system/ympd.service
install -Dm644  ympd.default /etc/default/ympd

#Enable and start the service
systemctl enable ympd.service
systemctl start ympd.service
systemctl status ympd.service

#Cleanup
rm ympd.service
rm ympd.default
rm master.zip

echo "Removing $unzipdir"
rm -rI $unzipdir
