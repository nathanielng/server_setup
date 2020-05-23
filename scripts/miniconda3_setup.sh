#!/bin/bash

# Repo Page: https://repo.anaconda.com/miniconda/
# Installation Guide: https://docs.conda.io/projects/conda/en/latest/user-guide/install/

curl -o miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh
if [ ! -e "miniconda3.sh" ]; then
    echo "Failed to download Miniconda"
    exit 1
fi

md5sum miniconda3.sh | grep "87e77f097f6ebb5127c77662dfc3165e"
if [ "$?" -eq 0 ]; then
    bash miniconda3.sh
else
    echo "md5 checksum failed"
    exit 2
fi
echo "To begin using Miniconda, restart your bash shell or type:"
echo "source ~/.bashrc"
