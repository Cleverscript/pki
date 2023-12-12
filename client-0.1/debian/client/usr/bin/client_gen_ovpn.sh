#!/bin/bash

# check argument (client login)
if [ -z "$1" ]; then
  echo -e "\033[31m Error: $0 client login is null - break! \033[0m"
  exit 1
fi

CLIENT_NAME="$1"

# check argument (VPN server IP)
if [ -z "$2" ]; then
  echo -e "\033[31m Error: $0 OpenVPN server IP is null - break! \033[0m"
  exit 1
fi

SERVER_IP_OPENVPN="$2"

#!/bin/bash
# First argument: Client identifier
KEY_DIR=/opt/easy-rsa/pki/private
OUTPUT_DIR=~/ovpn
BASE_CONFIG=/etc/openvpn/client/base.conf

# change user and permission
sudo chown -R $USER:$USER "/opt/easy-rsa"

if [ ! -f ${KEY_DIR}/${CLIENT_NAME}.crt ]; then
  echo -e "\033[31m Error: file ${KEY_DIR}/${CLIENT_NAME}.crt not exist! \033[0m"
  exit 1
fi

if [ ! -f $KEY_DIR/ca.crt ]; then
  echo -e "\033[31m Error: file ${BASE_CONFIG}/ta.key not exist! \033[0m"
  exit 1
fi

if [ ! -f $KEY_DIR/ta.key ]; then
  echo -e "\033[31m Error: file ${BASE_CONFIG}/ta.key not exist! \033[0m"
  exit 1
fi

if [ ! -f $BASE_CONFIG ]; then
  echo -e "\033[31m Error: file ${BASE_CONFIG} not exist! \033[0m"
  exit 1
fi

if [ ! -d $OUTPUT_DIR ]; then
  mkdir -p $OUTPUT_DIR
  sudo chmod 700 $OUTPUT_DIR
fi

sed -i "s|#SERVER_IP_OPENVPN#|$SERVER_IP_OPENVPN|g" $BASE_CONFIG

cat ${BASE_CONFIG} \
<(echo -e '<ca>') \
${KEY_DIR}/ca.crt \
<(echo -e '</ca>\n<cert>') \
${KEY_DIR}/${CLIENT_NAME}.crt \
<(echo -e '</cert>\n<key>') \
${KEY_DIR}/${CLIENT_NAME}.key \
<(echo -e '</key>\n<tls-crypt>') \
${KEY_DIR}/ta.key \
<(echo -e '</tls-crypt>\n') \
> ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn
#echo "redirect-gateway def1" >> ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn