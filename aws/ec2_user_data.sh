#!/bin/bash

# Setup ~/.bash_profile

cat >> /home/ec2-user/.bash_profile <<EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export LC_ALL="en_US.UTF-8"

HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

cat /etc/system-release 
EOF

# Install Cloudwatch (CW) Agent
# +Bugfix (CW expects a certain database file to exist, even if empty)
yum update -y
yum install -y amazon-cloudwatch-agent
mkdir -p /usr/share/collectd/
touch /usr/share/collectd/types.db

# Install Kernel Livepatch
yum install -y yum-plugin-kernel-livepatch
yum kernel-livepatch enable -y
systemctl enable kpatch.service
amazon-linux-extras enable livepatch

# Install LAMP Stack
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
systemctl is-enabled httpd

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
