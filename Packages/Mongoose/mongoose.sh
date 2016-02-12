#!/bin/bash
#
## Mongoose
## This is the full installation script including compilation
#

pkgname=mongoose
pkgver=5.5
pkgrel=2

if [ $# -gt 0 ]
then
    instopt="$1"
fi

#Dependencies for mongoose
aptitude install libssl-dev

cd /tmp

if [ "$instopt" = "-full" ]
then 
    #Get the main install base and compile
    wget https://github.com/cesanta/mongoose/archive/$pkgver.tar.gz
    tar -xvf $pkgver.tar.gz

    #Compile the lib file
    cd mongoose-$pkgver
    gcc -shared -fPIC -DNS_ENABLE_SSL $CFLAGS $LDFLAGS mongoose.c -o libmongoose.so -lssl
    cp libmongoose.so /tmp
    cp mongoose.h /tmp 
    cp LICENSE /tmp 

    #Make the web server
    cd examples/web_server
    make web_server
    cp web_server /tmp

    #Cleanup
    cd /tmp
    rm $pkgver.tar.gz
    rm -r mongoose-$pkgver
else
    #Just get the pre-compiled files
    wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/libmongoose.so
    wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/LICENSE
    wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/mongoose.h
    wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/web_server
fi

#Get the config file and service file
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/mongoose.conf
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/mongoose.service

# Install files
cd /tmp
install -D -m644 mongoose.conf "/etc/mongoose/mongoose.conf"
install -D -m644 mongoose.service "/etc/systemd/service"
install -D -m644 LICENSE "/usr/share/licenses/mongoose/LICENSE"
install -D -m755 libmongoose.so "/usr/lib/libmongoose.so"
install -D -m644 mongoose.h "/usr/include/mongoose.h"
install -D -m755 web_server "/usr/bin/mongoose"

systemctl enable mongoose.service
systemctl start mongoose.service
systemctl status mongoose.service

#Cleanup
rm mongoose.conf
rm mongoose.service
rm LICENSE
rm libmongoose.so
rm mongoose.h
rm web_server
