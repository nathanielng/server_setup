#!/bin/bash
curl -O http://ftp.gnu.org/gnu/parallel/parallel-20190322.tar.bz2
tar -xjf parallel-20190322.tar.bz2
cd parallel-20190322
./configure --prefix=$HOME && make && make install

