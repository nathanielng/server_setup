# LAMBDA MONITOR

## 1. Description

This is a Lambda function that helps to monitor other AWS Accounts that you have control of

## 2. Setup (Main AWS Account)

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
        if now.day == 1:
            end_date = now.strftime('%Y-%m-02')
        else:
            end_date = now.strftime('%Y-%m-%d')

    r = ce.get_cost_and_usage(
        TimePeriod={'Start': start_date, 'End': end_date},
        Granularity='MONTHLY',
        Metrics=['BlendedCost'])
    cost = r['ResultsByTime'][0]['Total']['BlendedCost']
    spend, unit = float(cost['Amount']), cost['Unit']
    # print(f"Monthly spend: {unit} {spend:.2f}")
    return spend, unit

def get_yesterdays_spend(ce, max_items=10, threshold=0.01):
    now = datetime.datetime.now()
    yesterday = now - datetime.timedelta(days=1)
    start_date = yesterday.strftime('%Y-%m-%d')
    end_date = now.strftime('%Y-%m-%d')

    r = ce.get_cost_and_usage(
        TimePeriod={'Start': start_date, 'End': end_date},
        Granularity='DAILY',
        Metrics=['BlendedCost'],
        GroupBy=[{
            'Type': 'DIMENSION',
            'Key': 'USAGE_TYPE'
        }])
    results = r['ResultsByTime'][0]['Groups']

    spend = []
    for x in results:
        cost = x['Keys'][0]
        amount = float(x['Metrics']['BlendedCost']['Amount'])
        if amount >= threshold:
            spend.append(
                (cost, amount)
            )
    top_spend = sorted(spend, key=lambda x: x[1], reverse=True)
    return top_spend

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
    account_ids = event['account_ids']
    actions = event['actions']
    regions = event['regions']
    topic_arn = event.get('topic_arn', None)
    stop_ec2_threshold = event['stop_ec2_threshold']

    results = {}
    if 'report_spend' in actions:
        spend = {}
        for account_id in account_ids:
            session = get_session(f"arn:aws:iam::{account_id}:role/OrganizationAccountAccessRole")
            ce = session.client('ce')
            child_account_spend, unit = get_monthly_spend(ce)
            child_account_top_spend = get_yesterdays_spend(ce)
            spend[account_id] = {
                "Monthly spend": child_account_spend,
                "Yesterday's spend": child_account_top_spend
            }
            # print(f"{account_id}: {unit} {child_account_spend:.2f}")
        results['Spend'] = spend
        
        # Create and send message
        message = 'AWS Accounts - Monthly Spend\n'
        for account_id in account_ids:
            message += f'\n - Account ID: {account_id} - USD {spend[account_id]["Monthly spend"]}'
        print(message)

        if topic_arn is not None:
            sns = boto3.client('sns')
            response = sns.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject='AWS Current Usage'
            )

    if 'stop_ec2' in actions:
        ec2_actions = {}
        for account_id in account_ids:
            session = get_session(f"arn:aws:iam::{account_id}:role/OrganizationAccountAccessRole")
            ce = session.client('ce')
            child_account_spend, _ = get_monthly_spend(ce)
            if child_account_spend > stop_ec2_threshold:
                ec2_actions[account_id] = {}
                for region in regions:
                    ec2 = session.client('ec2', region_name = region)
                    instance_ids_stopped = stop_instances(ec2)
                    ec2_actions[account_id][region] = {
                        'Stopped EC2s': instance_ids_stopped
                    }
                    print(f'Region {region}: EC2s stopped: ' + ','.join(instance_ids_stopped))
        results['ec2'] = ec2_actions

    return {
        'statusCode': 200,
        'body': json.dumps(results)
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
            "Action":
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

Trust Relationships (leave this as default)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```


#### 2.1.3 Lambda Function Test Event

In the Lambda fucntion create a **Test event** with the following Event JSON:

- replace `AWS_ACCOUNT_ID_CHILD` with the account number of child account, e.g. `012345678901`.
- replace `us-east-`, `us-west-2`, `ap-southeast-1` with the regions that you wish to monitor.

```json
{
  "account_ids": [
    "AWS_ACCOUNT_ID_CHILD"
  ],
  "actions": [
    "report_spend", "stop_ec2"
  ],
  "regions": [
    "us-east-1",
    "us-west-2",
    "ap-southeast-1"
  ],
  "stop_ec2_threshold": 2000.0,
  "topic_arn": "arn:aws:sns:REGION:AWS_ACCOUNT_ID_ROOT:CostReport"
}
```


#### 2.1.4 Lambda Function Configuration

Timeout: at least ~20 seconds


### 2.2 SNS

1. Create Topic, Type=Standard, Name=`CostReport`
2. Create subscription, Protocol=Email, Endpoint=`youremail@yourdomain.com`
3. Copy the Topic ARN which should have the following format: `arn:aws:sns:REGION:AWS_ACCOUNT_ID_ROOT:CostReport`
4. When you have received the email, click the link to confirm your subscription.


### 2.3 EventBridge

1. In the Lambda function click on "Add trigger"
2. For Trigger Source, choose "EventBridge (CloudWatch Events). Choose "Create a new rule". For Rule name, choose something like "DailyChecks". For Rule type, choose "Schedule expression". Enter something like "cron(0 9 * * ? *)". This runs when: minutes=0, hours=9, day_of_month=ANY, month=ANY, day_of_week=ANY, year=ANY. In other words, this Lambda function will be triggered at 9am every day, whereby an email will be sent to your inbox.
3. Under **Targets**, **Additional settings**, for "Configure target input" specify "Constant (JSON text).
4. Put the following inside the JSON text

```json
{
  "account_ids": [
    "AWS_ACCOUNT_ID_CHILD"
  ],
  "actions": [
    "report_spend", "stop_ec2"
  ],
  "regions": [
    "us-east-1",
    "us-west-2",
    "ap-southeast-1"
  ],
  "stop_ec2_threshold": 20.0,
  "topic_arn": "arn:aws:sns:REGION:AWS_ACCOUNT_ID_ROOT:CostReport"
}
```

## 3. Child AWS Account

### 3.1 IAM Role

Create a role `OrganizationAccountAccessRole` with the following permissions

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

Set the Trust relationships to the following.
Replace `ROLE_OF_LAMBDA_FUNCTION` with the role of the Lambda function and `NAME_OF_LAMBDA_FUNCTION` with the name of the Lambda function.

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
