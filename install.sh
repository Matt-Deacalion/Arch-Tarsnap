#!/bin/bash


#
# Install Tarsnap if it's not already there
#
if [ ! -x /usr/bin/tarsnap ]; then
    sudo pacman -Syy
    sudo pacman --noconfirm -S tarsnap
fi

echo -n "Tarsnap account email: "
read tarsnap_email

echo -n "Machine name: "
read machine_name


#
# Create the key
#
if [ -e /root/.tarsnap-key.txt ]; then
    sudo mv /root/.tarsnap-key.txt /root/.tarsnap-key.txt.backup
fi

sudo tarsnap-keygen --keyfile /root/.tarsnap-key.txt --user $tarsnap_email --machine $machine_name


#
# Install our Tarsnap configuration
#
if [ -e /etc/tarsnap/tarsnap.conf ]; then
    sudo mv /etc/tarsnap/tarsnap.conf /etc/tarsnap/tarsnap.conf.backup
fi

sudo cp ./tarsnap.conf /etc/tarsnap/


#
# Create the Tarsnap cache directory
#
sudo mkdir /usr/local/tarsnap-cache
sudo chmod 700 /usr/local/tarsnap-cache


#
# Install our `backup` command
#
sed -i "s/USER/$USER/" backup
sudo cp backup /usr/local/sbin/


#
# Install our `backup-browser-plugins` command
#
sudo cp backup-browser-plugins /usr/local/sbin/


#
# Install systemd service and timer units
#
sudo cp tarsnap.service /etc/systemd/system/
sudo cp tarsnap.timer /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable tarsnap.timer
sudo systemctl start tarsnap.timer
