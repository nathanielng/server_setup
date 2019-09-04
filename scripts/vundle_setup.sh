#!/bin/bash
INSTALL_PATH="$HOME/.vim/bundle/Vundle.vim"
if [ -e "$INSTALL_PATH" ]; then
    echo "Vundle directory already exists"
    echo "No installation steps will be taken"
else
    git clone https://github.com/gmarik/Vundle.vim.git $INSTALL_PATH
    touch $HOME/.vimrc
fi
