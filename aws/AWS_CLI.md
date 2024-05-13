# AWS CLI Examples

## 1. Quick Setup

Get the first key pair. For the default VPC in ap-southeast-1, get the default security group, and the default subnet corresponding to `apse1-az1`:

```bash
FIRST_KEY_PAIR=$(aws ec2 describe-key-pairs --query "KeyPairs[0].KeyName" --output text)
DEFAULT_VPC=$(aws ec2 describe-vpcs --filter Name=is-default,Values=true --query "Vpcs[].VpcId" --region ap-southeast-1 --output text)
DEFAULT_SUBNET=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=${DEFAULT_VPC} --filter Name=default-for-az,Values=true Name=availability-zone-id,Values=apse1-az1 --query "Subnets[].SubnetId" --output text)
DEFAULT_SG=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --filter "Name=vpc-id,Values=${DEFAULT_VPC}" "Name=group-name,Values=default")
```

## 2. EC2

Setup new EC2 instance:

```bash
cat >> ~/.bashrc << EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF
source ~/.bashrc
```

Check IP address:

```bash
MY_IP_ADDR=`curl ifconfig.me`
MY_IP_ADDR=`curl v4.ifconfig.co`
MY_IP_ADDR=`curl https://checkip.amazonaws.com`
CIDR="{$MY_IP_ADDR}/32"
```

Retrieve Account ID and region:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION=$(aws configure get region)
```

### 2.1 Instances

```bash
aws ec2 describe-instances
aws ec2 describe-instances help
aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservances[].InstanceId"
```

Get the EC2 instances in a specific region & availability zone

```bash
aws ec2 describe-instance-type-offerings --location-type "availability-zone" --filters Name=location,Values=us-east-2a --region us-east-2 --query "InstanceTypeOfferings[*].[InstanceType]" --output text | sort
```

Get EC2 image ids

```bash
aws ec2 describe-images --owners self amazon --filters "Name=root-device-type,Values=ebs"
aws ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query "Parameters[].Name"
pcluster list-official-images --os alinux2 --architecture x86_64
pcluster list-official-images --os ubuntu2204 --architecture arm64
```

Get list of EC2 AMI names, then choose the AMI ID corresponding to one of the names

```bash
aws ec2 describe-images --region $REGION --owners amazon --query 'reverse(sort_by(Images, &CreationDate))[].Name' > ami_names.json
AMI_ID=$(aws ec2 describe-images --region $REGION --owners amazon --filters "Name=name,Values='Deep Learning Base Proprietary Nvidia Driver GPU AMI (Ubuntu 20.04) 20240429'" --query 'Images[0].ImageId' --output text); echo $AMI_ID
```

Launch an EC2 Instance (specifying a name and EBS volume size)

```bash
REGION="ap-southeast-1"
KEYPAIR="AWS_KEYPAIR"
SECURITY_GROUP="sg-..."
SUBNET="subnet-..."
INSTANCE_TYPE="t3.large"
INSTANCE_NAME="t3l_spot_30G"
AMI_ID="resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"  # Amazon Linux 2023

# On-Demand Instance
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEYPAIR \
    --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET --ebs-optimized \
    --region $REGION --instance-initiated-shutdown-behavior terminate \
    --block-device-mapping "[ { \"DeviceName\": \"/dev/xvda\", \"Ebs\": { \"VolumeSize\": 20 } } ]" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]"

# Spot Instance
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEYPAIR \
    --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET --ebs-optimized \
    --block-device-mapping "[ { \"DeviceName\": \"/dev/xvda\", \"Ebs\": { \"VolumeSize\": 20 } } ]" \
    --instance-market-options MarketType=spot,SpotOptions={SpotInstanceType=one-time} \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" 
```

```bash
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" --output text --query 'Reservations[*].Instances[0].InstanceId')
PUBLIC_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" --output text --query 'Reservations[*].Instances[0].PublicIpAddress')
echo "Instance ID: $INSTANCE_ID (IP: $PUBLIC_IP)"
```

Check whether a specific EC2 instance type (such as `hpc6a.48xlarge`) is available in a specific Availability Zone

```bash
aws ec2 describe-reserved-instances-offerings --region ap-southeast-1 --availability-zone ap-southeast-1a --offering-type "No Upfront" --offering-class "standard" --max-duration 31536000 --filters "Name=instance-type,Values=hpc6a.48xlarge" "Name=product-description,Values=Linux/UNIX"
```



### 2.2 VPCs and Subnets

Retrieve information on VPCs:

```bash
aws ec2 describe-vpcs
aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,CidrBlockAssociationSet[*].CidrBlock,Tags]"
DEFAULT_VPC=$(aws ec2 describe-vpcs --filter Name=is-default,Values=true --query "Vpcs[].VpcId" --region ap-southeast-1 --output text)
```

Default subnet of default VPC: to get the first subnet, or the subnet corresponding to an availability zone ID such as `apse1-az1`:

```bash
aws ec2 describe-subnets --filter Name=vpc-id,Values=${DEFAULT_VPC} --filter Name=default-for-az,Values=true --query "Subnets[].SubnetId" --max-items 1 --output text | head -1
DEFAULT_SUBNET=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=${DEFAULT_VPC} --filter Name=default-for-az,Values=true Name=availability-zone-id,Values=apse1-az1 --query "Subnets[].SubnetId" --output text)
```

Get mappings between Availability Zone names and Zone IDs

```bash
aws ec2 describe-availability-zones --region ap-southeast-1 --query "[AvailabilityZones][].[ZoneName,ZoneId]"
```



### 2.3 Security Groups

Retrieve information on security groups:

```bash
aws ec2 describe-security-groups help
aws ec2 describe-security-groups --query "SecurityGroups[*].[Description,GroupName,GroupId]"
aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId --filter Name=group"
aws ec2 describe-security-groups --group-name $GROUP_NAME
aws ec2 describe-security-groups --filters Name=ip-permission.from-port,Values=22 --query "SecurityGroups[*].[GroupName]"
DEFAULT_SG=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --filter "Name=vpc-id,Values=${DEFAULT_VPC}" "Name=group-name,Values=default")
```

Create security group:

```bash
aws ec2 create-security-group help
aws ec2 create-security-group --group-name SSHFromMyIP --description "SSH from my IP address"
aws ec2 authorize-security-group-ingress --group-name SSHFromMyIP --protocol tcp --port 22 --cidr ${MY_IP_ADDR}/32
```

Modify security group permissions

```bash
aws ec2 describe-security-groups --group-name $GROUP_NAME
aws ec2 describe-security-groups --filters Name=ip-permission.from-port,Values=22 --query "SecurityGroups[*].[GroupName]"
aws ec2 revoke-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr $CIDR
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr $CIDR
```

### 2.4 Keys

#### 2.4.1 EC2 Key Pairs

```bash
KEY_NAME="keypair-aws-${REGION}"
KEY_FILE="${HOME}/.ssh/${KEY_NAME}"
aws ec2 describe-key-pairs --key-name "${KEY_NAME}" --region ${REGION} > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
    aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material fileb://${KEY_FILE}.pub --region ${REGION}
fi
```

```bash
aws ec2 describe-key-pairs --query "KeyPairs[].KeyName"  # Get all key pairs
FIRST_KEY_PAIR=$(aws ec2 describe-key-pairs --query "KeyPairs[0].KeyName" --output text)
```


### 2.5 Capacity Reservations

```bash
COUNT=0
for i in {1..1000}
do
  echo "Attempting to create a new EC2 reservation now:"
  aws ec2 create-capacity-reservation \
    --availability-zone ap-southeast-1a \
    --instance-type t3.nano \
    --instance-platform Linux/UNIX \
    --instance-count 1 \
    --end-date-type limited \
    --end-date 2024-12-31T23:59:59Z
  if [ "$?" -eq 0 ]; then
    COUNT=$((COUNT + 1))
    echo "Capacity reservation was successful"
    echo "Total reservations created so far: $COUNT"
    # echo "Attempting to launching EC2 instance"
    # aws ec2 run-instances \
    #   --image-id "<my-ami-id>" \
    #   --instance-type "t3.nano" \
    #   --key-name "<my-key-name>" \
    #   --count 1 \
    #   --instance-initiated-shutdown-behavior terminate \
    #   --region ap-southeast-1 \
    #   --subnet-id "subnet-12345678" \
    #   --security-group-ids "sg-01234567890123456"

    if [ "$COUNT" -ge 9 ]; then
      echo "Successfully reached ${COUNT} reservations. Script will terminate."
      break
    fi
  fi
 
  echo "Creating new EC2 capacity reservation in 15 mins..."
  sleep 300
  echo "Creating new EC2 capacity reservation in 10 mins..."
  sleep 300
  echo "Creating new EC2 capacity reservation in  5 mins..."
  sleep 300
done
```

### 2.6 [Extend a Linux file system after resizing a volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html)

```bash
sudo lsblk                     # check disk & partition names
sudo growpart /dev/nvme0n1 1   # extend partition on the disk nvme0n1
sudo lsblk                     # check that the disk (nvme0n1) and partition (nvme0n1p1) are the same size
df -hT                         # get name, size, type, and mount points for the file system
sudo xfs_growfs -d /           # extend the XFS file system mounted on / (XFS only)
sudo resize2fs /dev/nvme0n1p1  # extend the ext4 file system named /dev/nvme0n1p1 (ext4 only)
```


### 2.7 [Instance Metadata and IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)

```bash
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

Combined version

```bash
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

```bash
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AMI_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
EXTERNAL_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "AMI ID: $AMI_ID" && echo "Instance Type: $INSTANCE_TYPE" && echo "External IP Address: $EXTERNAL_IP"
```


## 3. IAM & KMS

### 3.1 Creating an IAM user with Administrator permissions and secret access keys

Create a new IAM group, and give adminstrator permissions to that group

```bash
aws iam create-group --group-name MyAdminGroup
aws iam attach-group-policy --group-name MyAdminGroup --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Create a new IAM user, and add that user to the IAM group created in the previous step

```bash
aws iam create-user --user-name MyAdminUser
aws iam add-user-to-group --user-name MyAdminUser --group-name MyAdminGroup
```

If you need to give the IAM admin user access to the AWS console, use:

```bash
aws iam create-login-profile --user-name MyAdminUser --password MyLoginPasswordHere123
```

If you need to generate a `SecretAccessKey` and `AccessKeyId` for use with the AWS CLI or with the AWS SDK, such as Python Boto3, use:

```bash
aws iam create-access-key --user-name MyAdminUser
```

As an example output, you will see something like the following:

```json
{
    "AccessKey": {
        "UserName": "MyAdminUser",
        "AccessKeyId": "AKIAXXXXX5XXXX3S4FK",
        "Status": "Active",
        "SecretAccessKey": "1cXXXxxx0x9xXxXxxXXXxXXXXXxxX5XX+XxXEkvQ",
        "CreateDate": "2023-11-09T03:27:13+00:00"
    }
}
```


### 3.2 KMS Keys

Look up the creation of a specific KMS key in Cloudtrail

```bash
REGION="ap-southeast-1"
aws cloudtrail lookup-events --region $REGION --lookup-attributes AttributeKey=EventName,AttributeValue=CreateKey
aws cloudtrail lookup-events --region $REGION --lookup-attributes AttributeKey=EventName,AttributeValue=CreateStack
aws cloudformation list-stacks --region $REGION
aws cloudformation list-stacks --region $REGION --query "StackSummaries[*].StackName"
aws cloudformation list-stacks --region $REGION --query "StackSummaries[*].[StackName,StackId]" --output table
aws kms list-keys --region $REGION --output table
aws kms list-keys --region $REGION --query "Keys[*].KeyId"
aws kms list-keys --region $REGION --query "Keys[*].KeyId" --output text | xargs -n 1 echo
```

Select the first KMS key and get its creation date

```bash
KMS_KEY0=$(aws kms list-keys --region $REGION --query "Keys[0].KeyId" --output text)
aws kms describe-key --region $REGION --key-id $KMS_KEY0
aws kms describe-key --region $REGION --key-id $KMS_KEY0 --query "KeyMetadata.CreationDate"
```



## 4. S3

### 4.1 File Sharing

```bash
# Share file in S3 bucket using pre-signed URLs
aws s3 presign s3://mys3bucket/folder/filename --expires-in 604800

# Download file
curl -o "filename" "https://mys3bucket.s3.{REGION}.amazonaws.com/folder/filename?..."
```


## 5. Cloudformation

```bash
aws cloudformation create-stack --stack-name mystackname --template-body file://mycfnstack.json --parameters file://path/parameters.json
aws cloudformation create-stack --stack-name mystackname --template-body file://mycfnstack.json --parameters ParameterKey=Key1,ParameterValue=Value1 ParameterKey=Key2,ParameterValue=Value2
aws cloudformation create-stack --stack-name mystackname --template-url "https://hostname.com/mycfnstack.json"
aws cloudformation deploy --template-file template.yaml --stack-name mystackname
aws cloudformation validate-template --template-body file://my_cloudformation_file.yaml
```


## 6. Pricing

```bash
aws pricing describe-services --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
aws pricing get-attribute-values --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2 --attribute-name instanceType
aws pricing get-products --max-results 1 --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
```

## 7. SageMaker

Check for active SageMaker resources and delete them

```bash
REGION="ap-southeast-1"
aws sagemaker --region $REGION list-endpoints --output text | xargs -n 1 echo
aws sagemaker --region $REGION list-training-jobs --status-equals InProgress --max-results 50
aws sagemaker --region $REGION list-processing-jobs --status-equals InProgress
aws sagemaker --region $REGION list-notebook-instances --status-equals InService
aws sagemaker --region $REGION list-transform-jobs --status-equals InProgress
aws sagemaker --region $REGION list-hyper-parameter-tuning-jobs --status-equals InProgress
aws sagemaker --region $REGION list-data-quality-job-definitions
aws sagemaker --region $REGION list-compilation-jobs
```

```bash
aws sagemaker --region $REGION list-endpoint-configs
aws sagemaker --region $REGION describe-endpoint-config --endpoint-config-name <endpoint-config-name>
aws sagemaker --region $REGION list-inference-components
aws sagemaker --region $REGION list-inference-components --endpoint-name <endpoint_name>
```

```bash
aws sagemaker --region $REGION delete-endpoint --endpoint-name <endpoint-name>
aws sagemaker --region $REGION delete-inference-component <component_name>
aws sagemaker --region $REGION delete-endpoint-config --endpoint-config-name <endpoint-config-name>
aws sagemaker --region $REGION delete-model --model-name <model-name>
```
