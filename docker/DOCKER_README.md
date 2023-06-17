# Docker Readme

## 1. Introduction

### 1.1 Docker Installation

- **Instructions**: https://docs.docker.com/install/


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
