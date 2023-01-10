#!/bin/bash

read -p "Do you wish to delete all your S3 buckets in this account (y/N)? " yn
case $yn in
    [Yy] ) aws s3 ls | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{} --force
esac
