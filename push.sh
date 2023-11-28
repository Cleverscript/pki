#!/bin/bash

LOGIN=$1
HOST=$2

if [ -z $LOGIN ]; then
    read -p "Error - enter login: " LOGIN
fi

if [ -z $HOST ]; then
    read -p "Error - enter IP or domain remote host: " HOST
fi

rm -f pki_0.1.* && rm -f ovpn_0.1-1_*

cd ovpn-0.1/debian && debuild -b
cd ../../
cd pki-0.1/debian && debuild -b
cd ../../


# push new deb packets to remote server
scp pki_0.1-1_all.deb ovpn_0.1-1_all.deb ${LOGIN}@${HOST}:/home/${LOGIN}

# connet to remote server
ssh ${LOGIN}@${HOST} -t "sudo apt remove easy-rsa iptables-persistent net-tools pki ovpn; sudo apt install ./pki_0.1-1_all.deb ./ovpn_0.1-1_all.deb; exit"