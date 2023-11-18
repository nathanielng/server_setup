#!/usr/bin/env python

import boto3
import glob
import html2text
import json
import os
import re
import requests
import tiktoken
import time

from langchain.document_loaders import DirectoryLoader, UnstructuredMarkdownLoader
from langchain.embeddings import BedrockEmbeddings
from langchain.llms.bedrock import Bedrock
from langchain.text_splitter import CharacterTextSplitter, RecursiveCharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.indexes import VectorstoreIndexCreator
from langchain.indexes.vectorstore import VectorStoreIndexWrapper


# ----- Bedrock -----
bedrock_runtime = boto3.client(
    service_name = 'bedrock-runtime',
    region_name = 'us-west-2'
)

llm = Bedrock(
    model_id="anthropic.claude-instant-v1",
    client=bedrock_runtime,
    model_kwargs={
        'max_tokens_to_sample':200
    }
)

bedrock_embeddings = BedrockEmbeddings(
    model_id="amazon.titan-embed-text-v1",
    client=bedrock_runtime
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

    response = bedrock_runtime.invoke_model(
        modelId = "anthropic.claude-instant-v1",
        contentType = "application/json",
        accept = "*/*",
        body = json.dumps(body)
    )
    response_body = json.loads(response.get('body').read())
    return response_body['completion']



# ----- Format Converters -----
def convert_html_to_markdown(folder):
    files = glob.glob(f'{folder}/*.html')
    for file in files:
        basename, _ = os.path.splitext(file)
        with open(file, 'r') as f:
            html_text = f.read()
            # markdown_text = markdownify.markdownify(html_text)
            markdown_text = html2text.html2text(html_text)
            markdown_text = re.sub('^Skip to content\n', '', markdown_text)

        with open(f'{basename}.md', 'w') as f:
            f.write(markdown_text)
        
        print(f'Created: {basename}.md')



# ----- Count Tokens -----
def count_tokens(folder):
    files = glob.glob(f'{folder}/*.md')

    for file in files:
        with open(file, 'r') as f:
            txt = f.read()

        encoding = tiktoken.get_encoding("cl100k_base")
        encoded_markdown_text = encoding.encode(txt)
        n = len(encoded_markdown_text)
        print(f'{file}, {n}')



# ----- Retrieval Augmented Generation (RAG) -----
def document_loader(folder):
    text_loader_kwargs={'autodetect_encoding': True}

    loader = DirectoryLoader(
        './websites/',
        glob='*.md',
        loader_cls=UnstructuredMarkdownLoader,
        show_progress=True,
        use_multithreading=True,
        loader_kwargs=text_loader_kwargs
    )
    docs = loader.load()
    return RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200
    ).split_documents(docs)


def create_vector_store(docs, embeddings, vector_store_name="faiss_index"):
    # Create vector store
    print('Creating vector store')
    start_time = time.perf_counter()
    vector_store = FAISS.from_documents(docs, embeddings)
    end_time = time.perf_counter()
    print(f'Vector store created (time elapsed: {end_time - start_time:.2f} seconds)')

    # Save vector store
    vector_store.save_local(vector_store_name)
    return vector_store


def query_vector_store(vector_store, query):
    top_docs = vector_store.similarity_search(query)
    context = []
    for i, doc in enumerate(top_docs[:3]):
        source = doc.metadata['source']
        print(f'----- Document {i:02d} ({source}) -----')
        print(doc.page_content)
        context.append(doc.page_content)
    return '\n\n.join(context)'


def query_rag(vector_store, query):
    context = query_vector_store(vector_store, query=query)
    prompt = f"""Answer the following question, based on the context provided: <context>{context}</context>
    If you do not know the answer, say that you do not know.
    {query}"""
    completion = invoke_claude_instant(prompt)
    return completion


if __name__ == '__main__':
    vector_store_folder = "faiss_index"
    if os.path.isdir(vector_store_folder):
        vector_store = FAISS.load_local("faiss_index", bedrock_embeddings)
    else:
        docs = document_loader('./data/')
        vector_store = create_vector_store(docs, embeddings=bedrock_embeddings)

    query = "Can you give me a summary of the context provided?"
    answer = query_rag(vector_store, query)
    print(f'===== Question: {query} =====')
    print(answer)
    print('==========')
