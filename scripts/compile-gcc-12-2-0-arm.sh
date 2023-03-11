#!/bin/bash

# curl -s https://raw.githubusercontent.com/nathanielng/server_setup/master/scripts/compile-gcc-12-2-0-arm.sh | bash

wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
tar zxvf gcc-12.2.0.tar.gz
cd gcc-12.2.0
./contrib/download_prerequisites
./configure --enable-languages=c,c++,fortran --prefix=/home/ec2-user/gnu12.2.0-arm64 --enable-shared --with-system-zlib --build=aarch64-redhat-linux
make -j
make install
