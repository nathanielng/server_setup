# AWS CLI Examples

## 1. EC2

Check IP address:

```bash
MY_IP_ADDR=`curl ifconfig.me`
MY_IP_ADDR=`curl https://checkip.amazonaws.com`
CIDR="{$MY_IP_ADDR}/32"
```

### 1.1 Instances

```bash
aws ec2 describe-instances
aws ec2 describe-instances help
aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservances[].InstanceId"
```

### 1.2 Security Groups

Retrieve information on security groups:

```bash
aws ec2 describe-security-groups help
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
