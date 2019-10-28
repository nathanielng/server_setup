#!/bin/bash

if [ "$1" = "" ]; then
    echo "Usage: $0 [https2git|git2https]"
    exit 1
fi

export git_url=`git config --get remote.origin.url`
echo "Original URL: $git_url"

if [ "$1" = "https2git" ]; then
    # Switches a git repository from https to git
    repo="${git_url##*/}"
    server="${git_url%/*}"
    git_user="${server##*/}"
    server="${server%/*}"
    server="${server##*/}"

    new_url="git@${server}:${git_user}/${repo}"
    echo "Type the following to switch modes"
    echo "git remote set-url origin ${new_url}"

else
    # Switches a git repository from git to https
    repo="${git_url##*/}"
    server="${git_url%%/*}"
    git_user="${server##*:}"
    server="${server%%:*}"
    server="${server##*@}"

    new_url="https://${server}/${git_user}/${repo}"
    echo "git remote set-url origin ${new_url}"

fi

