#!/bin/bash

echo "This is a script to install frequently used Python packages"

curl -LO https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
python3 -m pip install virtualenv
virtualenv venv -p python3
source venv/bin/activate

pip install bokeh jupyter matplotlib numpy pandas scikit-learn scipy
pip install autopep8 flake8 python-dateutil pytz virtualenv
pip install bs4 gspread lxml html5lib openpyxl richxerox xlrd webloc
pip install awscli oauth2client
