#!/bin/bash -e
#
# Vagrant provisioning script for cross compiling WebKit2GTK+

# System packages
# ---------------

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Build dependencies:
apt-get install -y --assume-yes \
        gawk \
        cmake \
        debhelper \
        gperf \
        bison \
        flex \
        ruby

apt-get install -y --assume-yes \
        cpp-4.9-arm-linux-gnueabihf \
        g++-4.9-arm-linux-gnueabihf \
        gcc-4.9-arm-linux-gnueabihf \
        gcc-4.9-arm-linux-gnueabihf-base \
        libasan1-armhf-cross \
        libgcc-4.9-dev-armhf-cross \
        libstdc++-4.9-dev-armhf-cross
