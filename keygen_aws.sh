#!/bin/bash

# Creates a key pair named after the AWS Instance ID
# - only if a key pair of that same name does not already exist
# - and generating a new file if it does not already exist

IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
KEY_PAIR="keypair-${INSTANCE_ID}"

KEY_FILE="$HOME/.ssh/id_rsa"
if [ ! -e "${KEY_FILE}" ]; then
    ssh-keygen -t rsa -b 4096 -f ${KEY_FILE} -q -N ""
fi

aws ec2 describe-key-pairs --key-name "$KEY_PAIR" 2> /dev/null
if [ "$?" -ne 0 ]; then
    aws ec2 import-key-pair --key-name ${KEY_PAIR} --public-key-material fileb://${KEY_FILE}.pub
fi
