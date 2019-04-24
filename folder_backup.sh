#!/bin/bash
cd $HOME
FOLDERS=`ls -d */ | xargs`
for folder in $FOLDERS; do
    echo "$folder"
    tar -czf "${folder%%/}.tar.gz" "${folder}"
done
tar -czf dot_files.tar.gz .ssh .jupyter .bash_profile .bashrc

