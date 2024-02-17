# Docker Readme

## 1. Introduction

### 1.1 Docker Installation

- **Instructions**: https://docs.docker.com/install/

Amazon Linux 2 Docker Installation

```bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo reboot
```

### 1.2 Docker Post Installation Steps

- **Instructions**: https://docs.docker.com/install/linux/linux-postinstall/

#### 1.2.1 User Setup

Create the `docker` group and add `userid` to it

```bash
sudo groupadd docker
sudo adduser userid
sudo passwd userid
sudo usermod -aG docker userid
```

## 2. Dockerfiles

- [FIPS 140-2 Compliant Docker Images](https://github.com/arhea/docker-fips-library)
- [Official Docker Samples](https://github.com/dockersamples)
- [Python Official Docker Image](https://github.com/docker-library/python)
- [SageMaker Studio Custom Image Samples](https://github.com/aws-samples/sagemaker-studio-custom-image-samples)

## 3. Amazon Elastic Container Repository (ECR)

```bash
ACCOUNT_ID="..."
ECR_REPONAME="myecrrepo"
IMAGE_NAME="..."
REGION="ap-southeast-1"
aws ecr create-repository --repository-name ${REPO_NAME}
```

```bash
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}
docker build . -t ${IMAGE_NAME} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}
```
