#!/bin/bash

FILE="$HOME/.bashrc"

echo "Setting up $FILE"
cat >> $FILE <<EOF
export PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '
export SUDO_PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '
alias ls='ls --color=auto'
alias grep='grep --color=auto'
HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
EOF

