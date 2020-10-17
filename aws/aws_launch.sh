#!/bin/bash
GIT_GLOBAL_USER=`git config --global user.name`
GIT_GLOBAL_EMAIL=`git config --global user.email`
GIT_GLOBAL_EDITOR=`git config --global core.editor`
python aws_setup.py --launch_instance \
    --git_user "$GIT_GLOBAL_USER" \
    --git_email "$GIT_GLOBAL_EMAIL" \
    --git_editor "$GIT_GLOBAL_EDITOR"
