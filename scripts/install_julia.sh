#!/bin/bash

# Download Page: https://julialang.org/downloads/

if [ ! -e "julia.tar.gz" ]; then
    echo "Downloading Julia:"
    curl -o julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.5-linux-x86_64.tar.gz
    curl -o julia.asc https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.5-linux-x86_64.tar.gz.asc
fi

tar -xzf julia.tar.gz

