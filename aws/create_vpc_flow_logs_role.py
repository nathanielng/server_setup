#!/usr/bin/env python3

import boto3
import json

def create_vpc_flow_logs_role():
    iam = boto3.client('iam')
    
    role_name = 'VPCFlowLogsRole'
    policy_name = 'VPCFlowLogsPolicy'
    
    # Trust policy for VPC Flow Logs service
    trust_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "vpc-flow-logs.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    
    # Permissions policy for CloudWatch Logs
    permissions_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams"
                ],
                "Resource": "*"
            }
        ]
    }
    
    try:
        # Create IAM role
        print(f"Creating IAM role: {role_name}")
        iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy),
            Description='IAM role for VPC Flow Logs to write to CloudWatch Logs'
        )
        
        # Create and attach policy
        print(f"Creating and attaching policy: {policy_name}")
        iam.put_role_policy(
            RoleName=role_name,
            PolicyName=policy_name,
            PolicyDocument=json.dumps(permissions_policy)
        )
        
        # Get role ARN
        role_response = iam.get_role(RoleName=role_name)
        role_arn = role_response['Role']['Arn']
        
        print(f"Successfully created VPC Flow Logs role: {role_arn}")
        return role_arn
        
    except Exception as e:
        print(f"Error creating role: {str(e)}")
        return None

if __name__ == "__main__":
    create_vpc_flow_logs_role()
