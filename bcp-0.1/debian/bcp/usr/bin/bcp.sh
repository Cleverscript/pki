#!/bin/bash

##########################################################################
# Shellscript:  bcp.sh - backup of critical infrastructure files (Bourne Shell)
# Author     :  Dokukin Vyacheslav Olegovich (<a href="mailto:toorrp4@gmail.com">toorrp4@gmail.com</a>)
# Date       :  24-12-2023
# Category   :  Desktop
##########################################################################

BCPDATETIME=$(date +"%d.%m.%Y_%H%M%S")
BCPCNF=/etc/bcp.conf
BCPGPGCONF=/etc/bcpgpg.conf
BCPS3CFG=/etc/bcps3cfg.conf
BCPNAME=bcp_$(date "+%d%m%Y")
BCPLOG=/var/log/bcp.log

# create backup dir
if [ ! -d /tmp/${BCPNAME} ]; then
    mkdir /tmp/${BCPNAME}
else
    rm -rf /tmp/${BCPNAME}/*
fi

# create log file
if [ ! -f ${BCPLOG} ]; then
    touch ${BCPLOG}
fi

# check exist backup dir
if [ ! -d /tmp/${BCPNAME} ]; then
    echo "[${BCPDATETIME}] Error: backup dir /tmp/${BCPNAME} is not exist!" >> ${BCPLOG}
    exit 1
fi

cd /tmp

while read line
do
    # Packing into an array
    if [ ! -z "$line" ]; then
        cp -r "$line" /tmp/${BCPNAME}/ >/dev/null
    fi
    tar -zcf ${BCPNAME}.tar.gz /tmp/${BCPNAME}
    echo "[${BCPDATETIME}] Success: create backup file ${BCPNAME}.tar.gz!" >> ${BCPLOG}
    tar -tf ${BCPNAME}.tar.gz >> ${BCPLOG}

done < $BCPCNF

# GPG encript file array
if [ -f $BCPGPGCONF ]; then
    GPGKEY=$(cat ${BCPGPGCONF})
    if [ ! -z $GPGKEY ]; then

        gpg --encrypt --sign --armor -r ${GPGKEY} /tmp/${BCPNAME}.tar.gz

        if [ -f /tmp/${BCPNAME}.tar.gz.asc ]; then
            rm -f /tmp/${BCPNAME}.tar.gz && echo "[${BCPDATETIME}] Remove /tmp/${BCPNAME}.tar.gz" >> ${BCPLOG}
            echo "[${BCPDATETIME}] Success GPG encrypt file array, new file:" >> ${BCPLOG}
            ls -la /tmp/${BCPNAME}.tar.gz.asc >> ${BCPLOG}
        else
            echo "[${BCPDATETIME}] Error GPG encrypt file array fail" >> ${BCPLOG}
        fi
    else
        echo "[${BCPDATETIME}] Error: The recipient's decryption key is not specified, specify it later in the file ${BCPGPGCONF}, otherwise it will not work!" >> ${BCPLOG}
        exit 1
    fi
else
    echo "[${BCPDATETIME}] Error: config file ${BCPGPGCONF} not exist, create a file!" >> ${BCPLOG}
    exit 1
fi

# Sending to the cloud
if [ -f $BCP3CFG ]; then

    # get container name
    CONTAINER=$(cat ${BCPS3CFG})

    if [ ! -z ${CONTAINER} ]; then
        if [ -f /tmp/${BCPNAME}.tar.gz.asc ]; then		
                s3cmd put /tmp/${BCPNAME}.tar.gz.asc s3://${CONTAINER}
        else
            echo "[${BCPDATETIME}] Error: file /tmp/${BCPNAME}.tar.gz.asc is not exist!" >> ${BCPLOG}
        fi
    else
        echo "[${BCPDATETIME}] Error: The recipient's decryption key is not specified, specify it later in the file ${CP3CFG}, otherwise it will not work!" >> ${BCPLOG}
        exit 1
    fi

else
    echo "[${BCPDATETIME}] Error: config file ${BCP3CFG} not exist, create a file!" >> ${BCPLOG}
    exit 1
fi

echo "- - - - -" >> ${BCPLOG}

# clear tmp files
rm -rf /tmp/${BCPNAME}*