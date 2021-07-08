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

cat << EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"logs": {
		"logs_collected": {
			"files": {
				"collect_list": [
					{
						"file_path": "/var/log/secure",
						"log_group_name": "/var/log/secure",
						"log_stream_name": "{instance_id}"
					},
					{
						"file_path": "/var/log/httpd/access_log",
						"log_group_name": "/var/log/httpd/access_log",
						"log_stream_name": "{instance_id}"
					},
					{
						"file_path": "/var/log/httpd/error_log",
						"log_group_name": "/var/log/httpd/error_log",
						"log_stream_name": "{instance_id}"
					}
				]
			}
		}
	},
	"metrics": {
		"append_dimensions": {
			"AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
			"ImageId": "\${aws:ImageId}",
			"InstanceId": "\${aws:InstanceId}",
			"InstanceType": "\${aws:InstanceType}"
		},
		"metrics_collected": {
			"collectd": {
				"metrics_aggregation_interval": 60
			},
			"disk": {
				"measurement": [
					"used_percent"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
			"statsd": {
				"metrics_aggregation_interval": 60,
				"metrics_collection_interval": 10,
				"service_address": ":8125"
			}
		}
	}
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# (3) Install Kernel Livepatch
yum install -y yum-plugin-kernel-livepatch
yum kernel-livepatch enable -y
systemctl enable kpatch.service
amazon-linux-extras enable livepatch

# (4) Install LAMP Stack
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
systemctl is-enabled httpd

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# (5) Install NFS Client & Mount EFS (requires parameter store entries to be set up)
# REGION="ap-southeast-1"
# PARAMTER_EFSID="/ExampleApp/EFSFSID"
# EFSFSID=$(aws ssm get-parameters --region $REGION --names $PARAMETER_EFSID --query Parameters[0].Value)
# EFSFSID=`echo "$EFSFSID" | tr -d '"'`

# yum -y install amazon-efs-utils nfs-utils
# file_system_id_1=${EFSFSID}
# efs_mount_point_1=/mnt/efs/fs1

# mkdir -p "${efs_mount_point_1}"
# chown ec2-user:ec2-user "${efs_mount_point_1}"
# test -f "/sbin/mount.efs" && printf "${EFSFSID}:/ ${efs_mount_point_1} efs iam,tls,_netdev 0 0\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.ap-southeast-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
# test -f "/sbin/mount.efs" && printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf
# retryCnt=5; waitTime=20; while true; do mount -a -t efs,nfs4 defaults; if [ "$?" -eq 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;

# (6) Enable EPEL
# amazon-linux-extras install -y epel

# (7) Install AWS CLI v2 (and remove AWS CLI v1)
# pip3 uninstall -y awscli
# sudo rm /usr/bin/aws

# PROCESSOR=$(uname -p)
# if [ "$PROCESSOR" == "x86_64" ]; then
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# else
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
# fi
# unzip awscliv2.zip
# sudo ./aws/install

echo "Cloud Init completed successfully on:"
date
