# AWS Documentation

## 1. Credentials

- Generate AWS Security Credentials [here](https://console.aws.amazon.com/iam/home?#security_credential)
- Store the keys in the following file `~/.aws/credentials`

## 2. EC2

### 2.1 Overview

- [Launching New Instances](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/migrationec2.html#launching-new-instances)

### 2.2 Reference

- [`EC2.ServiceResource.create_instances()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.ServiceResource.create_instances) - [sample code](https://docs.aws.amazon.com/code-samples/latest/catalog/python-ec2-create_instance.py.html)
- [`EC2.Client.authorize_security_group_ingress()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.authorize_security_group_ingress)
- [`EC2.Client.create_key_pair()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_key_pair)
- [`EC2.Client.create_security_group()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_security_group)
- [`EC2.Client.describe_instances()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_instances)
- [`EC2.Client.describe_key_pairs()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_key_pairs)
- [`EC2.Client.describe_security_groups()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_security_groups)
- [`EC2.Client.run_instances()`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.run_instances)

### 2.3 Session Manager Access

- Create a key in KMS and note down its ARN
- Copy the policy from [this link](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-add-permissions-to-existing-profile.html)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "key-name"
        }
    ]
}
```

- In the IAM console, create a policy with the JSON above, replacing the text "key-name" with the full ARN of a KMS key that was just created.
