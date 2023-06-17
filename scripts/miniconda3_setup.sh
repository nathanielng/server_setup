#!/bin/bash

# Repo Page: https://repo.anaconda.com/miniconda/
# Installation Guide: https://docs.conda.io/projects/conda/en/latest/user-guide/install/

curl -o miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh
if [ ! -e "miniconda3.sh" ]; then
    echo "Failed to download Miniconda"
    exit 1
fi

# Check SHA256
sha256sum miniconda3.sh | grep "1564571a6a06a9999a75a6c65d63cb82911fc647e96ba5b729f904bf00c177d3"
if [ "$?" -eq 0 ]; then
    bash miniconda3.sh
else
    echo "md5 checksum failed"
    exit 2
fi
echo "To begin using Miniconda, restart your bash shell or type:"
echo "source ~/.bashrc"
