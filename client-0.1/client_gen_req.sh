#!/bin/bash

PATHEASYRSAUSR="/opt/easy-rsa"
LOGIN=$USER

cd ${PATHEASYRSAUSR}

read "Enter your user login [${USER}]: " login
if [ ! -z $login ]; then
    LOGIN=$login
fi

./easyrsa gen-req ${LOGIN} nopass

