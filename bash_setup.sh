#!/bin/bash

FILE="$HOME/.bashrc"

echo "Setting up $FILE"
cat >> $FILE <<EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gitconfig='git config --local user.name && git config --local user.email'
EOF

which apt
if [ "$?" -eq 0 ]; then
    echo "alias update='sudo apt -y update && sudo apt -y upgrade'" >> $FILE
fi

