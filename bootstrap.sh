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

# Flatpak runtimes
# ----------------

tmpdir=$(mktemp -d) && pushd ${tmpdir}

wget -O gnome-sdk.gpg https://sdk.gnome.org/keys/gnome-sdk.gpg && \
{
    flatpak remote-add --gpg-import=gnome-sdk.gpg gnome https://sdk.gnome.org/repo
    flatpak install gnome org.gnome.Platform 3.22
    flatpak install gnome org.gnome.Sdk 3.22
}

popd && rm -rf ${tmpdir}

# Additional configuration
# ------------------------

# Some modules installed with npm install look for node
sudo ln -s /usr/bin/nodejs /usr/bin/node


