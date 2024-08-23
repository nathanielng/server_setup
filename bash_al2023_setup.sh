#!/bin/bash

cat >> /home/ec2-user/.bashrc << EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
HISTSIZE=50000
HISTFILESIZE=50000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF
source ~/.bashrc
