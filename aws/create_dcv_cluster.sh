#!/bin/bash

date
# Generate keypair
INSTANCE_ID=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)
KEY_NAME="keypair-$INSTANCE_ID"

if [[ ! -e "~/.ssh/${KEY_NAME}" ]]; then
    aws ec2 describe-key-pairs --key-name $KEY_NAME 2> /dev/null
    if [[ "$?" -ne 0 ]]; then
        aws ec2 create-key-pair --key-name ${KEY_NAME} --query KeyMaterial --output text > ~/.ssh/${KEY_NAME}
    else
        echo "Cannot create EC2 key pair ${KEY_NAME} because it already exists"
        exit 1
    fi
fi
chmod 600 ~/.ssh/${KEY_NAME}

# Setup Environment Variables
CLUSTER_NAME="my-dcv-cluster"
IFACE=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNET_ID=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${IFACE}/subnet-id)
VPC_ID=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${IFACE}/vpc-id)
AZ=$(curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}

# Create the cluster configuration
cd ~/environment
cat > ${CLUSTER_NAME}.ini << EOF
[aws]
aws_region_name = ${REGION}

[global]
cluster_template = default
update_check = false
sanity_check = true

[cluster default]
key_name = ${KEY_NAME}
base_os = centos7
vpc_settings = public
master_instance_type = g4dn.xlarge
compute_instance_type = c5.xlarge
cluster_type = ondemand
placement_group = DYNAMIC
placement = compute
initial_queue_size = 0
max_queue_size = 8
disable_hyperthreading = true
s3_read_write_resource = *
scheduler = slurm
dcv_settings = default

[dcv default]
enable = master

[vpc public]
vpc_id = ${VPC_ID}
master_subnet_id = ${SUBNET_ID}

[aliases]
ssh = ssh {CFN_USER}@{MASTER_IP} {ARGS}
EOF

pcluster create ${CLUSTER_NAME} -c ${CLUSTER_NAME}.ini

date
echo "AWS ParallelCluster creation complete for: ${CLUSTER_NAME}"
echo "To connect to the cluster, type:"
echo "pcluster dcv connect ${CLUSTER_NAME} -k ~/.ssh/${KEY_NAME}"
echo
echo "To ssh into the cluster, type:"
echo "pcluster ssh ${CLUSTER_NAME} -i ~/.ssh/${KEY_NAME}"
echo
echo "To delete the cluster, type:"
echo "pcluster delete ${CLUSTER_NAME}"
