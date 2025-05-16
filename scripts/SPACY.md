# Spacy

## Installation (Amazon Linux 2023)

**Reference**: https://spacy.io/usage

### Dependencies

```bash
sudo dnf install -y python3.11 git
sudo dnf install -y gcc g++ python3.11-devel
curl -Os https://bootstrap.pypa.io/get-pip.py
python3.11 get-pip.py
python3.11 -m pip install virtualenv
python3.11 -m virtualenv $HOME/venv
source $HOME/venv/bin/activate
```

### Python Environment

```bash
pip install -U pip setuptools wheel
git clone https://github.com/explosion/spaCy
cd spaCy
pip install -r requirements.txt
pip install --no-build-isolation --editable .
python -m spacy download en_core_web_sm
```

### Test spaCy

```bash
$ python -c "import spacy; print(spacy.__version__); nlp =
spacy.load('en_core_web_sm'); doc = nlp('This is a test sentence.');
print([token.text for token in doc])"
```

```python
3.8.5
['This', 'is', 'a', 'test', 'sentence', '.']
```

**Report EC2 Instance Type**

```
$ TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-
metadata-token-ttl-seconds: 21600"`
$ INSTANCE_TYPE=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN"
http://169.254.169.254/latest/meta-data/instance-type` && echo $INSTANCE_TYPE
```

```
c6g.large
```
