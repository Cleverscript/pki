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
rm -f client_0.1-1_*

# debuild .deb package
cd client-0.1/debian && debuild -b
cd ../../

# push new deb packets to remote server
scp client_0.1-1_all.deb ${LOGIN}@${HOST}:/home/${LOGIN}

# connet to remote server
ssh ${LOGIN}@${HOST} -t "sudo apt remove easy-rsa openvpn client; sudo apt autoremove; sudo apt install ./client_0.1-1_all.deb; exit"