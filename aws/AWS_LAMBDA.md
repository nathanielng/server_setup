# AWS Lambda

## 1. Pyenv Virtualenv

## 1. Creating a Lambda Layer

The following is based on the instructions [here](https://github.com/awsdocs/aws-lambda-developer-guide/tree/main/sample-apps/layer-python),
but has been adapted for pyenv

```bash
mkdir test/
pyenv local 3.12
pyenv which python

cat << EOF > requirements.txt
requests==2.32.3
EOF

python -m venv create_layer
source create_layer/bin/activate
pip install -r requirements.txt
mkdir python
cp -r create_layer/lib python/
zip -r requests-py312.zip python

# Cleanup 
deactivate
rm -rf create_layer/ python/
```
