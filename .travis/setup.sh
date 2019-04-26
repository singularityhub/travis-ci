#!/bin/bash -ex

sudo sed -i -e 's/^Defaults\tsecure_path.*$//' /etc/sudoers

# Check Python

echo "Python Version:"
python --version
sudo pip install --upgrade pip 
sudo pip install sregistry[all]
sregistry version

echo "sregistry Version:"

# Install Singularity

SINGULARITY_BASE="${GOPATH}/src/github.com/sylabs/singularity"
export PATH="${GOPATH}/bin:${PATH}"
cd ${SINGULARITY_BASE}
./mconfig -v -p /usr/local
make -j `nproc 2>/dev/null || echo 1` -C ./builddir all
sudo make -C ./builddir install
