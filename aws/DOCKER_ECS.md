# DOCKER ECS

## 1. Setup Environment Variables

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION=$(aws configure get region)
ECR_REPONAME="mydockerimage-repo"
IMAGE_NAME="mydockerimage"
```

## 2. Elastic Container Registry (ECR)

Create repository if it does not exist.
Login.
Build the image.
Push the image to ECR.

```bash
aws ecr describe-repositories --region ${REGION} --repository-names ${ECR_REPONAME} || aws ecr create-repository --repository-name ${ECR_REPONAME} --region ${REGION}
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}
docker build . -t ${IMAGE_NAME} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}
```
