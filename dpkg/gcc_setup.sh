#!/bin/bash
sudo apt-get install build-essential binutils gfortran libgmp-dev libmpfr-dev libmpc-dev libisl-dev
if [ ! -e "gcc-6.5.0.tar.gz" ]; then
    curl -O http://mirrors-usa.go-parts.com/gcc/releases/gcc-6.5.0/gcc-6.5.0.tar.gz
    sha512sum gcc-6.5.0.tar.gz | grep 4ac91a81b345b70b62ee8c290d67b368b3c4e3e54cf9b4ad04accd16e5341fa922cac9cd9f82c0877498de12b16eb124bc70e2e2d04a5659e4b662ed9f08cc54
    if [ "$?" -ne 0 ]; then
        echo "Incorrect sha1sum"
        exit 1
    fi
fi
tar -xzf gcc-6.5.0.tar.gz 
cd gcc-6.5.0/

./contrib/download_prerequisites
if [ "$?" -ne 0 ]; then
    exit 2
fi

cd .. && mkdir -p objdir && cd objdir
$PWD/../gcc-6.5.0/configure --prefix=/opt/gcc65 --disable-multilib --enable-languages=c,c++,fortran CC=/usr/bin/gcc-7 CXX=/usr/bin/g++-7
time make
sudo make install

