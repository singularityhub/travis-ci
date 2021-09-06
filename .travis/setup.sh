#!/bin/bash -ex

sudo sed -i -e 's/^Defaults\tsecure_path.*$//' /etc/sudoers

# Check Python
echo "Python Version:"
python --version

pip install --user sregistry[all]
echo "sregistry Version:"
sregistry version

echo "Go Version:"
go version

export VERSION=3.7.2 && # adjust this as necessary \
    wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity


./mconfig && \
    make -C builddir && \
    sudo make -C builddir install