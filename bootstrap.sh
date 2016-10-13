#!/bin/bash -e
#
# To be executed inside the chroot, to provision the environment

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Ubuntu Xenial does not get the _apt user installed when creating
# a chroot via debootstrap, so create it now to prevent failures.
adduser --force-badname --system --home /nonexistent  \
        --no-create-home --quiet _apt || true

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
