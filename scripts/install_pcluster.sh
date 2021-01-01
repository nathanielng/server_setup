#!/bin/bash

which python3
if [[ "$?" -ne "0" ]]; then
    echo "python3 is not installed"
    exit
fi

python3 -m pip install --upgrade pip
python3 -m pip install --user --upgrade virtualenv
python3 -m virtualenv pcluster
source pcluster/bin/activate
python3 -m pip install --upgrade aws-parallelcluster

