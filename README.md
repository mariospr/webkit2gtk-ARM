# WebKit2GTK+ cross-compilation environment for ARM

Resources to allow cross compiling WebKit2GTK+ for ARM.

## Requirements

* A host machine with lots of CPUs and RAM (16GB recommended)
* RootFS for the target device
  - You need to adjust the path in the CMake Toolchain file accordingly (e.g /schroot/eos-master-armhf)
* Packages to create and use the chroot: debootstrap, chroot and schroot
  - Debian/Ubuntu: `sudo apt-get install debootstrap chroot schroot`
  - Fedora: `sudo dnf install debootstrap chroot schroot`

## Instructions

(1) First of all, create the chroot:
```
$ sudo /usr/sbin/debootstrap \
    --arch amd64 \
    --components=main,universe \
    xenial /path/to/chroot http://uk.archive.ubuntu.com/ubuntu
```

(2) Create a configuration file for schroot, for instance under `/etc/schroot/chroot.d/xenial-amd64`, with the following contents (replacing `<username>` and `<group>`):
```
[xenial-amd64]
description=Ubuntu 64-bit chroot based on Xenial
type=directory
directory=/path/to/chroot
users=<username>
groups=<group>
root-users=<username>
setup.copyfiles=default/copyfiles
setup.fstab=default/xenial-amd64.fstab
```

(3) Now you need to create that file under `/etc/schroot/default` so that you can tell schroot to bind mount the path to the RootFS when entering the chroot. To do that, create a copy of `/etc/schroot/default/fstab` (`sudo cp /etc/schroot/default/fstab/xenial-amd64.fstab`) and then add this line to its contents:
```
# To crosscompile WebKitGTK
/schroot/eos-master-armhf  /schroot/eos-master-armhf        none    rw,bind         0       0
```
...or whatever the path to the RootFS is. Just remember that the second column specifies the mount point **inside** the chroot, so it has to be on sync with the path referenced from the CMake Toolchain file.

(4) You should be able to **enter the chroot** with your regular user session:
```
  $ schroot -c xenial-amd64
```

(5) Finally, from inside the chroot, you can **run the `bootstrap.sh` script as the root user** (or using sudo) provided with this repository to provision it with the tools you need to build Webkit, and then **copy the `armv7l-toolchain.cmake` file to some local path**, and you're good to go.

(6) Now create a BUILD directory in `/path/to/your/WebKit` and configure the build (you might want to pass extra/different parameters, though) from inside the chroot:
```
  $ mkdir /path/to/your/WebKit/BUILD && cd /path/to/your/WebKit/BUILD
  $ cmake -DCMAKE_TOOLCHAIN_FILE=/home/mario/work/webkit2gtk-ARM/armv7l-toolchain.cmake \
        -DPORT=GTK \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_SYSCONFDIR=/etc \
        -DCMAKE_INSTALL_LOCALSTATEDIR=/var \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib/arm-linux-gnueabihf \
        -DCMAKE_INSTALL_LIBEXECDIR=lib/arm-linux-gnueabihf \
        -DENABLE_PLUGIN_PROCESS_GTK2=OFF \
        -DENABLE_GEOLOCATION=OFF \
        -DENABLE_GLES2=ON \
        -DUSE_LD_GOLD=OFF \
        /path/to/your/WebKit
```

(7) Finally, and still from inside the chroot, build the thing:
```
  $ make VERBOSE=1 -j12    # Or anything else, this is just what I use
```

And that should be all. Now you should be able to copy the relevant files over to the target machine and use your cross-compiled WebKit build.

Enjoy!
