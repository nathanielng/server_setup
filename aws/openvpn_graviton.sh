#!/bin/bash

# Installs OpenVPN on a Graviton instance

# Commands for Amazon Linux 2 (Note this last step does not work)
# sudo yum -y update
# sudo amazon-linux-extras install epel -y
# sudo yum install -y yum-plugin-copr
# sudo yum copr enable dsommers/openvpn3 -y
# sudo yum install -y openvpn3-client

# Commands for Ubuntu
sudo apt -y update
sudo apt -y install tzdata
sudo dpkg-reconfigure tzdata
sudo apt -y install ca-certificates wget net-tools gnupg
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | sudo apt-key add -
sudo bash -c 'echo "deb http://as-repository.openvpn.net/as/debian focal main" > /etc/apt/sources.list.d/openvpn-as-repo.list'
sudo apt -y update && sudo apt -y install openvpn-as
