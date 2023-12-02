#!/bin/bash

LOGIN=$1
HOST=$2

if [ -z $LOGIN ]; then
    read -p "Error - enter login: " LOGIN
fi

if [ -z $HOST ]; then
    read -p "Error - enter IP or domain remote host: " HOST
fi

rm -f pki_0.1.* && rm -f ovpn_0.1-1_* && rm -f client_0.1-1_*

# generate .deb packets
cd pki-0.1/debian && debuild -b
cd ../../
cd ovpn-0.1/debian && debuild -b
cd ../../
cd client-0.1/debian && debuild -b
cd ../../


# push new deb packets to remote server
scp pki_0.1-1_all.deb ovpn_0.1-1_all.deb ${LOGIN}@${HOST}:/home/${LOGIN}

# connet to remote server
ssh ${LOGIN}@${HOST} -t "sudo apt remove pki ovpn easy-rsa iptables-persistent net-tools; sudo apt install ./pki_0.1-1_all.deb ./ovpn_0.1-1_all.deb; exit"