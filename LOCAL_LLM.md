# Local LLM Setup

## 1. Launch EC2 Instance

Launch EC2 instance (e.g. c6a.2xlarge) as a spot instance

```bash
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEYPAIR --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET --instance-market-options MarketType=spot,SpotOptions={SpotInstanceType=one-time} --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=c6a4xl_spot}]'
```

```bash
cat >> ~/.bashrc << EOF
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export SUDO_PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
HISTSIZE=20000
HISTFILESIZE=20000
TERM='xterm-256color'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF
source ~/.bashrc
```

## 2. Install Software Stack

On the EC2 instance

```bash
sudo yum -y groupinstall "Development Tools"
sudo yum -y install git
git clone https://github.com/GoogleCloudPlatform/localllm.git
cd localllm/

curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip install virtualenv
virtualenv pyenv -p python3
source pyenv/bin/activate
pip install -U pip
pip install openai
pip install ./llm-tool/.
llm pull TheBloke/Mistral-7B-Instruct-v0.2-GGUF
llm run TheBloke/Mistral-7B-Instruct-v0.2-GGUF 8000
llm ps
```
