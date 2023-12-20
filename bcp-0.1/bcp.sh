#!/bin/bash

BCPDATETIME=$(date +"%d.%m.%Y_%H%M%S")
BCPCNF=/etc/bcp.conf
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
    cd /tmp
    if [ -d $line ]; then
        cp -r $line /tmp/${BCPNAME}/ >/dev/null
    else
        echo "[${BCPDATETIME}] Warning: fail copy dir ${line}, dir not exist!" >> ${BCPLOG}
    fi
    tar -zcf ${BCPNAME}.tar.gz ${BCPNAME}
    echo "[${BCPDATETIME}] Success: create backup file ${BCPNAME}.tar.gz!" >> ${BCPLOG}
    tar -tf ${BCPNAME}.tar.gz >> ${BCPLOG}
    echo "- - - - -" >> ${BCPLOG}

done < $BCPCNF

rm -rf /tmp/${BCPNAME}