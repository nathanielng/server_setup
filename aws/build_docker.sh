#!/bin/bash

# 1. Builds Docker Image in a Cloud9 / Amazon Linux 2 Instance
# 2. Pushes image to Amazon ECR
# 3. Defaults to account and region of the Cloud9 instance
# 4. Requires about 8 GB memory (t3.large instance size) and at least about 25 GB EBS Storage
# 5. Customize by modifiying environment.yaml and/or Dockerfile heredoc.

# Code adapted from:
# - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
# - https://ecsworkshop.com/
# - https://raw.githubusercontent.com/aws/amazon-braket-examples/main/environment.yml

# (0) Specify inputs, such as your region, ECR repository name, and braket image name
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
ECR_REPONAME="braketcontainers"
IMAGE_NAME="braketimage"


# (1) Create Conda Environment File
#     The following is based on:
#     https://raw.githubusercontent.com/aws/amazon-braket-examples/main/environment.yml
cat > environment.yml << EOF
name: Braket
channels:
  - psi4
  - conda-forge
  - defaults
dependencies:
  - awscli=1.20.52
  - boto3=1.18.52
  - botocore=1.21.52
  - conda-pack=0.6.0
  - colorama=0.4.3
  - decorator=4.4.0
  - idna=2.10
  - ipykernel=5.3.4
  - jinja2=2.11.3
  - markupsafe=1.1.1
  - matplotlib=3.2.2
  - nbconvert=6.0.7
  - networkx=2.4
  - numpy=1.19.2
  - openbabel=3.1.1
  - pandas=1.1.4
  - pip
  - protobuf=3.12.4
  - psi4=1.3.2
  - python=3.7
  - rsa=4.4.1
  - scipy=1.5.2
  - six=1.15.0
  - typing_extensions=3.7.4.3
  - pip:
      - amazon-braket-default-simulator
      - amazon-braket-ocean-plugin
      - amazon-braket-pennylane-plugin
      - amazon-braket-schemas
      - amazon-braket-sdk
      - dask==2.30.0
      - dwave-ocean-sdk==3.3.0
      - jax==0.2.21
      - keras==2.6.0
      - openfermion==1.0.0
      - pennylane==0.18
      - pennylane-qchem==0.17
      - s3transfer==0.5.0
      - tensorflow==2.6.0
      - torch==1.8.1
EOF


# (2) Create Docker File (based on environment.yml)
cat > Dockerfile << EOF
FROM continuumio/miniconda3

ADD environment.yml .
RUN conda env create -f environment.yml
ENV PATH /opt/conda/envs/\$(head -1 /src/mro_env.yml | cut -d' ' -f2)/bin:\$PATH
RUN conda init bash
RUN echo "conda activate \$(head -1 environment.yml | cut -d' ' -f2)" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]
EOF


# (3) Resize Cloud9 EBS Volume (you could need anywhere from 25 to 100 GB
#     of EBS storage to build the Docker image)
bash cloud9_resize.sh 50
sudo growpart /dev/xvda 1
sudo xfs_growfs $(df -h |awk '/^\/dev/{print $1}')


# (4) Install & Start Docker
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user


# (5) Create repository if it does not already exist
aws ecr describe-repositories --region ${REGION} --repository-names ${ECR_REPONAME} || aws ecr create-repository --repository-name ${ECR_REPONAME} --region ${REGION}


# (6) Login
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}


# (7) Build the Container Image
docker build . -t ${IMAGE_NAME} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}


# (8) Push the Image to ECR
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPONAME}:${IMAGE_NAME}
