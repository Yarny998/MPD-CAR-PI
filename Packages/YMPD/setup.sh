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
declare -a depends=("cmake" "libmpdclient-dev")

echo "Installing $pkgname"

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
sed 's/WEB_PORT=8080/WEB_PORT=80/' -i ympd.default

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
