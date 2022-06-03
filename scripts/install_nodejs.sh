#!/bin/bash

# Adapted from: https://github.com/nodejs/help/wiki/Installation

curl -LO https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz
sudo mkdir -p /usr/local/lib/nodejs
sudo tar -xJvf node-v16.15.1-linux-x64.tar.xz -C /usr/local/lib/nodejs
sudo ln -s /usr/local/lib/nodejs/node-v16.15.1-linux-x64/bin/node /usr/local/bin/node
