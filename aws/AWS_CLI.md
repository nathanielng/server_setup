# AWS CLI Examples

## 1. EC2

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

### 1.1 Instances

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


### 1.2 VPCs

Retrieve information on VPCs:

```bash
aws ec2 describe-vpcs
aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,CidrBlockAssociationSet[*].CidrBlock,Tags]"
```

### 1.3 Security Groups

Retrieve information on security groups:

```bash
aws ec2 describe-security-groups help
aws ec2 describe-security-groups --query "SecurityGroups[*].[Description,GroupName,GroupId]"
aws ec2 describe-security-groups --group-name $GROUP_NAME
aws ec2 describe-security-groups --filters Name=ip-permission.from-port,Values=22 --query "SecurityGroups[*].[GroupName]"
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

### 1.4 Keys

#### 1.4.1 EC2 Key Pairs

```bash
KEY_NAME="keypair-aws-${REGION}"
KEY_FILE="${HOME}/.ssh/${KEY_NAME}"
aws ec2 describe-key-pairs --key-name "${KEY_NAME}" --region ${REGION} > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
    aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material fileb://${KEY_FILE}.pub --region ${REGION}
fi
```

#### 1.4.2 KMS Keys

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


### 1.5 Capacity Reservations

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


## 2. IAM

### 2.1 Creating an IAM user with Administrator permissions and secret access keys

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


## 3. Cloudformation

```bash
aws cloudformation create-stack --stack-name mystackname --template-body file://mycfnstack.json --parameters file://path/parameters.json
aws cloudformation create-stack --stack-name mystackname --template-body file://mycfnstack.json --parameters ParameterKey=Key1,ParameterValue=Value1 ParameterKey=Key2,ParameterValue=Value2
aws cloudformation create-stack --stack-name mystackname --template-url "https://hostname.com/mycfnstack.json"
aws cloudformation deploy --template-file template.yaml --stack-name mystackname
```

## 4. Pricing

```bash
aws pricing describe-services --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
aws pricing get-attribute-values --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2 --attribute-name instanceType
aws pricing get-products --max-results 1 --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
```

## 5. SageMaker

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
