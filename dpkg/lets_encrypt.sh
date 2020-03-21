#!/bin/bash

# This script is based on instructions from
# https://certbot.eff.org/lets-encrypt/ubuntubionic-other

sudo apt -y update
sudo apt install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt -y update
sudo apt install certbot
sudo certbot certonly --standalone

