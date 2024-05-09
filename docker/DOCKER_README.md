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

Ubuntu Docker Installation (from https://github.com/aws-samples/amazon-sagemaker-immersion-day/blob/master/bring-your-own-model/bring-custom-container.ipynb and https://docs.openwebui.com/getting-started/)

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## Currently only Docker version 20.10.X is supported in Studio: see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html
# pick the latest patch from:
# apt-cache madison docker-ce | awk '{ print $3 }' | grep -i 20.10
# VERSION_STRING=5:20.10.24~3-0~ubuntu-jammy
# sudo apt-get install docker-ce-cli=$VERSION_STRING docker-compose-plugin -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# validate the Docker Client is able to access Docker Server at [unix:///docker/proxy.sock]
docker version
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
