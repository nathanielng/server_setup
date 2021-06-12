# AWS CLI Examples

## 1. EC2

Check IP address:

```bash
MY_IP_ADDR=`curl ifconfig.me`
MY_IP_ADDR=`curl v4.ifconfig.co`
MY_IP_ADDR=`curl https://checkip.amazonaws.com`
CIDR="{$MY_IP_ADDR}/32"
```

### 1.1 Instances

```bash
aws ec2 describe-instances
aws ec2 describe-instances help
aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservances[].InstanceId"
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

## 2. Pricing

```bash
aws pricing describe-services --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
aws pricing get-attribute-values --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2 --attribute-name instanceType
aws pricing get-products --max-results 1 --endpoint https://api.pricing.us-east-1.amazonaws.com --region us-east-1 --service-code AmazonEC2
```

