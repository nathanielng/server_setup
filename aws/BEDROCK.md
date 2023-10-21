# Amazon Bedrock

- Bedrock [Base model IDs](https://docs.aws.amazon.com/bedrock/latest/userguide/model-ids-arns.html)

## 1. Bedrock Setup

### 1.1 Bedrock Access

#### 1.1.1 Role Permissions

Use an existing role with the following permissions, or create a new role

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BedrockFullAccess",
            "Effect": "Allow",
            "Action": ["bedrock:*"],
            "Resource": "*"
        }
    ]
}
```


#### 1.1.2 Enable Bedrock Models in the Console

Browse to the Bedrock Model Access Page in [us-east-1](https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1#/modelaccess)
or [us-west-2](https://us-west-2.console.aws.amazon.com/bedrock/home?region=us-west-2#/modelaccess).
Click the **Edit** button, and check all the models that you wish to enable.
Then click the **Save Changes** button.

**Ref**: Bedrock [Model access documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)



### 1.2 Install AWS CLI

Instructions: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
AWS version should be ~2.13.24 or higher

Test the AWS CLI with the following:

```bash
aws --version
aws bedrock list-foundation-models --region us-east-1  # requires role permissions set in 1.1
```

#### 1.2.1 Mac

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```


#### 1.2.2 Ubuntu

```bash
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"  # for ARM
unzip awscliv2.zip
sudo ./aws/install --update
```



### 1.3 Install Python Environment + Boto3

Install Python Environment (Amazon Linux)

```bash
amazon-linux-extras | grep python  # Latest version should be 3.8 or higher
sudo amazon-linux-extras install python3.8

curl -LO https://bootstrap.pypa.io/get-pip.py
python3.8 get-pip.py
python3.8 -m pip install virtualenv
python3.8 -m virtualenv ~/.venv -p python3.8
source ~/.venv/bin/activate
pip install boto3 -U
```

Install Python Environment (General)

```bash
curl -LO https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
python3 -m pip install virtualenv
python3 -m virtualenv ~/.venv -p python3
source ~/.venv/bin/activate
pip install boto3 -U
```

Test the Python environment with the following. Boto3 version should be ~1.28.61 or higher.

```bash
python -c "import boto3; print(boto3.__version__)"
```

Run the following Bedrock Hello World Script

```python
import boto3

bedrock = boto3.client(service_name='bedrock', region_name='us-east-1')
print(bedrock.list_foundation_models())
```



## 2. Bedrock Models

### 2.1 AI21 Labs

#### 2.1.1 Jurassic-2 Ultra

```json
{
  "modelId": "ai21.j2-ultra-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": "{"prompt":"this is where you place your input text","maxTokens":200,"temperature":0,"topP":250,"stop_sequences":[],"countPenalty":{"scale":0},"presencePenalty":{"scale":0},"frequencyPenalty":{"scale":0}}"  
}
```


#### 2.1.2 Jurassic-2 Mid

```json
{
  "modelId": "ai21.j2-mid-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": "{"prompt":"this is where you place your input text","maxTokens":200,"temperature":0,"topP":250,"stop_sequences":[],"countPenalty":{"scale":0},"presencePenalty":{"scale":0},"frequencyPenalty":{"scale":0}}"  
}
```



### 2.2 Amazon

#### 2.2.1 Titan Embeddings G1 - Text

```json
{
  "modelId": "amazon.titan-embed-text-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
    "inputText": "this is where you place your input text"
   } 
}
```


#### 2.2.2 Titan Text G1 - Express (Preview)

```json
{
  "modelId": "amazon.titan-text-express-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
   "inputText": "this is where you place your input text",
   "textGenerationConfig": {
      "maxTokenCount": 8192,
      "stopSequences": [],
      "temperature":0,
      "topP":1
     }
   } 
}
```



### 2.3. Anthropic Claude

Anthropic [Human: and Assistant: formatting guide](https://docs.anthropic.com/claude/docs/human-and-assistant-formatting)

#### 2.3.1 Claude v1.3

```json
{
  "modelId": "anthropic.claude-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
    "prompt": "\n\nHuman: Hello world\n\nAssistant:",
    "max_tokens_to_sample": 300,
    "temperature": 0.5,
    "top_k": 250,
    "top_p": 1,
    "stop_sequences": [
      "\\n\\nHuman:"
    ],
    "anthropic_version": "bedrock-2023-05-31"
  }
}
```


#### 2.3.2 Claude Instant v1.2

```json
{
  "modelId": "anthropic.claude-instant-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
    "prompt": "\n\nHuman: Hello world\n\nAssistant:",
    "max_tokens_to_sample": 300,
    "temperature": 0.5,
    "top_k": 250,
    "top_p": 1,
    "stop_sequences": [
      "\\n\\nHuman:"
    ],
    "anthropic_version": "bedrock-2023-05-31"
  }
}
```


#### 2.3.3 Claude v2

```json
{
  "modelId": "anthropic.claude-v2",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
    "prompt": "\n\nHuman: Hello world\n\nAssistant:",
    "max_tokens_to_sample": 300,
    "temperature": 0.5,
    "top_k": 250,
    "top_p": 1,
    "stop_sequences": [
      "\\n\\nHuman:"
    ],
    "anthropic_version": "bedrock-2023-05-31"
  }
}
```



### 2.4 Cohere

#### 2.4.1 Command

```json
{
  "modelId": "cohere.command-text-v14",
  "contentType": "application/json",
  "accept": "*/*",
  "body": {
    "prompt": "Write a LinkedIn post about starting a career in tech:",
    "max_tokens": 100,
    "temperature": 0.8,
    "return_likelihood": "GENERATION"   
  } 
}
```



### 2.5 Stability

#### 2.5.1 Stable Diffusion XL

```json
{
  "modelId": "stability.stable-diffusion-xl-v0",
  "contentType": "application/json",
  "accept": "*/*",
  "body": "{"text_prompts": [{"text":"this is where you place your input text"}],"cfg_scale":10,"seed":0,"steps":50}"  
}
```
