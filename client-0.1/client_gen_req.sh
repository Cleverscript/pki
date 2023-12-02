#!/bin/bash

PATHEASYRSAUSR="/opt/easy-rsa"

# check argument (client login)
if [ -z "$1" ]; then
  echo "Error: $0 CLIENT_NAME - break!"
  exit 1
fi

LOGIN="$1"

cd ${PATHEASYRSAUSR}

./easyrsa gen-req ${LOGIN} nopass

