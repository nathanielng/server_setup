#!/bin/bash

if [ "$2" = "" ]; then
    echo "Usage: $0 [script_name] [server_name]"
    exit 1
fi

script_name="$1"
server_name="$2"

if [ ! -e "$script_name" ]; then
    echo "Script ${script_name} does not exist"
    exit 2
fi

rsync -avz -e "ssh -i $KEYFILE" ${script_name} ${server_name}:
ssh -i $KEYFILE $server_name ${script_name}

