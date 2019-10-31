#!/bin/bash

# This script is based on code from:
# https://ubuntu.com/livepatch

if [ "$LIVEPATCH_TOKEN" = "" ]; then
    echo "Please obtain a livepatch token from"
    echo "https://auth.livepatch.canonical.com/?user_type=ubuntu-user"
    exit 1
fi

sudo snap install canonical-livepatch
sudo canonical-livepatch enable $LIVEPATCH_TOKEN

