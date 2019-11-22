#!/bin/bash

# Repo Page: https://repo.anaconda.com/miniconda/

curl -O https://repo.continuum.io/miniconda/Miniconda3-4.7.10-Linux-x86_64.sh
md5sum Miniconda3-4.7.10-Linux-x86_64.sh | grep "1c945f2b3335c7b2b15130b1b2dc5cf4"
if [ "$?" -eq 0 ]; then
    bash Miniconda3-4.7.10-Linux-x86_64.sh
else
    echo "Failed to download Miniconda"
    exit 1
fi
echo "To begin using Miniconda, restart your bash shell or type:"
echo "source ~/.bashrc"
