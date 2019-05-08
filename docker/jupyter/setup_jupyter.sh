#!/bin/bash

if [ "$1" = "" ]; then
    # Ask user for password and store it in an environment variable
    JUPYTER_HASH=`python -c 'from notebook.auth import passwd; print(passwd());'`
else
    # Use first argument as password for jupyter notebook
    JUPYTER_HASH=`python -c 'from notebook.auth import passwd; print(passwd("$1"));'`
fi

mkdir -p $HOME/.jupyter
cd $HOME/.jupyter
jupyter notebook --generate-config
cat >> $HOME/.jupyter/jupyter_notebook_config.py << EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.password = '$JUPYTER_HASH'
c.NotebookApp.certfile = '$HOME/.jupyter/cert.pem'
c.NotebookApp.keyfile = '$HOME/.jupyter/key.pem'
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $HOME/.jupyter/key.pem \
    -out $HOME/.jupyter/cert.pem \
    -subj "/C=US/ST=MyState/L=MyCity/O=MyOrganization/OU=MyDepartment/CN=localhost"
