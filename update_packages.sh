#!/bin/bash

# Keep the system up to date

which apt
if [ "$?" -eq 0 ]; then
    sudo apt -y update
    sudo apt -y upgrade
fi

which yum
if [ "$?" -eq 0 ]; then
    sudo yum -y update
fi

