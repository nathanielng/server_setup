#!/bin/bash

# Upgrades AWS CLI to v2 on Amazon Linux 2 (AL2) Instances
# which have AWS CLI v1 installed

pip3 uninstall -y awscli
sudo rm /usr/bin/aws

PROCESSOR=$(uname -p)
if [ "$PROCESSOR" == "x86_64" ]; then
    # x86 processors
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
else
    # ARM processors
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
fi
unzip awscliv2.zip
sudo ./aws/install
