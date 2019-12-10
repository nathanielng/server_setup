# Sample Output

## 1. Create Security Group

### Input

```python
response = client.create_security_group(
        GroupName=group_name,
        Description=description
    )
```

### Output

```python
{'GroupId': 'sg-0018e5dd0c2eb3021', 'ResponseMetadata': {'RequestId': 'e11bf2dc-b0ff-4a73-9c47-244c83a768ba', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'content-length': '283', 'date': 'Mon, 16 Sep 2019 23:20:26 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
```

## 2. Run Instance

### Input

```python
response = ec2.run_instances(
        ImageId=AMI_IMAGE_ID,
        InstanceType=AMI_INSTANCE_TYPE,
        KeyName=key_name,
        MinCount=1,
        MaxCount=1,
        SecurityGroups=[
            security_group
        ],
    )
instance = response['Instances'][0]
```

### Output

```python
>>> import datetime
>>> from dateutil.tz import tzutc
>>> instance
{'AmiLaunchIndex': 0, 'ImageId': 'ami-048a01c78f7bae4aa', 'InstanceId': 'i-0bb613a2946512fbb', 'InstanceType': 't2.small', 'KeyName': 'ec2-ssh-keypair', 'LaunchTime': datetime.datetime(2019, 9, 16, 23, 20, 28, tzinfo=tzutc()), 'Monitoring': {'State': 'disabled'}, 'Placement': {'AvailabilityZone': 'ap-southeast-1b', 'GroupName': '', 'Tenancy': 'default'}, 'PrivateDnsName': 'ip-172-31-6-252.ap-southeast-1.compute.internal', 'PrivateIpAddress': '172.31.6.252', 'ProductCodes': [], 'PublicDnsName': '', 'State': {'Code': 0, 'Name': 'pending'}, 'StateTransitionReason': '', 'SubnetId': 'subnet-641b7f03', 'VpcId': 'vpc-51bd6c36', 'Architecture': 'x86_64', 'BlockDeviceMappings': [], 'ClientToken': '', 'EbsOptimized': False, 'Hypervisor': 'xen', 'NetworkInterfaces': [{'Attachment': {'AttachTime': datetime.datetime(2019, 9, 16, 23, 20, 28, tzinfo=tzutc()), 'AttachmentId': 'eni-attach-07d56ee74451b2a8e', 'DeleteOnTermination': True, 'DeviceIndex': 0, 'Status': 'attaching'}, 'Description': '', 'Groups': [{'GroupName': 'EC2_Security_SSH_Jupyter', 'GroupId': 'sg-0018e5dd0c2eb3021'}], 'Ipv6Addresses': [], 'MacAddress': '02:a2:e6:ab:ce:90', 'NetworkInterfaceId': 'eni-065b61f0bda60adf2', 'OwnerId': '856952634940', 'PrivateDnsName': 'ip-172-31-6-252.ap-southeast-1.compute.internal', 'PrivateIpAddress': '172.31.6.252', 'PrivateIpAddresses': [{'Primary': True, 'PrivateDnsName': 'ip-172-31-6-252.ap-southeast-1.compute.internal', 'PrivateIpAddress': '172.31.6.252'}], 'SourceDestCheck': True, 'Status': 'in-use', 'SubnetId': 'subnet-641b7f03', 'VpcId': 'vpc-51bd6c36'}], 'RootDeviceName': '/dev/xvda', 'RootDeviceType': 'ebs', 'SecurityGroups': [{'GroupName': 'EC2_Security_SSH_Jupyter', 'GroupId': 'sg-0018e5dd0c2eb3021'}], 'SourceDestCheck': True, 'StateReason': {'Code': 'pending', 'Message': 'pending'}, 'VirtualizationType': 'hvm'}
```

