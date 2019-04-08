#!/bin/bash

FILE="$HOME/.ssh/id_ed25519"
ssh-keygen -o -a 100 -t ed25519 -f $FILE -C "$USER@$HOSTNAME"

