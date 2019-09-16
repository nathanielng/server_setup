#!/usr/bin/env python

import argparse
import boto3
import csv
import os


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


def launch_instance(keypair):
    """
    Launches a spot instance
    """
    ec2 = boto3.resource('ec2')
    ec2.create_instances(
        ImageId=AMI_IMAGE_ID,
        InstanceType=AMI_INSTANCE_TYPE,
        KeyName=keypair,
        MinCount=1, MaxCount=1)

    
def main(args):
    if args.launch_spot_instance is True:
        keynames = get_key_pairs()
        launch_spot_instance(keynames[0])
    elif args.keypairs is True:
        keynames = get_key_pairs()
        print("-----AWS IAM Key Pairs-----")
        for keyname in keynames:
            print(keyname)


AWS_SETTINGS = load_settings()
AMI_IMAGE_ID = AWS_SETTINGS['AMI_IMAGE_ID']
AMI_INSTANCE_TYPE = AWS_SETTINGS['AMI_INSTANCE_TYPE']
AVAILABILITY_ZONE = AWS_SETTINGS['AVAILABILITY_ZONE']


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--launch_spot_instance', action='store_true',
        help='Launch an AWS Spot Instance')
    parser.add_argument('--keypairs', action='store_true',
        help='List AWS Keypairs')
    args = parser.parse_args()
    main(args)
