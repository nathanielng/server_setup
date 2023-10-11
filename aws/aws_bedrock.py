#!/usr/bin/env python

import argparse
import boto3
import json
import os


REGION = 'us-west-2'
print(f'Boto3 version: {boto3.__version__}')
print(f'Region: {REGION}')


bedrock = boto3.client(
    service_name='bedrock',
    region_name=REGION
)

bedrock_runtime = boto3.client(
    service_name='bedrock-runtime',
    region_name=REGION
)



def list_models():
    response = bedrock.list_foundation_models()
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise Exception('Failed to list models')
    models = response['modelSummaries']
    for model in models:
        model_id = model['modelId']
        model_name = model['modelName']
        print(f'{model_id}: {model_name}')
    return model



# ----- Amazon Titan -----
def invoke_titan_tg1(prompt):
    bedrock_runtime = boto3.client(
        service_name = 'bedrock-runtime',
        region_name = 'us-west-2',
        endpoint_url = 'https://prod.us-west-2.frontend.bedrock.aws.dev'
    )

    body = json.dumps({
        "inputText": prompt
    })

    response = bedrock_runtime.invoke_model(
        body=body,
        modelId='amazon.titan-tg1-large',
        accept='application/json',
        contentType='application/json'
        )
    response_body = json.loads(response.get('body').read())
    return response_body.get('results')[0].get('outputText').strip()


def invoke_titan_text_express(prompt, modelId='amazon.titan-tg1-large'):
    body = json.dumps({
        "inputText": prompt
        })

    try:
        response = bedrock_runtime.invoke_model(
            body=body,
            modelId=modelId,
            accept='application/json',
            contentType='application/json'
            )
        response_body = json.loads(response.get('body').read())
        return response_body.get('results')[0].get('outputText')
    except Exception as e:
        # print(e)
        return e



# ----- Anthropic Claude -----
def invoke_claude_instant(prompt):
    body = json.dumps({
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
        "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    })

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-instant-v1",
        contentType = "application/json",
        accept = "*/*",
        body = body
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']


def invoke_claude_v1(prompt):
    body = json.dumps({
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
            "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    })

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-v1",
        contentType = "application/json",
        accept = "*/*",
        body = body
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']


def invoke_claude_v2(prompt):
    body = json.dumps({
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
        "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    })

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-v2",
        contentType = "application/json",
        accept = "*/*",
        body = body
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']



if __name__ == '__main__':
    list_models()
    prompt = 'What is science?'

    print('----- Titan TG1 -----')
    answer = invoke_titan_tg1(prompt)
    print(answer)

    print('----- Titan Text Express -----')
    answer = invoke_titan_text_express(prompt)
    print(answer) 

    print('----- Claude Instant -----')
    answer = invoke_claude_instant(prompt)
    print(answer)

    print('----- Claude v1 -----')
    answer = invoke_claude_v1(prompt)
    print(answer)

    print('----- Claude v2 -----')
    answer = invoke_claude_v2(prompt)
    print(answer)
