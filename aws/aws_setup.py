#!/usr/bin/env python

import argparse
import boto3
import csv
import os
import re


def load_settings(filename="aws-settings.csv", skip_rows=1):
    with open(filename) as f:
        table = csv.reader(f, delimiter=',')
        table = list(table)
    d = {}
    for i, row in enumerate(table):
        if i < skip_rows:
            continue
        d[row[0]] = row[1]
    return d


def get_key_pairs():
    """
    Get EC2 Key Pair Names
    """
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    keypairs = client.describe_key_pairs()
    keypairs = [ kepair for kepair in keypairs['KeyPairs']]
    keynames = [ kepair['KeyName'] for kepair in keypairs]
    return keynames


def create_key_pair(key_name):
    """
    Creates a Key Pair
    """
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    response = client.create_key_pair(
        KeyName=key_name
    )
    with open(key_name, 'w') as f:
        f.write(response['KeyMaterial'])
    return response


def launch_instance(key_name, security_group):
    """
    Launches an EC2 instance
    """
    # Create Key Pair if it does not already exist
    key_names = get_key_pairs()
    if key_name not in key_names:
        response = create_key_pair(key_name)

    # Create Security Group if it does not already exist
    names = get_security_group_names()
    if security_group not in names:
        group_id = create_security_group(security_group)

    # Create EC2 Instance
    ec2 = boto3.resource('ec2')
    response = ec2.create_instances(
        ImageId=AMI_IMAGE_ID,
        InstanceType=AMI_INSTANCE_TYPE,
        KeyName=key_name,
        MinCount=1, MaxCount=1,
        SecurityGroups=[
            security_group
        ],
    )
    return response


def terminate_instance(ids):
    ec2 = boto3.resource('ec2')
    response = ec2.instances.filter(InstanceIds=ids).terminate()
    return response


def get_security_groups():
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    response = client.describe_security_groups()
    return response


def get_security_group_names(response=None):
    if response is None:
        response = get_security_groups()
    groups = response['SecurityGroups']
    return [ group['GroupName'] for group in groups ]


def create_security_group(group_name):
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    response = client.create_security_group(
        GroupName=group_name,
        Description=re.sub("_", " ", group_name)
    )
    print(response)
    group_id = response['GroupId']
    response = client.authorize_security_group_ingress(
        GroupId=group_id,
        IpPermissions=[
        {
            'IpProtocol': 'tcp',
            'FromPort': 22,
            'ToPort': 22,
            'IpRanges': [
                {'CidrIp': '0.0.0.0/0'}
            ]
        },
        {
            'IpProtocol': 'tcp',
            'FromPort': 8888,
            'ToPort': 8888,
            'IpRanges': [
                {'CidrIp': '0.0.0.0/0'}
            ]
        }
        ]
    )
    return group_id

    
def main(args):
    if args.launch_instance is True:
        response = launch_instance(KEY_PAIR_NAME, SECURITY_GROUP)
        print(response)
    elif args.keypairs is True:
        keynames = get_key_pairs()
        print("-----AWS IAM Key Pairs-----")
        for keyname in keynames:
            print(keyname)
    elif args.security_groups is True:
        print("-----AWS Security Groups-----")
        names = get_security_group_names()
        print('\n'.join(names))
    elif args.terminate_id is not None:
        response = terminate_instance([args.terminate_id])
        print(response)


AWS_SETTINGS = load_settings()
AMI_IMAGE_ID = AWS_SETTINGS['AMI_IMAGE_ID']
AMI_INSTANCE_TYPE = AWS_SETTINGS['AMI_INSTANCE_TYPE']
AVAILABILITY_ZONE = AWS_SETTINGS['AVAILABILITY_ZONE']
KEY_PAIR_NAME = AWS_SETTINGS['KEY_PAIR_NAME']
SECURITY_GROUP = AWS_SETTINGS['SECURITY_GROUP']


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--launch_instance', action='store_true',
        help='Launch an AWS EC2 Instance')
    parser.add_argument('--keypairs', action='store_true',
        help='List AWS keypairs')
    parser.add_argument('--security_groups', action='store_true',
        help='List AWS security groups')
    parser.add_argument('--terminate_id',
        help='Specify an instance id to terminate')
    args = parser.parse_args()
    main(args)
