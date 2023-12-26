#!/bin/bash

##########################################################################
# Shellscript:  bac.sh - backup of critical infrastructure files (Bourne Shell)
# Author     :  Dokukin Vyacheslav Olegovich (<a href="mailto:toorrp4@gmail.com">toorrp4@gmail.com</a>)
# Date       :  24-12-2023
# Category   :  Desktop
##########################################################################

BACDATETIME=$(date +"%d.%m.%Y %H:%M:%S")
BACCNF=/etc/bac.conf
BACGPG="$1"
BACCONTAINER="$2"
BACUSER="$3"
BACNAME=bac_$(date "+%d%m%Y")
BACLOG=/var/log/bac.log

# check config
if [ ! -f $BACCNF ]; then
    sudo bash -c "echo '[${BACDATETIME}] Error: config file ${BACCNF} is not exist!' >> '${BACLOG}';"
    exit 1
fi

# check GPG key
if [ -z $BACGPG ]; then
    sudo bash -c "echo '[${BACDATETIME}] Error: PGP key is null, exited!' >> '${BACLOG}';"
    exit 1
fi

# check SELECTEL storege container name
if [ -z $BACCONTAINER ]; then
    sudo bash -c "echo '[${BACDATETIME}] Error: SELECTEL storege container name is null, exited!' >> '${BACLOG}';"
    exit 1
fi

# check user
if [ -z $BACUSER ]; then
    sudo bash -c "echo '[${BACDATETIME}] Error: user is null, exited!' >> '${BACLOG}';"
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
    sudo touch ${BACLOG}
fi

# check exist backup dir
if [ ! -d /tmp/${BACNAME} ]; then
    sudo bash -c "echo '[${BACDATETIME}] Error: backup dir /tmp/${BACNAME} is not exist!' >> '${BACLOG}';"
    exit 1
fi

cd /tmp

# Packing into array
while read line
do
    if [ ! -z "$line" ]; then
        sudo bash -c "'cp -r $line /tmp/${BACNAME}/' > '/dev/null';"
    fi
    sudo bash -c "tar -zcf ${BACNAME}.tar.gz /tmp/${BACNAME} > '/dev/null';"
    if [ ! -f /tmp/${BACNAME}.tar.gz ]; then
        sudo bash -c "echo '[${BACDATETIME}] Error: create backup file ${BACNAME}.tar.gz, exited!' >> '${BACLOG}';"
    fi
    sudo bash -c "echo '[${BACDATETIME}] Success: create backup file ${BACNAME}.tar.gz!' >> '${BACLOG}';"
    sudo bash -c "chown $BACUSER:$BACUSER /tmp/${BACNAME}.tar.gz"
    sudo bash -c "ls -la /tmp/${BACNAME}.tar.gz >> '${BACLOG}';"
    sudo bash -c "tar -tf ${BACNAME}.tar.gz >> '${BACLOG}';"

done < $BACCNF

# GPG encript file array
if [ ! -z $BACGPG ]; then
    USR=$USER
    sudo bash -c "echo 'GPG enc start: use key <${BACGPG}>, user run $USR $BACUSER' >> '${BACLOG}';"
    gpg --sign-key ${BACGPG}
    #gpg --no-tty --encrypt --sign --armor -r ${BACGPG} /tmp/${BACNAME}.tar.gz
    # --detach-sign --batch --no-tty --yes
    GPG_TTY=$(tty)
    export GPG_TTY
    #sudo -H -u $BACUSER bash -c "gpg --encrypt --no-tty --yes --sign --armor -r ${BACGPG} /tmp/${BACNAME}.tar.gz"
    gpg --encrypt --no-tty --yes --sign --armor -r ${BACGPG} /tmp/${BACNAME}.tar.gz
    GPGLISTKEY=$(sudo -H -u $BACUSER bash -c "gpg --list-key")
    sudo bash -c "echo '$GPGLISTKEY' >> '${BACLOG}';"

    if [ -f /tmp/${BACNAME}.tar.gz.asc ]; then
        sudo bash -c "rm -f /tmp/${BACNAME}.tar.gz" && sudo bash -c "echo '[${BACDATETIME}] Remove /tmp/${BACNAME}.tar.gz' >> '${BACLOG}';"
        sudo bash -c "echo '[${BACDATETIME}] Success GPG encrypt file array, new file:' >> '${BACLOG}';"
        sudo bash -c "ls -la /tmp/${BACNAME}.tar.gz.asc >> '${BACLOG}';"
    else
        sudo bash -c "echo '[${BACDATETIME}] Error GPG encrypt file array fail' >> '${BACLOG}';"
        exit 1
    fi
else
    sudo bash -c "echo '[${BACDATETIME}] Error: The recipient's decryption key is not specified, specify it later in the file /etc/systemd/system/bac.service, otherwise it will not work!' >> '${BACLOG}';"
    exit 1
fi


# Sending to the cloud
if [ ! -z ${BACCONTAINER} ]; then
    if [ -f /tmp/${BACNAME}.tar.gz.asc ]; then		
            s3cmd put /tmp/${BACNAME}.tar.gz.asc s3://${BACCONTAINER}
    else
        sudo bash -c "echo '[${BACDATETIME}] Error: file /tmp/${BACNAME}.tar.gz.asc is not exist!' >> '${BACLOG}';"
        exit 1
    fi
else
    sudo bash -c "echo '[${BACDATETIME}] Error: container name is not defined, exited!' >> '${BACLOG}';"
    exit 1
fi


sudo bash -c "echo '- - - - -' >> '${BACLOG}';"

# clear tmp files
rm -rf /tmp/${BACNAME}*