#!/bin/bash

# Installs OpenVPN on a Graviton instance

sudo yum -y update
sudo amazon-linux-extras install epel -y
sudo yum install -y yum-plugin-copr
sudo yum copr enable dsommers/openvpn3 -y

# Note this last step does not work
sudo yum install -y openvpn3-client
