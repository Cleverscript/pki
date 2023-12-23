#!/bin/bash

BCPDATETIME=$(date +"%d.%m.%Y_%H%M%S")
BCPCNF=/etc/bcp.conf
BCPGPGCONF=/etc/bcpgpg.conf
BCP3CFG=/etc/bcp3cfg.conf
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

while read line
do
    # Packing into an array
    cd /tmp
    if [ -d $line ]; then
        cp -r $line /tmp/${BCPNAME}/ >/dev/null
    else
        echo "[${BCPDATETIME}] Warning: fail copy dir ${line}, dir not exist!" >> ${BCPLOG}
    fi
    tar -zcf ${BCPNAME}.tar.gz ${BCPNAME}
    echo "[${BCPDATETIME}] Success: create backup file ${BCPNAME}.tar.gz!" >> ${BCPLOG}
    tar -tf ${BCPNAME}.tar.gz >> ${BCPLOG}

    # GPG encript file array
    if [ -f $BCPGPGCONF ]; then
        GPGKEY=$(cat ${$BCPGPGCONF})
        if [ ! -z $GPGKEY ]; then
            gpg --encrypt --sign --armor -r ${GPGKEY} ${BCPNAME}.tar.gz
            rm -f ${BCPNAME}.tar.gz && echo "[${BCPDATETIME}] Remove ${BCPNAME}.tar.gz" >> ${BCPLOG}
            if [ -f ${BCPNAME}.tar.gz.asc ]; then
                echo "[${BCPDATETIME}] Success GPG encrypt file array, new file:" >> ${BCPLOG}
                ls -la ${BCPNAME}.tar.gz.asc >> ${BCPLOG}
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
        CONTAINER=$(cat ${BCP3CFG})
        if [ ! -z ${CONTAINER} ]; then
            s3cmd put ${BCPNAME}.tar.gz.asc s3://${CONTAINER}
        else
            echo "[${BCPDATETIME}] Error: The recipient's decryption key is not specified, specify it later in the file ${CP3CFG}, otherwise it will not work!" >> ${BCPLOG}
            exit 1
        fi

    else
        echo "[${BCPDATETIME}] Error: config file ${BCP3CFG} not exist, create a file!" >> ${BCPLOG}
        exit 1
    fi

    echo "- - - - -" >> ${BCPLOG}

done < $BCPCNF

rm -rf /tmp/${BCPNAME}