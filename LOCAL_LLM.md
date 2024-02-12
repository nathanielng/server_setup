# Local LLM Setup

## 1. Launch EC2 Instance

Launch EC2 instance (e.g. c6a.xlarge) On-Demand or Spot.


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
