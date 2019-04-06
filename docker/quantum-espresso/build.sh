#!/bin/bash
if [ ! -e "qe-6.4.tar.gz" ]; then
    curl -o qe-6.4.tar.gz https://codeload.github.com/QEF/q-e/tar.gz/qe-6.4
fi
docker build -t qe64 .
if [ "$?" -eq 0 ]; then
    echo "Docker image built successfully"
    echo "Run it with"
    echo "docker run --rm -it qe64"
fi
