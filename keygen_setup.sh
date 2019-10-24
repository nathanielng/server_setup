#!/bin/bash

FILE="$HOME/.ssh/id_ed25519"
ssh-keygen -o -a 100 -t ed25519 -f $FILE -C "$USER@$HOSTNAME"

PUBLIC_IP_ADDR=`curl http://ifconfig.me/ip`
if [ "$?" -eq 0 ]; then
    echo "On a client computer, copy $FILE to ~/.ssh/id_ed25519"
    echo "and add the following lines to ~/.ssh/config:"
    echo
    echo "Host $HOSTNAME"
    echo " HostName ${PUBLIC_IP_ADDR}"
    echo " IdentityFile ~/.ssh/id_ed25519"
    echo " User $USER"
else
    echo "Failed to get public IP address"
fi
