# README

## 1. Amazon EC2

### 1.1 Launching a New Instance

```bash
./aws_launch.sh
```

Two files will be created upon launch: `ssh_to_ec2.sh` and
`terminate_ec2.sh`


### 1.2 SSH to the newly created instance

```bash
./ssh_to_ec2.sh
```

### 1.3 Terminating the newly created instance

```bash
./terminate_ec2.sh
```

## 2. Cloudfront

### 2.1 [RSA Key Pair Creation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#private-content-creating-cloudfront-key-pairs)

```bash
openssl genrsa -out private_key.pem 2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

