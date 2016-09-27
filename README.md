# WebKit2GTK+ cross-compilation environment for ARM

Resources to allow cross compiling WebKit2GTK+ for ARM.

Two methods:
  * Using a local chroot (debootstrap + schroot): harder to setup, faster builds
  * Using a Virtual Machine (using Vagrant): easier to setup, way slower builds

## Using a chroot (debootstrap + schroot)

This method is harder to setup than the one based on VMs, but build times are MUCH faster, so I'm describing it first.

As reference, I could cross compile WebKit2GTK+ 2.14.0 from scratch using a chroot in my desktop PC (12 Xeon cores at 3.54 GHz, 16GB DDR4 RAM, fast SSD) in less than 1 hour, while the VM-based method in the same machine (sharing only 8 cores and 12GB of RAM, though) I could only build ~15% in about 2h. So yes, the chroot method seems to be about 12x faster under those circumstances, which is why I'd recommend it instead of the easier method.

### Requirements

To do that, you have a different set of requirements:

* A host machine with lots of CPUs and RAM (16GB recommended)
* RootFS for the target device
  - You need to adjust the path in Vagrantfile and the CMake Toolchain file accordingly (e.g /schroot/eos-master-armhf)
* Packages to create and use the chroot: debootstrap, chroot and schroot
  - Debian/Ubuntu: sudo apt-get install debootstrap chroot schroot
  - Fedora: sudo dnf install debootstrap chroot schroot

### Instructions

(1) Now you have the requirements installed you can create the chroot:
```
$ sudo /usr/sbin/debootstrap \
    --arch amd64 \
    --components=main,universe \
    wily /path/to/chroot http://uk.archive.ubuntu.com/ubuntu
```

(2) Create a configuration file for schroot, for instance under `/etc/schroot/chroot.d/wily-amd64`, with the following contents (replacing `<username>` and `<group>`):
```
[wily-amd64]
description=Ubuntu 64-bit chroot based on Wily
type=directory
directory=/path/to/chroot
users=<username>
groups=<group>
root-users=<username>
setup.copyfiles=default/copyfiles
setup.fstab=default/wily-amd64.fstab
```

(3) Now you need to create that file under `/etc/schroot/default` so that you can tell schroot to bind mount the path to the RootFS when entering the chroot. To do that, create a copy of `/etc/schroot/default/fstab` (`sudo cp /etc/schroot/default/fstab/wily-amd64.fstab`) and then add this line to its contents:
```
# To crosscompile WebKitGTK
/schroot/eos-master-armhf  /schroot/eos-master-armhf        none    rw,bind         0       0
```
...or whatever the path to the RootFS is. Just remember that the second column specifies the mount point **inside** the chroot, so it has to be on sync with the path referenced from the CMake Toolchain file.

(4) You should be able to **enter the chroot** with your regular user session:
```
  $ schroot -c wily-amd64
```

(5) Finally, from inside the chroot, you can **run the `bootstrap.sh` script** provided with this repository to provision it with the tools you need to build Webkit, and then **copy the `armv7l-toolchain.cmake` file to some local path, and you're good to go.

(6) To build WebKit now, you follow similar last steps to the ones for the case using Vagrant:

(6.1) Create a BUILD directory in `/path/to/your/WebKit`:
```
  $ mkdir /path/to/your/WebKit/BUILD && cd /path/to/your/WebKit/BUILD
```
(6.2) Configure the build, passing any extra parameter you need. For instance:
```
  $ cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/armv7l-toolchain.cmake \
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
        /path/to/your/WebKit
```

(6.3) Build the thing:
```
  $ make VERBOSE=1 -j12    # Or anything else, this is just what I use
```

## Using a Virtual Machine (using Vagrant)

The first method described simply creates a VM with all the needed tools to cross-compile WebKit2GTK+
for ARMv7, so it requires very few things, but still something is needed:

### Requirements

* A host machine with lots of CPUs and RAM (16GB recommended)
  - Adjust Vagrantfile for the amount of resources you want to share (8 cores and 12GB by default)

* Vagrant >= 1.8.5 (tested with 1.8.5 on Debian Testing and Fedora 24)

* VirtualBox >=5.0 (tested with 5.0.16 on Debian Testing and 5.1.4 on Fedora 24)

* RootFS for the target device
  - The RootFS needs to provide all the usual WebKit build dependencies
  - You need to adjust the path in Vagrantfile and the CMake Toolchain file accordingly (e.g /schroot/eos-master-armhf)

* Checkout of WebKit2GTK+ source code
  - Will be mounted under /home/vagrant/WebKitARM inside the VM
  - You need to adjust the path in Vagrantfile accordingly

### Instructions

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

(5) Create a BUILD directory in `/home/vagrant/WebKitARM`:
```
  $ mkdir WebKitARM/BUILD && cd WebKitARM/BUILD
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

(8) Once you finish, you'll have the BUILD objects under `BUILD/`, inside the checkout directory (both inside and outside the VM).
