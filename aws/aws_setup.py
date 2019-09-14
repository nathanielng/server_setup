#!/usr/bin/env python

import argparse
import boto3
import csv
import os


AWS_SETTINGS = load_settings()


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


def launch_spot_instance(keypair):
    """
    Launches a spot instance
    """
    AMI_IMAGE_ID = AWS_SETTINGS['AMI_IMAGE_ID']
    AMI_INSTANCE_TYPE = AWS_SETTINGS['AMI_INSTANCE_TYPE']
    ec2 = boto3.resource('ec2')
    ec2.create_instances(
        ImageId=AMI_IMAGE_ID,
        InstanceType=AMI_INSTANCE_TYPE,
        KeyName=keypair,
        InstanceMarketOptions={
            'MarketType': 'spot',
            'SpotInstanceType': 'one-time',
            'InstanceInterruptionBehavior': 'stop'}
        MinCount=1, MaxCount=1)

    
def main(args):
    if args.launch_spot_instance is True:
        launch_spot_instance(args.keypair)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--launch_spot_instance', help='Launch an AWS Spot Instance')
    parser.add_argument('--keypair', help='AWS Keypair')
    args = parser.parse_args()
    main(args)
