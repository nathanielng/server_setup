#!/usr/bin/env python

import boto3
import json
import sys


bedrock_runtime = boto3.client(
    service_name='bedrock-runtime', 
    region_name='us-west-2'
)

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

    try:
        response = bedrock_runtime.invoke_model(
            modelId = "anthropic.claude-instant-v1",
            contentType = "application/json",
            accept = "*/*",
            body = json.dumps(body)
        )
        response_body = json.loads(response.get('body').read())
        return response_body['completion']
    except Exception as e:
        return e

def lambda_handler(event, context):
    prompt = event.get("body").get("input").get("question")
    completion = invoke_claude_instant(prompt)
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({ "Answer": completion }),
        'boto3': f"{boto3.__version__}",
        'python': f"{sys.version}"
    }
