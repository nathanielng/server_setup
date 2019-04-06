echo ">>>>> 1 >>>>> Install Dependencies"
sudo yum install -y autoconf automake gcc gcc-c++ zlib-devel ncurses-devel protobuf-devel openssl-devel

echo ">>>>> 2 >>>>> Clone Git Repository"
git clone -b mosh-stable https://github.com/mobile-shell/mosh.git

echo ">>>>> 3 >>>>> ./autogen.sh"
cd mosh/
./autogen.sh

echo ">>>>> 4 >>>>> ./configure"
./configure

echo ">>>>> 5 >>>>> ./make"
make

echo ">>>>> 6 >>>>> sudo make install"
sudo make install  # mosh-server and mosh-client will be in src/frontend/

echo ">>>>> 7 >>>>> start server: src/frontend/mosh-server"
cd src/frontend
./mosh-server

