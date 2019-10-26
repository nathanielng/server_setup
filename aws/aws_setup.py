#!/usr/bin/env python

import argparse
import boto3
import csv
import os
import re
import sys
import time


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


# ----- Key Pair Management -----
def get_key_pairs():
    """
    Get EC2 Key Pair Names
    """
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    keypairs = client.describe_key_pairs()
    keypairs = [ kepair for kepair in keypairs['KeyPairs']]
    keynames = [ kepair['KeyName'] for kepair in keypairs]
    return keynames


def create_key_pair(key_name, verbose=False):
    """
    Creates a Key Pair
    """
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    response = client.create_key_pair(
        KeyName=key_name
    )
    with open(key_name, 'w') as f:
        f.write(response['KeyMaterial'])
    os.chmod(key_name, 0o600)
    if verbose is True:
        print(f'Created key pair: {key_name}')
        print(f'response = {response}')
    return response


def delete_key_pair(key_name, verbose=False):
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    response = client.delete_key_pair(
        KeyName=key_name
    )
    if verbose is True:
        print(f'Deleted key pair: {key_name}')
        print(f'response = {response}')
    return response


# ----- Launch Instance -----
def launch_instance(key_name, security_group):
    """
    Launches an EC2 instance
    """
    # Create Key Pair if it does not already exist
    key_names = get_key_pairs()
    if key_name not in key_names:
        create_key_pair(key_name, True)
        print()
    elif not os.path.isfile(key_name):
        delete_key_pair(key_name, True)
        print()
        create_key_pair(key_name, True)
        print()

    # Create Security Group if it does not already exist
    names = get_security_group_names()
    if security_group not in names:
        group_id = create_security_group(security_group)

    # Create EC2 Instance
    ec2 = boto3.client('ec2', AVAILABILITY_ZONE)
    response = ec2.run_instances(
        ImageId=AMI_IMAGE_ID,
        InstanceType=AMI_INSTANCE_TYPE,
        KeyName=key_name,
        MinCount=1,
        MaxCount=1,
        InstanceInitiatedShutdownBehavior='terminate',
        SecurityGroups=[
            security_group
        ],
    )
    instance = response['Instances'][0]
    instance_id = instance['InstanceId']
    print(f"Launched EC2 Instance with: ID={instance_id}")
    print("Terminate this instance with the script: terminate_ec2.sh")
    with open("terminate_ec2.sh", "w") as f:
        f.write(f"python {sys.argv[0]} --terminate_id {instance_id}")

    print("Waiting for public dns", end='')
    while True:
        instance_info = describe_instances([instance_id])
        public_dns = instance_info['Reservations'][0]['Instances'][0]['PublicDnsName']
        if public_dns != '':
            print(f"\nPublic DNS: {public_dns}")
            break
        print('.', end='')
        sys.stdout.flush()
        time.sleep(1)

    ssh_command = f'ssh -i {key_name} ec2-user@{public_dns}'
    with open('ssh_to_ec2.sh', 'w') as f:
        f.write(ssh_command)

    print('Access the EC2 instance with ssh_to_ec2.sh, or run following command directly:')
    print(ssh_command)
    return response


def describe_instances(instance_ids=None):
    client = boto3.client('ec2', AVAILABILITY_ZONE)
    if instance_ids is None:
        return client.describe_instances()
    else:
        return client.describe_instances(
            InstanceIds=instance_ids
        )


def stop_instance(ids):
    ec2 = boto3.resource('ec2')
    response = ec2.instances.filter(InstanceIds=ids).stop()
    return response


def terminate_instance(ids):
    ec2 = boto3.resource('ec2')
    response = ec2.instances.filter(InstanceIds=ids).terminate()
    return response


# ----- Security Group Management
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


# ----- S3 Buckets -----
def get_buckets():
    s3 = boto3.resource('s3')
    return [ bucket in s3.buckets.all() ]


def list_buckets():
    for bucket in get_buckets():
        print(bucket.name)


# ----- Main Program -----
def main(args):
    if args.launch_instance is True:
        response = launch_instance(KEY_PAIR_NAME, SECURITY_GROUP)
    elif args.instances is True:
        response = describe_instances()
        reservations = response['Reservations']
        print(' InstanceId         | Type     | State      | KeyName         | PublicDnsName ')
        print('====================|==========|============|=================|===============')
        for i, reservation in enumerate(reservations):
            instance = reservation['Instances'][0]
            state = instance['State']['Name']
            print(f"{instance['InstanceId']} | {instance['InstanceType']} | {state}", end='')
            print(' | {KeyName}'.format(**instance), end='')
            if 'PublicDnsName' in instance.keys():
                print(' | {PublicDnsName}'.format(**instance))
            else:
                print(' | - ')
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
    parser.add_argument('--instances', action='store_true',
        help='List AWS instances')
    parser.add_argument('--keypairs', action='store_true',
        help='List AWS keypairs')
    parser.add_argument('--security_groups', action='store_true',
        help='List AWS security groups')
    parser.add_argument('--terminate_id',
        help='Specify an instance id to terminate')
    parser.add_argument('--git_user')
    parser.add_argument('--git_email')
    parser.add_argument('--git_editor')
    args = parser.parse_args()
    main(args)

