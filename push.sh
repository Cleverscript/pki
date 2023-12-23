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

# remove .deb package
rm -f pki_0.1.* && rm -f ovpn_0.1-1_* && rm -f client_0.1-1_*

# generate .deb packets
cd pki-0.1/debian && debuild -b
cd ../../
cd ovpn-0.1/debian && debuild -b
cd ../../
cd bcp-0.1/debian && debuild -b
cd ../../
cd client-0.1/debian && debuild -b
cd ../../

# push new deb packets to remote server
scp pki_0.1-1_all.deb ovpn_0.1-1_all.deb bcp_0.1-1_all.deb ${LOGIN}@${HOST}:/home/${LOGIN}

# connet to remote server
# ./bcp_0.1-1_all.deb
ssh ${LOGIN}@${HOST} -t "sudo apt update && sudo apt full-upgrade; sudo apt remove pki ovpn bcp easy-rsa iptables-persistent net-tools python3-pip prometheus-node-exporter gnupg; sudo apt autoremove; sudo apt install ./pki_0.1-1_all.deb ./ovpn_0.1-1_all.deb ./bcp_0.1-1_all.deb; exit"