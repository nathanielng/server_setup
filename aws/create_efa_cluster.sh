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
CLUSTER_NAME="my-efa-cluster"
IFACE=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNET_ID=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${IFACE}/subnet-id)
VPC_ID=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${IFACE}/vpc-id)
AZ=$(curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}

# Create the cluster configuration
mkdir -p ~/.parallelcluster
cat > ${CLUSTER_NAME}.ini << EOF
[aws]
aws_region_name = ${REGION}

[global]
cluster_template = default
update_check = false
sanity_check = true

[cluster default]
key_name = ${KEY_NAME}
vpc_settings = public
ebs_settings = myebs
compute_instance_type = c5n.18xlarge
master_instance_type = c5.2xlarge
cluster_type = ondemand
placement_group = DYNAMIC
placement = compute
max_queue_size = 4
initial_queue_size = 0
disable_hyperthreading = true
scheduler = slurm
enable_efa = compute
base_os = alinux2

[vpc public]
vpc_id = ${VPC_ID}
master_subnet_id = ${SUBNET_ID}

[ebs myebs]
shared_dir = /shared
volume_type = gp2
volume_size = 20

[aliases]
ssh = ssh {CFN_USER}@{MASTER_IP} {ARGS}
EOF

pcluster create ${CLUSTER_NAME} -c ${CLUSTER_NAME}.ini

date
echo "AWS ParallelCluster creation complete for: ${CLUSTER_NAME}"
echo "To connect to the cluster, type:"
echo "pcluster ssh ${CLUSTER_NAME} -i ~/.ssh/${KEY_NAME}"
echo
echo "To delete the cluster, type:"
echo "pcluster delete ${CLUSTER_NAME}"
