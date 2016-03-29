#!/bin/bash
#
## Coverart
## This is the full installation script
#
## This installs a number of files to show coverart and other backgrounds
## while MPD plays music files
#
## Installs and sets up LXDE as well

pkgname=coverart
pkgver=1.0
pkgrel=1
declare -a depends=('xinit' 'lxde-core' 'lxterminal' 'lxappearance' 'lightdm' 'iceweasel' 'x11-xserver-utils' 'gxmessage' 'imagemagick')

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
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/coverart.sh
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/YMPD
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/autostart
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/art.tar

# Install files
install -D -m755 -o mpd -g audio coverart.sh /var/lib/mpd/coverart.sh
install -D -m755 -o mpd -g audio YMPD /var/lib/mpd/Desktop/YMPD
install -D -m644 -o mpd -g audio autostart /var/lib/mpd/.config/lxsession/LXDE/autostart
cd /var/lib/mpd
tar -xf /tmp/$pkgname/art.tar

# Setting graphical.target as the new default target
if command -v systemctl > /dev/null && systemctl | grep -q '\-\.mount'; then
    SYSTEMD=1
elif [ -f /etc/init.d/cron ] && [ ! -h /etc/init.d/cron ]; then
    SYSTEMD=0
else
    echo "Unrecognised init system"
    return 1
fi

if [ $SYSTEMD -eq 1 ]; then
    systemctl set-default graphical.target
    ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
else
    update-rc.d lightdm enable 2
fi

sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=mpd/"

#Cleanup
cd /tmp
rm -rI $pkgname
