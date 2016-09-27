WebKit2GTK+ cross-compilation environment for ARM
=================================================

Resources to allow cross compiling WebKit2GTK+ for ARM.

Requirements
============

This small project simply creates a VM with all the needed tools to cross-compile WebKit2GTK+
for ARMv7, so it requires very few things, but still something is needed:

* A host machine with lots of RAM (16GB recommended)
  - Adjust Vagrantfile for the amount of memory you want to share (12GB by default)

* Vagrant >= 1.8.5 (tested with 1.8.5 on Debian Testing and Fedora 24)

* VirtualBox >=5.0 (tested with 5.0.16 on Debian Testing and 5.1.4 on Fedora 24)

* RootFS for the target device
  - The RootFS needs to provide all the usual WebKit build dependencies
  - You need to adjust the path in Vagrantfile accordingly (e.g /schroot/eos-master-armhf)

* Checkout of WebKit2GTK+ source code
  - Will be mounted under /home/vagrant/WebKitARM inside the VM
  - You need to adjust the path in Vagrantfile accordingly

Instructions
============

(1) To re-create the development environment, start by cloning the git repository:
```
  $ git clone git@github.com:mariospr/webkit2gtk-ARM.git
  $ cd webkit2gtk-ARM
```

(2) Now you edit `Vagrantfile` and provide the correct paths pointing to your WebKit checkout and the target RootFS

(3) Finally you initialize, provision and run the virtual machine:
```
  $ vagrant up --provider=virtualbox  # Will take some time the first time
  $ vagrant ssh                       # Logs in into the Virtual Machine
```

(4) You'll be inside the VM with access to your WebKit checkout under `/home/vagrant/WebKitARM` and to the CMake Toolchain file under `/home/vagrant/armv7l-toolchain.cmake`, assuming that you have adjusted the paths in step 2.

(5) Create a BUILD directory in /home/vagrant:
```
  $ mkdir BUILD && cd BUILD
```

(6) Configure the build, passing any extra parameter you need. For instance:
```
  $ cmake -DCMAKE_TOOLCHAIN_FILE=/home/vagrant/armv7l-toolchain.cmake \
        -DPORT=GTK \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_SYSCONFDIR=/etc \
        -DCMAKE_INSTALL_LOCALSTATEDIR=/var \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib/arm-linux-gnueabihf \
        -DCMAKE_INSTALL_LIBEXECDIR=lib/arm-linux-gnueabihf \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DENABLE_PLUGIN_PROCESS_GTK2=OFF \
        -DENABLE_GEOLOCATION=OFF \
        -DENABLE_GLES2=ON \
        -DUSE_LD_GOLD=OFF \
        -DUSE_GSTREAMER_GL=ON \
        /home/vagrant/WebKitARM
```

(7) Build the thing:
```
  $ make VERBOSE=1 -j12    # Or anything else, this is just what I use
```
