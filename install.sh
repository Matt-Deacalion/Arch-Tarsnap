#!/bin/bash


if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

#
# Install Tarsnap if it's not already there
#
if [ ! -x /usr/bin/tarsnap ]; then
    pacman -Syy
    pacman --noconfirm -S tarsnap
fi

echo -n "Tarsnap account email: "
read tarsnap_email

echo -n "Machine name: "
read machine_name


#
# Create the key
#
if [ -e /root/.tarsnap-key.txt ]; then
    mv /root/.tarsnap-key.txt /root/.tarsnap-key.txt.backup
fi

tarsnap-keygen --keyfile /root/.tarsnap-key.txt --user $tarsnap_email --machine $machine_name


#
# Install our Tarsnap configuration
#
if [ -e /etc/tarsnap/tarsnap.conf ]; then
    mv /etc/tarsnap/tarsnap.conf /etc/tarsnap/tarsnap.conf.backup
fi

cp ./tarsnap.conf /etc/tarsnap/


#
# Create the Tarsnap cache directory
#
mkdir /usr/local/tarsnap-cache
chmod 700 /usr/local/tarsnap-cache


#
# Install our `backup` command
#
cp backup /usr/local/sbin/


#
# Install systemd service and timer units
#
cp tarsnap.service /etc/systemd/system/
cp tarsnap.timer /etc/systemd/system/

systemctl daemon-reload

systemctl enable tarsnap.timer
systemctl start tarsnap.timer
