#!/bin/bash

# check argument (client login)
if [ -z "$1" ]; then
  echo "Error: $0 CLIENT_NAME - break!"
  exit 1
fi

CLIENT_NAME="$1"
PATHEASYRSAUSR="/opt/easy-rsa"
PATHOVPNUSR="~/ovpn"
PATHOVPNCLIENT="/var/snap/simple-openvpn-client/common/"

sudo mkdir -p ${PATHOVPNUSR}/$CLIENT_NAME
sudo cp ${PATHOVPNUSR}/base.conf ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo chown -R $USER:$USER ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo chmod 766 ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
cd $PATHEASYRSAUSR
source ./vars
./easyrsa build-key $CLIENT_NAME
#(In the new version ./easyrsa build-client-full  $CLIENT_NAME)

# Copy the client keys and certificates to the client directory
sudo cp ${$PATHEASYRSAUSR}/pki/issued/$CLIENT_NAME.crt ${PATHOVPNUSR}/$CLIENT_NAME/
sudo cp ${$PATHEASYRSAUSR}/pki/private/$CLIENT_NAME.key ${PATHOVPNUSR}/$CLIENT_NAME/
sudo cp ${PATHOVPNUSR}/keys/ca.crt ${PATHOVPNUSR}/$CLIENT_NAME/
sudo cp ${PATHOVPNUSR}/keys/ta.key ${PATHOVPNUSR}/$CLIENT_NAME/

sudo echo "<tls-crypt>" >>${PATHOVPNUSR}/$CLIENT_NAME/ta.key >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo cat ${PATHOVPNUSR}/$CLIENT_NAME/ta.key >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo echo "</tls-crypt>

<ca>" >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo cat ${PATHOVPNUSR}/$CLIENT_NAME/ca.crt  >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo echo "</ca>

<cert>" >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo cat ${PATHOVPNUSR}/$CLIENT_NAME/$CLIENT_NAME.crt >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo echo "</cert>

<key>" >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo cat ${PATHOVPNUSR}/$CLIENT_NAME/$CLIENT_NAME.key  >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn
sudo echo "</key>" >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn

sudo echo "redirect-gateway def1" >> ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn

# copy config to simple-openvpn-client folder
if [ -d $PATHOVPNCLIENT ]; then
    cp ${PATHOVPNUSR}/$CLIENT_NAME/client.ovpn $PATHOVPNCLIENT
else
    echo "Error simple-openvpn-client folder is not exist!"
fi