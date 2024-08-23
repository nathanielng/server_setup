# Server Setup

## 1. Description

This git repository contains scripts for setting up remote servers.
It contains both bash scripts to build packages from source,
as well as docker files to build docker images.

## 2. Folders

- `docker/`: this folder contains Dockerfiles and Docker Compose (`docker-compose.yml`) files
  for multi-container builds.
- `dpkg/`: this folder contains build scripts where dependencies are installed via `apt`.
  Mostly for builds on Debian (and possibly also Ubuntu)
- `yum/`: this folder contains build scripts where dependencies are installed via `yum`.
  Mostly for builds on Amazon Linux.
- `scripts/`: this folder contains build scripts that do not involve package managers
  such as `apt`, `yum`, or `apk`.


## 3. Quick setup for a new server

### 3.1 SSH Keys

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
```

```bash
cd ~/.ssh/
KEY_NAME="keypair-use1"; KEY_FILE="keypair-use1.pem"; REGION="us-east-1"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/$KEY_FILE -q -N ""
aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material fileb://${KEY_FILE}.pub --region ${REGION}
```

### 3.2 Shell

#### 3.2.1 Bash

Customize `~/.bashrc` as follows:

```bash
cat >> ~/.bashrc << EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
HISTSIZE=50000
HISTFILESIZE=50000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF
source ~/.bashrc
```

Example EC2 user data

```bash
curl -s https://raw.githubusercontent.com/nathanielng/server_setup/master/bash_al2023_setup.sh | bash
```

#### 3.2.2 Zsh + Starship

Check current shell

```bash
echo $SHELL
```

Change shell to Zsh using:

```bash
chsh -s /bin/zsh
```

Install Starship as follows:

```zsh
curl -sS https://starship.rs/install.sh | sh
```

Customize `~/.zshrc` as follows:

```zsh
cat >> ~/.zshrc << EOF
export PS1="%F{green}%n@%m%f %F{red}%W%f %F{yellow}%1~%f %# "
export SUDO_PS1="%F{green}%n@%m%f %F{red}%W%f %F{yellow}%1~%f %# "
export HISTFILE=~/.zsh_history
export HISTSIZE=20000
export SAVEHIST=\$HISTSIZE
eval "\$(starship init zsh)"
EOF
```

#### 3.2.3 Instance Metadata

```bash
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_TYPE=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type` && echo $INSTANCE_TYPE
INSTANCE_ID=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id` && echo $INSTANCE_ID
AMI_ID=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id` && echo $AMI_ID
PUBLIC_IP=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4` && echo $PUBLIC_IP
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

### 3.3 Git

```bash
git config --global credential.helper store
git config --global credential.helper 'cache --timeout=604800'  # 1 week
git clone https://github.com/{git_username}/{project_name}
```

```bash
GIT_USERNAME=$(git --no-pager show -s --format='%an' HEAD)
GIT_USEREMAIL=$(git --no-pager show -s --format='%ae' HEAD)
git config --local user.name "$GIT_USERNAME"
git config --local user.email "$GIT_USEREMAIL"
```


### 3.4 Python

```bash
curl -Os https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip install virtualenv
cd ~
virtualenv ~/venv -p python3
source ~/venv/bin/activate
```

### 3.5 Node.js [via nvm](https://nodejs.org/en/download/package-manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20
```
