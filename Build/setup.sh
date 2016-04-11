#!/bin/bash
###################### Creation Script for Raspberry Pi 2 ############################
clear
red='\e[0;31m'
NC='\e[0m'

# Changing DNS servers
    echo -e "${red}Changing to Google DNS servers...${NC}" 
    systemctl disable systemd-resolved
    systemctl mask systemd-resolved
    rm /etc/resolv.conf
    cat > /etc/resolv.conf <<"EOF"
# Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
# Opendns
#nameserver 208.67.222.222 
#nameserver 208.67.220.220
EOF

    echo -e "${red}Disallowing dhcpcd to change DNS servers...${NC}" 
    cat >> /etc/dhcpcd.conf <<"EOF"

#Disallowing dhcpcd to change DNS servers
nohook resolv.conf
EOF

# Disabling various modules
    echo -e "${red}Disabling various modules...${NC}" 
    cat >> /etc/modprobe.d/blacklist.conf << "EOF"
blacklist snd_bcm2835
blacklist rpcsec_gss_krb5
EOF

# Disabling ipv6
# "net.ipv6.conf.all.disable_ipv6=1" added throught archphile-optimize package 
sed -e '/::1/ s/^#*/#/' -i /etc/hosts
cat >> /etc/dhcpcd.conf <<"EOF"

#Disable ipv6 connectivity
noipv6rs
noipv6
EOF

# Changing hostname
echo -e "${red}Changing your hostname...${NC}" 
hostnamectl set-hostname vanbian
	
# Locale and timezone configuration
systemctl disable systemd-timesyncd
systemctl mask systemd-timesyncd
aptitude install ntp
echo -e "${red}Changing locale, timezone and ntp configuration...${NC}" 
sed -i 's/^#en_US.UTF-8 UTF-8.*/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG="en_US.UTF-8"" > /etc/locale.conf
rm /etc/localtime
ln -s /usr/share/zoneinfo/Australia/Canberra /etc/localtime
wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Build/ntp.conf -O /etc/ntp.conf

echo -e "${red}Updating system and installing needed packages...${NC}" 
aptitude update

#USB Automount
aptitude install usbmount
sed 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,flush,gid=plugdev,dmask=0000,fmask=0000"/' -i /etc/usbmount/usbmount.conf

#
## MPD and MPC
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPD/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## Mongoose
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mongoose/setup.sh
# chmod 755 setup.sh
# ./setup.sh -full

#
## ympd
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/YMPD/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## i2select
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/i2select/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## alsaequal
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/AlsaEqual/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## controls
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Controls/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## mpdscribble
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/MPDScribble/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## coverart
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Coverart/setup.sh
# chmod 755 setup.sh
# ./setup.sh

#
## mausberry
#
# wget https://raw.githubusercontent.com/Yarny998/MPD-Jesse-Lite/master/Packages/Mausberry/setup.sh
# chmod 755 setup.sh
# ./setup.sh
 
