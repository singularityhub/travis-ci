Bootstrap: docker
From: ubuntu:latest

%runscript
    exec echo "Never sneeze on an ice cube tray, $@!"
