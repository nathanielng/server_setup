#!/bin/bash
# This script is to be copied to newly deployed AWS EC2 Instances
which yum
if [ "$?" -eq 0 ]; then
    sudo yum -y update
    sudo yum -y install git
fi

which apt
if [ "$?" -eq 0 ]; then
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt install git
fi

git clone https://github.com/nathanielng/server_setup.git
cd server_setup
bash bash_setup.sh
source ~/.bashrc

