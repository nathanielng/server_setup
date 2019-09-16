# AWS Documentation

## 1. Credentials

- Generate AWS Security Credentials [here](https://console.aws.amazon.com/iam/home?#security_credential)
- Store the keys in the following file `~/.aws/credentials`

## 2. EC2

- [`EC2.ServiceResource.create_instances()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.ServiceResource.create_instances) - [sample code](https://docs.aws.amazon.com/code-samples/latest/catalog/python-ec2-create_instance.py.html)
- [`EC2.Client.authorize_security_group_ingress()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.authorize_security_group_ingress)
- [`EC2.Client.create_security_group()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_security_group)
- [`EC2.Client.describe_security_groups()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_security_groups)