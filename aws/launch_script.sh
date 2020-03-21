#!/bin/bash

# This is a launch script that may be copied to
# a new Virtual Machine instance


# ----- Update repositories -----
which yum
if [ "$?" -eq 0 ]; then
    sudo yum -y update
    sudo yum -y install git vim
fi

which apt
if [ "$?" -eq 0 ]; then
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt install git vim
fi


# ----- Bash Setup -----

FILE="$HOME/.bashrc"

echo "Setting up $FILE"
cat >> $FILE <<EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gitconfig='git config --local user.name && git config --local user.email'
HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
EOF

