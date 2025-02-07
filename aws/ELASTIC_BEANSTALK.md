# Elastic Beanstalk

## 1. Setup

```bash
mkdir -p my-app
cd my-app
```

## 2. Procfile

```bash
web: streamlit run app.py --server.port 8501 --server.address 0.0.0.0
```

## 3. requirements.txt file (Python)

Example file

```bash
cat >> requirements.txt << EOF
boto3==1.34.42
numpy==1.26.1
pandas==2.1.2
python-dotenv==1.0.0
streamlit>=1.31.0
EOF
```

## 4. App (Python)

Example Python app.py

```python
cat >> app.py << EOF
print('Hello world')
EOF
```

## 5. Compress into a single app

```bash
zip -r my-app.zip my-app/
```

