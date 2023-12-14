#!/bin/bash

PATHEASYRSAUSR="/opt/easy-rsa"

# check argument (client login)
if [ -z "$1" ]; then
  echo "\033[31m Error: $0 CLIENT_NAME - break! \033[0m"
  exit 1
fi

LOGIN="$1"

cd ${PATHEASYRSAUSR}
./easyrsa gen-req ${LOGIN} nopass

