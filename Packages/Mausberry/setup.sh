#!/bin/bash
#
## Mausberry Car Power Controller
## This is the full installation script
#
## This installs a script to control the raspberry pi connected to 
## the Mausberry car power controller

pkgname=mausberry
pkgver=1.0
pkgrel=1

echo "Installing $pkgname"

mkdir /usr/bin/mausberry

echo '#!/bin/bash

#this is the GPIO pin connected to the lead on switch labeled OUT
GPIOpin1=5

#this is the GPIO pin connected to the lead on switch labeled IN
GPIOpin2=6

echo "$GPIOpin1" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$GPIOpin1/direction
echo "$GPIOpin2" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$GPIOpin2/direction
echo "1" > /sys/class/gpio/gpio$GPIOpin2/value
while [ 1 = 1 ]; do
power=$(cat /sys/class/gpio/gpio$GPIOpin1/value)
if [ $power = 0 ]; then
sleep 1
else
sudo poweroff
fi
done' > /usr/bin/mausberry/switch.sh
sudo chmod 777 /usr/bin/mausberry/switch.sh
sudo sed -i '$ i /usr/bin/mausberry/switch.sh &' /etc/rc.local
