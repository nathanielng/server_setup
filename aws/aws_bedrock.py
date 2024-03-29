#!/usr/bin/env python

import argparse
import base64
import boto3
import io
import json
import os

from PIL import Image


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



# ----- AI 21 -----
def invoke_jurrasic2_mid(prompt, **kwargs):
    body = {
        "prompt": prompt,
        "maxTokens": 200,
        "temperature": 0,
        "topP": 1.0,
        # "stop_sequences": [],
        "countPenalty": {
            "scale": 0
        },
        "presencePenalty": {
            "scale": 0
        },
        "frequencyPenalty": {
            "scale": 0
        }
    }

    for parameter in ['maxTokens', 'temperature', 'topP', 'countPenalty', 'presencePenalty', 'frequencyPenalty']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    try:
        response = bedrock_runtime.invoke_model(
            body=json.dumps(body),
            modelId='ai21.j2-mid-v1',
            accept='*/*',
            contentType='application/json'
        )
        response_body = json.loads(response.get('body').read())
        completions = response_body.get('completions')[0]
        # finishReason = completions.get('finishReason')
        return completions.get('data').get('text')
    except Exception as e:
        print(e)
        return e


def invoke_jurrasic2_ultra(prompt, **kwargs):
    body = {
        "prompt": prompt,
        "maxTokens": 200,
        "temperature": 0,
        "topP": 1.0,
        # "stop_sequences": [],
        "countPenalty": {
            "scale": 0
        },
        "presencePenalty": {
            "scale": 0
        },
        "frequencyPenalty": {
            "scale": 0
        }
    }
    for parameter in ['maxTokens', 'temperature', 'topP', 'countPenalty', 'presencePenalty', 'frequencyPenalty']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    try:
        response = bedrock_runtime.invoke_model(
            body=json.dumps(body),
            modelId='ai21.j2-ultra-v1',
            accept='*/*',
            contentType='application/json'
        )
        response_body = json.loads(response.get('body').read())
        completions = response_body.get('completions')[0]
        # finishReason = completions.get('finishReason')
        return completions.get('data').get('text')
    except Exception as e:
        print(e)
        return e



# ----- Amazon Titan -----
def invoke_titan_text_express(prompt, **kwargs):
    body = {
        "inputText": prompt,
        "textGenerationConfig": {
            "maxTokenCount": 8192,
            "stopSequences": [],
            "temperature":0,
            "topP":1
         }
    }
    for parameter in ['maxTokenCount', 'stopSequences', 'temperature', 'topP']:
        if parameter in kwargs:
            body['textGenerationConfig'][parameter] = kwargs[parameter]

    try:
        response = bedrock_runtime.invoke_model(
            body=json.dumps(body),
            modelId='amazon.titan-text-express-v1',
            accept='*/*',
            contentType='application/json'
        )
        response_body = json.loads(response.get('body').read())
        return response_body.get('results')[0].get('outputText')
    except Exception as e:
        print(e)
        return e


def invoke_titan_text_embeddings(prompt, **kwargs):
    body = {
        "inputText": prompt
    }

    try:
        response = bedrock_runtime.invoke_model(
            body=json.dumps(body),
            modelId='amazon.titan-embed-text-v1',
            accept='*/*',
            contentType='application/json'
        )
        response_body = json.loads(response.get('body').read())
        embedding = response_body.get('embedding')
        token_count = response_body.get('inputTextTokenCount')
        return embedding, token_count
    except Exception as e:
        print(e)
        return e



# ----- Anthropic Claude -----
def invoke_claude_instant(prompt, **kwargs):
    body = {
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
        "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    }
    for parameter in ['max_tokens_to_sample', 'temperature', 'top_k', 'top_p']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-instant-v1",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']


def invoke_claude_v1(prompt, **kwargs):
    body = {
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
            "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    }
    for parameter in ['max_tokens_to_sample', 'temperature', 'top_k', 'top_p']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-v1",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']


def invoke_claude_v2(prompt, **kwargs):
    body = {
        "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.5,
        "top_k": 250,
        "top_p": 1,
        "stop_sequences": [
        "\\n\\nHuman:"
        ],
        "anthropic_version": "bedrock-2023-05-31"
    }
    for parameter in ['max_tokens_to_sample', 'temperature', 'top_k', 'top_p']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-v2",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']



# ----- Cohere -----
def invoke_cohere(prompt, **kwargs):
    body = {
        "prompt": prompt,
        "max_tokens": 100,
        "temperature": 0.8
        # "return_likelihood": "GENERATION"   
    }
    for parameter in ['max_tokens', 'temperature']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    response = bedrock_runtime.invoke_model(
        modelId = "cohere.command-text-v14",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    return response_body['generations'][0]['text']



# ----- Stablity AI -----
def invoke_stable_diffusion_xl(prompt, **kwargs):
    text_prompts = [{"text": prompt, "weight": 1.0}]
    if 'negative_prompts' in kwargs:
        negative_prompts = kwargs['negative_prompts'].split(',')
        text_prompts = text_prompts + [{"text": negprompt, "weight": -1.0} for negprompt in negative_prompts]

    body = {
        "text_prompts": text_prompts,
        "cfg_scale": 10,
        "seed": 0,
        "steps": 50
    }

    for parameter in ['cfg_scale', 'seed', 'steps', 'style_preset']:
        if parameter in kwargs:
            body[parameter] = kwargs[parameter]

    response = bedrock_runtime.invoke_model(
        modelId = "stability.stable-diffusion-xl-v0",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    artifacts = response_body.get('artifacts')
    base_64_img_str = artifacts[0].get('base64')
    img = Image.open(io.BytesIO(base64.decodebytes(bytes(base_64_img_str, "utf-8"))))
    
    if 'img_file' in kwargs:
        img.save(kwags['img_file'])
    
    return img



if __name__ == '__main__':
    list_models()
    prompt = 'What is science?'

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
