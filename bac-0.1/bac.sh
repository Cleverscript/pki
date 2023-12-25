#!/bin/bash

##########################################################################
# Shellscript:  bac.sh - backup of critical infrastructure files (Bourne Shell)
# Author     :  Dokukin Vyacheslav Olegovich (<a href="mailto:toorrp4@gmail.com">toorrp4@gmail.com</a>)
# Date       :  24-12-2023
# Category   :  Desktop
##########################################################################

BACDATETIME=$(date +"%d.%m.%Y_%H-%M-%S")
BACCNF=/etc/bac.conf
BACGPG="$1"
BACCONTAINER="$2"
BACNAME=bac_$(date "+%d%m%Y")
BACLOG=/var/log/bac.log

# check config
if [ ! -f $BACCNF ]; then
    echo "[${BACDATETIME}] Error: config file ${BACCNF} is not exist!" >> ${BACLOG}
    exit 1
fi


# create backup dir
if [ ! -d /tmp/${BACNAME} ]; then
    mkdir /tmp/${BACNAME}
else
    rm -rf /tmp/${BACNAME}/*
fi

# create log file
if [ ! -f ${BACLOG} ]; then
    touch ${BACLOG}
fi

# check exist backup dir
if [ ! -d /tmp/${BACNAME} ]; then
    echo "[${BACDATETIME}] Error: backup dir /tmp/${BACNAME} is not exist!" >> ${BACLOG}
    exit 1
fi

cd /tmp

while read line
do
    # Packing into an array
    if [ ! -z "$line" ]; then
        cp -r "$line" /tmp/${BACNAME}/ >/dev/null
    fi
    tar -zcf ${BACNAME}.tar.gz /tmp/${BACNAME} >/dev/null
    echo "[${BACDATETIME}] Success: create backup file ${BACNAME}.tar.gz!" >> ${BACLOG}
    tar -tf ${BACNAME}.tar.gz >> ${BACLOG}

done < $BACCNF

# GPG encript file array
if [ ! -z $BACGPG ]; then

    gpg --encrypt --sign --armor -r ${BACGPG} /tmp/${BACNAME}.tar.gz

    if [ -f /tmp/${BACNAME}.tar.gz.asc ]; then
        rm -f /tmp/${BACNAME}.tar.gz && echo "[${BACDATETIME}] Remove /tmp/${BACNAME}.tar.gz" >> ${BACLOG}
        echo "[${BACDATETIME}] Success GPG encrypt file array, new file:" >> ${BACLOG}
        ls -la /tmp/${BACNAME}.tar.gz.asc >> ${BACLOG}
    else
        echo "[${BACDATETIME}] Error GPG encrypt file array fail" >> ${BACLOG}
        exit 1
    fi
else
    echo "[${BACDATETIME}] Error: The recipient's decryption key is not specified, specify it later in the file /etc/systemd/system/bac.service, otherwise it will not work!" >> ${BACLOG}
    exit 1
fi


# Sending to the cloud
if [ ! -z ${BACCONTAINER} ]; then
    if [ -f /tmp/${BACNAME}.tar.gz.asc ]; then		
            s3cmd put /tmp/${BACNAME}.tar.gz.asc s3://${BACCONTAINER}
    else
        echo "[${BACDATETIME}] Error: file /tmp/${BACNAME}.tar.gz.asc is not exist!" >> ${BACLOG}
        exit 1
    fi
else
    echo "[${BACDATETIME}] Error: container name is not defined, exited!" >> ${BACLOG}
    exit 1
fi


echo "- - - - -" >> ${BACLOG}

# clear tmp files
rm -rf /tmp/${BACNAME}*