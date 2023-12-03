#!/bin/bash

LOGIN=$1
HOST=$2

if [ -z $LOGIN ]; then
    echo -e "\033[31m"
    read -p "Error - enter login remote host: " LOGIN
    echo -e "\033[0m"
fi

if [ -z $HOST ]; then
    echo -e "\033[31m"
    read -p "Error - enter IP or domain remote host: " HOST
    echo -e "\033[0m"
fi

if [ -z $LOGIN ]; then
    echo -e "\033[31m Error - empty login remote host -break! \033[0m"
    exit 1
fi
if [ -z $HOST ]; then
    echo -e "\033[31m Error - empty IP or domain remote host -break! \033[0m"
    exit 1
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
ssh ${LOGIN}@${HOST} -t "sudo apt remove pki ovpn easy-rsa iptables-persistent net-tools; sudo apt autoremove; sudo apt install ./pki_0.1-1_all.deb ./ovpn_0.1-1_all.deb; exit"