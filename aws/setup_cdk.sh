#!/bin/bash

# Add the following to EC2 User Data
# curl -o- https://raw.githubusercontent.com/nathanielng/server_setup/refs/heads/master/aws/setup_cdk.sh | bash

# Setup NodeJS & AWS CDK
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install --lts
npm install -g aws-cdk

# Setup Python 3.11
sudo dnf install -y python3.11
curl -Os https://bootstrap.pypa.io/get-pip.py
python3.11 get-pip.py
python3.11 -m pip install virtualenv
python3.11 -m virtualenv $HOME/venv

# Setup Docker
yum -y update && yum -y install docker
chgrp docker $(which docker)
chmod g+s $(which docker)
systemctl enable docker.service
systemctl start docker.service
