#!/bin/bash

# (1) Create SSH key, if it does not already exist
KEY_FILE="$HOME/.ssh/id_rsa"
if [ ! -e "${KEY_FILE}" ]; then
    ssh-keygen -t rsa -b 4096 -f ${KEY_FILE} -q -N ""
fi

# (2) Import key pair, if it has not already been imported
IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
KEY_NAME="keypair-${INSTANCE_ID}"

aws ec2 describe-key-pairs --key-name "${KEY_NAME}" 2> /dev/null
if [ "$?" -ne 0 ]; then
    aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material fileb://${KEY_FILE}.pub
fi

# (3) Set Environment Variables
MASTER_INSTANCE_TYPE="t3.micro"
SINGLE_NODE_INSTANCE_TYPE="m6i.16xlarge"
SINGLE_NODE_INSTANCE_TYPE_SPOTPRICE="2"
SMALL_JOB_INSTANCE_TYPE="m6i.32xlarge"
SMALL_JOB_INSTANCE_TYPE_SPOTPRICE="4"
LARGE_JOB_INSTANCE_TYPE="c5n.18xlarge"
LARGE_JOB_INSTANCE_TYPE_SPOTPRICE="3"
CLUSTER_NAME="mypcluster"
S3_BUCKET="pcluster-${INSTANCE_ID}"

MAC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/subnet-id)
VPC_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-id)
REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
COMPUTE_SUBNET_ID="$SUBNET_ID"

# (4) Install Node Version Manager and Node.js
which node
if [[ "$?" -ne 0 ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    mkdir -p ~/.nvm
    ~/.nvm/nvm.sh
    nvm install node
fi
echo "----- Node JS Version -----"
node --version

# (5) Install AWS ParallelCluster
which pcluster
if [[ "$?" -ne 0 ]]; then
    python3 -m pip install "aws-parallelcluster" --upgrade --user
fi

cat > ~/.parallelcluster/cluster-config.yaml << EOF
Region: ${REGION}
Image:
  Os: centos7
HeadNode:
  InstanceType: ${MASTER_INSTANCE_TYPE}
  Networking:
    SubnetId: ${SUBNET_ID}
  Ssh:
    KeyName: ${KEY_NAME}
Scheduling:
  Scheduler: slurm
  SlurmQueues:
  - Name: smalljobq
    ComputeResources:
    - Name: singlenode
      InstanceType: ${SINGLE_NODE_INSTANCE_TYPE}
      MinCount: 0
      MaxCount: 5
      SpotPrice: ${SINGLE_NODE_INSTANCE_TYPE_SPOTPRICE}
      DisableSimultaneousMultithreading: true
    - Name: smalljob
      InstanceType: ${SMALL_JOB_INSTANCE_TYPE}
      MinCount: 0
      MaxCount: 5
      SpotPrice: ${SMALL_JOB_INSTANCE_TYPE_SPOTPRICE}
      DisableSimultaneousMultithreading: true
      Efa:
        Enabled: true
    Networking:
      SubnetIds:
      - ${COMPUTE_SUBNET_ID}
      PlacementGroup:
        Enabled: true
  - Name: largejobq
    ComputeResources:
    - Name: largejob
      InstanceType: ${LARGE_JOB_INSTANCE_TYPE}
      MinCount: 0
      MaxCount: 10
      SpotPrice: ${LARGE_JOB_INSTANCE_TYPE_SPOTPRICE}
      DisableSimultaneousMultithreading: true
      Efa:
        Enabled: true
    Networking:
      SubnetIds:
      - ${COMPUTE_SUBNET_ID}
      PlacementGroup:
        Enabled: true
Tags:
  - Key: CostCategory
    Value: PCluster
AdditionalPackages:
  IntelSoftware:
    IntelHpcPlatform: true
EOF

echo "----- AWS ParallelCluster -----"
pcluster version
echo
cp ~/.parallelcluster/cluster-config.yaml my-cluster-config.yaml
echo "Commands to launch cluster:"
echo "pcluster create-cluster --region ${REGION} --cluster-configuration my-cluster-config.yaml --cluster-name ${CLUSTER_NAME}"
echo
echo "Commands to log in to cluster:"
echo "pcluster ssh --region ${REGION} --cluster-name ${CLUSTER_NAME} -i ${KEY_FILE}"
