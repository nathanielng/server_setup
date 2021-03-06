echo ">>>>> 1 >>>>> Install Dependencies"
sudo yum install -y autoconf automake gcc gcc-c++ zlib-devel ncurses-devel protobuf-devel openssl-devel

echo ">>>>> 2 >>>>> Clone Git Repository"
git clone -b mosh-stable https://github.com/mobile-shell/mosh.git

echo ">>>>> 3 >>>>> ./autogen.sh"
cd mosh/
./autogen.sh

echo ">>>>> 4 >>>>> ./configure --prefix=/usr/local"
./configure --prefix=/usr/local

echo ">>>>> 5 >>>>> ./make"
make

echo ">>>>> 6 >>>>> sudo make install"
sudo make install  # mosh-server and mosh-client will be in src/frontend/

echo ">>>>> 7 >>>>> start server: src/frontend/mosh-server"
cd src/frontend
./mosh-server

ps -ef | grep mosh
if [ "$?" -ne 0 ]; then
    echo "ERROR: failed to start mosh-server"
    exit 1
fi

