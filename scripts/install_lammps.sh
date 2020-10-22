#!/usr/bin/env python

# Install Dependencies
sudo apt update
sudo apt -y upgrade
sudo apt -y install cmake fftw-dev libpng-dev libjpeg-dev openmpi-bin

# Download LAMMPS
curl -O https://wxkzhe3i.s3-ap-southeast-1.amazonaws.com/lammps-stable.tar.gz
tar -xzf lammps-stable.tar.gz
cd lammps-3Mar20/

# Build LAMMPS
mkdir -p build
cd build
cmake ../cmake
cmake --build .

# Copy LAMMPS executable
sudo cp lmp /usr/local/bin

