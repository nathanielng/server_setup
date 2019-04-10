#!/bin/bash
curl -O https://repo.anaconda.com/miniconda/Miniconda2-4.5.12-Linux-x86_64.sh
md5sum Miniconda2-4.5.12-Linux-x86_64.sh | grep "4be03f925e992a8eda03758b72a77298"
if [ "$?" -eq 0 ]; then
    bash Miniconda2-4.5.12-Linux-x86_64.sh
else
    echo "Failed to download Miniconda 2"
    exit 1
fi
echo "To begin using Miniconda, restart your bash shell or type:"
echo "source ~/.bashrc"
