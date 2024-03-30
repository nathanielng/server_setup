# LAMBDA MONITOR

## 1. Description

This is a Lambda function that helps to monitor other AWS Accounts that you have control of

## 2. Setup

### 2.1 Lambda Function

#### 2.1.1 Lambda Function Python Code

```python
import json
import boto3
import datetime
import json

sts = boto3.client('sts')

# ----- STS -----
def get_session(role_arn):
    resp = sts.assume_role(
        RoleArn=role_arn,
        RoleSessionName='session'
    )
    return boto3.Session(
        aws_access_key_id=resp['Credentials']['AccessKeyId'],
        aws_secret_access_key=resp['Credentials']['SecretAccessKey'],
        aws_session_token=resp['Credentials']['SessionToken']
    )

# ----- Cost Explorer -----
def get_monthly_spend(ce, start_date=None, end_date=None):
    now = datetime.datetime.now()
    if start_date is None:
        start_date = now.strftime('%Y-%m-01')
    if end_date is None:
        end_date = now.strftime('%Y-%m-%d')

    r = ce.get_cost_and_usage(
        TimePeriod={'Start': start_date, 'End': end_date},
        Granularity='MONTHLY',
        Metrics=['BlendedCost'])
    cost = r['ResultsByTime'][0]['Total']['BlendedCost']
    return f"{cost['Unit']} {float(cost['Amount']):.2f}"

# ----- EC2 -----
def describe_instances(ec2):
    r = ec2.describe_instances()
    output = 'InstanceId,Name,InstanceType,PublicIpAddress,InstanceState'
    for reservation in r['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            instance_type = instance['InstanceType']
            instance_ip = instance.get('PublicIpAddress', '(no public ip)')

            instance_name = '(no name)'
            for tag in instance['Tags']:
                if tag['Key'] == 'Name':
                    instance_name = tag['Value']

            instance_state = instance['State']['Name']
            output += f'\n{instance_id},{instance_name},{instance_type},{instance_ip},{instance_state}'
    return output

def stop_instances(ec2):
    r = ec2.describe_instances()
    instance_ids_stopped = []
    for reservation in r['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            ec2.stop_instances(
                InstanceIds=[ instance_id ]
            )
            instance_ids_stopped.append(instance_id)
    return instance_ids_stopped

def lambda_handler(event, context):
    account_id = event['account_id']
    actions = event['actions']
    regions = event['regions']

    session = get_session(f"arn:aws:iam::{account_id}:role/OrganizationAccountAccessRole")

    result = {}

    if 'get_monthly_spend' in actions:
        ce = boto3.client('ce')
        root_account_spend = get_monthly_spend(ce)
        print(f'Monthly spend of root account is USD {root_account_spend}')

        ce = session.client('ce')
        child_account_spend = get_monthly_spend(ce)
        print(f'Monthly spend of {account_id} is USD {child_account_spend}')
        result['Monthly Spend'] = {
            'root': root_account_spend,
            account_id: child_account_spend
        }
        
        sns = boto3.client('sns')
        response = sns.publish(
            TopicArn='arn:aws:sns:ap-southeast-1:856952634940:CostReport',
            Message=f'Your AWS Usage is:\n- Root account: {root_account_spend}\n- Account ID {account_id}: {child_account_spend}',
            Subject='AWS Current Usage'
        )

    if 'describe_ec2' in actions:
        ec2_descriptions = {}
        for region in regions:
            ec2 = session.client('ec2', region_name = region)
            ec2_description = f'----- EC2 Instances ({region}) -----\n' + \
            describe_instances(ec2)
            print(ec2_description)
            ec2_descriptions[region] = ec2_description
        result['ec2'] = ec2_descriptions

    if 'stop_ec2' in actions:
        ec2_actions = {}
        for region in regions:
            ec2 = session.client('ec2', region_name = region)
            instance_ids_stopped = stop_instances(ec2)
            ec2_actions[region] = {
                'Stopped EC2s': instance_ids_stopped
            }
            print(f'Region {region}: EC2s stopped: ' + ','.join(instance_ids_stopped))
        result['ec2'] = ec2_actions

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
```

#### 2.1.2 Lambda Function Execution Role

Replace `account-checker` with the name of the Lambda function log group
Replace `AWS_ACCOUNT_ID_ROOT` with the AWS Account ID of the Lambda function
Replace `AWS_ACCOUNT_ID_CHILD` with the AWS Account ID of the child account that is being monitored

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-southeast-1:AWS_ACCOUNT_ID_ROOT:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-southeast-1:AWS_ACCOUNT_ID_ROOT:log-group:/aws/lambda/account-checker:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::AWS_ACCOUNT_ID_CHILD:role/OrganizationAccountAccessRole"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "ce:GetCostAndUsage"
            ],
            "Resource": "*"
        }
    ]
}
```

#### 2.1.3 Child AWS Account

Create a role `OrganizationAccountAccessRole `

Permissions

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
```

Trust relationships. Replace `ROLE_OF_LAMBDA_FUNCTION` with the role of the Lambda function and `NAME_OF_LAMBDA_FUNCTION` with the name of the Lambda function.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::856952634940:root",
                    "arn:aws:sts::856952634940:assumed-role/ROLE_OF_LAMBDA_FUNCTION/NAME_OF_LAMBDA_FUNCTION"
                ]
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
```
