#!/bin/bash
# Copies the global git configuration name & email
# to the local git configuration

GIT_USER_NAME=`git config --global user.name`
GIT_USER_EMAIL=`git config --global user.email`

if [ "$GIT_USER_NAME" = "" ]; then
    echo "git global user name is not defined"
    exit 1
fi

if [ "$GIT_USER_EMAIL" = "" ]; then
    echo "git global user email is not defined"
    exit 1
fi

echo "Run git config --local user.name \"${GIT_USER_NAME}\" (y/n)?"
read ans
if [[ "${ans:0:1}" =~ [Yy] ]]; then
    git config --local user.name "${GIT_USER_NAME}"
fi

echo "Run git config --local user.email \"${GIT_USER_EMAIL}\" (y/n)?"
read ans
if [[ "${ans:0:1}" =~ [Yy] ]]; then
    git config --local user.email "${GIT_USER_EMAIL}"
fi

