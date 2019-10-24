#!/bin/bash

# Switches a git repository from https to git

export git_url=`git config --get remote.origin.url`
echo "$git_url"

repo="${git_url##*/}"
server="${git_url%%/*}"
git_user="${git_url%/*}"
git_user="${git_user#*/}"

new_url="git@${server}:${git_user}/${repo}"
echo "git remote set-url origin ${new_url}"

