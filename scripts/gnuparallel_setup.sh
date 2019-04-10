#!/bin/bash
if [ ! "$1" = "" ]; then
    PREFIX=${1}
elif [ "$PREFIX" = "" ]; then
    PREFIX=$HOME
fi
echo "GNU Parallel will be installed to the folder: $PREFIX"

curl -O http://ftp.gnu.org/gnu/parallel/parallel-20190322.tar.bz2
tar -xjf parallel-20190322.tar.bz2
cd parallel-20190322
./configure --prefix=$PREFIX && make && make install

