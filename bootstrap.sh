#!/bin/bash -e
#
# Vagrant provisioning script for cross compiling WebKit2GTK+

# System packages
# ---------------

export DEBIAN_FRONTEND=noninteractive
apt-get update

# General build dependencies:
apt-get install -y --assume-yes \
        bison \
        cmake \
        debhelper \
        flex \
        gawk \
        gcc-4.9-base \
        gperf \
        libasan1 \
        libgcc-4.9-dev \
        libstdc++-4.9-dev \
        pkg-config \
        ruby

# Cross compiler:
apt-get install -y --assume-yes \
        cpp-4.9-arm-linux-gnueabihf \
        g++-4.9-arm-linux-gnueabihf \
        gcc-4.9-arm-linux-gnueabihf \
        gcc-4.9-arm-linux-gnueabihf-base \
        libasan1-armhf-cross \
        libgcc-4.9-dev-armhf-cross \
        libstdc++-4.9-dev-armhf-cross
