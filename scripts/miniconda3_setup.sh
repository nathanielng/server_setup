#!/bin/bash
curl -O https://repo.continuum.io/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh
md5sum Miniconda3-4.5.12-Linux-x86_64.sh | grep "866ae9dff53ad0874e1d1a60b1ad1ef8"
if [ "$?" -eq 0 ]; then
    bash Miniconda3-4.5.12-Linux-x86_64.sh
else
    echo "Failed to download Miniconda"
    exit 1
fi
echo "To begin using Miniconda, restart your bash shell or type:"
echo "source ~/.bashrc"
