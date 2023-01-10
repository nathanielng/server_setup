#!/bin/bash

echo "Checking all regions for EC2 instances and EBS volumes to terminate"
REGIONS=$(aws ec2 describe-regions --region us-east-1 --query Regions[*].[RegionName] --output text)
for region in $REGIONS; do
    echo -n "Region: $region "
    INSTANCES=$(aws ec2 describe-instances --region $region \
        --query Reservations[*].Instances[*].InstanceId \
        --output text)
    if [[ "$INSTANCES" = "" ]]; then
        echo "(no instances)"
        continue
    else
        echo
    fi
    for instance in $INSTANCES; do
        read -p "Terminate instance $instance (corresponding EBS volume will be deleted) (y/N)? " yn
        case $yn in
            [Yy] ) aws ec2 terminate-instances --region $region --instance-ids $instance
        esac
    done
done
