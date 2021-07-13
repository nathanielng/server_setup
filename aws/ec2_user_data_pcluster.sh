#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Cloud Init initiated on:"
date

# (1) Setup ~/.bash_profile
cat >> /home/ec2-user/.bash_profile <<EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"

HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

CLOUDWATCH_AGENT="/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl"
if [[ -f "$CLOUDWATCH_AGENT" ]]; then
    echo "Cloudwatch status:"
    sudo $CLOUDWATCH_AGENT -m ec2 -a status
    echo
fi

echo "This EC2 instance is running on:"
cat /etc/system-release
echo
echo "The current date/time is:"
date
EOF

# (2) Install Cloudwatch (CW) Agent
# +Bugfix (CW expects a certain database file to exist, even if empty)
yum update -y
yum install -y amazon-cloudwatch-agent
mkdir -p /usr/share/collectd/
touch /usr/share/collectd/types.db

# (3) Install Kernel Livepatch
yum install -y yum-plugin-kernel-livepatch
yum kernel-livepatch enable -y
systemctl enable kpatch.service
amazon-linux-extras enable livepatch

# (4) Install AWS CLI v2 (and remove AWS CLI v1)
pip3 uninstall -y awscli
sudo rm /usr/bin/aws

PROCESSOR=$(uname -p)
if [ "$PROCESSOR" == "x86_64" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
fi
unzip awscliv2.zip
sudo ./aws/install

# (5) Enable EPEL and install jq
amazon-linux-extras install -y epel
yum --enablerepo epel install -y moreutils
yum install -y gcc python3-devel jq-devel
pip3 install --upgrade pip setuptools wheel wildq
