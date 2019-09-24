#!/bin/bash
# This script is to be copied to newly deployed AWS EC2 Instances
sudo yum -y update
sudo yum -y install git
git clone https://github.com/nathanielng/server_setup.git
cd server_setup
bash bash_setup.sh
source ~/.bashrc

