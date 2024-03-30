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

def lambda_handler(event, context):
    session = get_session(f"arn:aws:iam::" + event['account_id'] + ":role/OrganizationAccountAccessRole")
    ce = session.client('ce')
    spend = get_monthly_spend(ce)
    result = { 'Monthly Spend': spend }
    print(f'Monthly spend is {spend}')

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
