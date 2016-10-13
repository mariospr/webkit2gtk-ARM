# CMake Toolchain file to cross compile WebKit2GTK+ for ARM (tested with 2.14.0)
#
# Environment:
#   * Ubuntu Xenial chroot (amd64)
#   * Root FS for the target device (e.g. /schroot/eos-master-armhf)
#   * Usual WebKit build deps installed in the Root FS
#   * Build dependencies in the host (xenial chroot):
#     gawk cmake debhelper gperf bison flex ruby
#   * Cross compiler packages in the host (xenial chroot):
#       cpp-4.9-arm-linux-gnueabihf g++-4.9-arm-linux-gnueabihf \
#       gcc-4.9-arm-linux-gnueabihf gcc-4.9-arm-linux-gnueabihf-base \
#       libasan1-armhf-cross libgcc-4.9-dev-armhf-cross \
#       libstdc++-4.9-dev-armhf-cross
#
# How to build:
#   1. Write this file to disk (e.g. armv7l-toolchain.cmake)
#   2. From WebKit top source directory, create a BUILD dir:
#        $ mkdir BUILD && cd BUILD
#   3. Configure the build, passing any extra parameter you need:
#        $ cmake -DCMAKE_TOOLCHAIN_FILE=$(pwd)/../armv7l-toolchain.cmake \
#              -DPORT=GTK \
#              -DCMAKE_BUILD_TYPE=Release \
#              -DCMAKE_INSTALL_SYSCONFDIR=/etc \
#              -DCMAKE_INSTALL_LOCALSTATEDIR=/var \
#              -DCMAKE_INSTALL_PREFIX=/usr \
#              -DCMAKE_INSTALL_LIBDIR=lib/arm-linux-gnueabihf \
#              -DCMAKE_INSTALL_LIBEXECDIR=lib/arm-linux-gnueabihf \
#              -DENABLE_PLUGIN_PROCESS_GTK2=OFF \
#              -DENABLE_GEOLOCATION=OFF \
#              -DENABLE_GLES2=ON \
#              -DUSE_LD_GOLD=OFF \
#              -DUSE_GSTREAMER_GL=ON \
#              ..
#   4. Build the thing:
#        $ make VERBOSE=1 -j12    # Or anything else, this is just what I use

# Path to the target RootFS (adjust as needed)
SET(ROOTFS "/schroot/eos-master-armhf")

SET(MULTIARCH "arm-linux-gnueabihf")

# Setting the system name to "Linux" sets CMAKE_CROSSCOMPILING to true
SET(CMAKE_SYSTEM_NAME "Linux")
SET(CMAKE_SYSTEM_PROCESSOR "armv7l")

# Specify the cross compilers
SET(CMAKE_C_COMPILER /usr/bin/${MULTIARCH}-gcc-4.9)
SET(CMAKE_CXX_COMPILER /usr/bin/${MULTIARCH}-g++-4.9)

# This is very important, so that we find the right headers and libraries
# without explicitly listing the default include directories (e.g. JSC)
SET(CMAKE_SYSROOT "${ROOTFS}")

# Ensure that FIND_PACKAGE() functions and friends look in the rootfs
# only for libraries and header files, but not for programs (e.g perl)
SET(CMAKE_FIND_ROOT_PATH "${ROOTFS}")
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Add include directories from the rootfs matching the current toolchain
INCLUDE_DIRECTORIES(SYSTEM
  "${ROOTFS}/usr/include"
  "${ROOTFS}/usr/include/c++/4.9"
  "${ROOTFS}/usr/include/arm-linux-gnueabihf/c++/4.9"
  )

# CMake does not pick CPPFLAGS, so we add it manually into CFLAGS and CXXFLAGS
# Note: I have no idea why the first include directory from the previous list
# gets ignored when building some components, so I pass it here as well.
SET(CPPFLAGS "-DG_DISABLE_CAST_CHECKS")
SET(ENV{CFLAGS} "${CPPFLAGS} -fstack-protector-strong -Wall -Wformat -Werror=format-security -I${ROOTFS}/usr/include -isystem ${ROOTFS}/usr/include")
SET(ENV{CXXFLAGS} "${CPPFLAGS} -fstack-protector-strong -Wall -Wformat -Werror=format-security -I${ROOTFS}/usr/include -isystem ${ROOTFS}/usr/include")

# CMake does not pick LDFLAGS, so we add it manually too
SET(ENV{LDFLAGS} "-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed -Wl,-rpath-link,${ROOTFS}/lib/arm-linux-gnueabihf")

# This setup is meant for development so make sure we build without optimizations
# and with some debug symbols (-g2 is too much in our ARM platform).
SET(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG" CACHE STRING "Flags used by the compiler during release builds." FORCE)
SET(CMAKE_CXX_FLAGS_RELEASE "-O2  -DNDEBUG"  CACHE STRING "Flags used by the compiler during release builds." FORCE)
SET(CMAKE_C_FLAGS_DEBUG "-g1 -O0" CACHE STRING "Flags used by the compiler during debug builds." FORCE)
SET(CMAKE_CXX_FLAGS_DEBUG "-g1 -O0"  CACHE STRING "Flags used by the compiler during debug builds." FORCE)

# Need to export this variables for pkg-config to pick them up, so that it
# sets the right search path and prefixes the result paths with the rootfs.
SET(ENV{PKG_CONFIG_PATH} "${ROOTFS}/usr/share/pkgconfig")
SET(ENV{PKG_CONFIG_LIBDIR} "${ROOTFS}/usr/lib/${MULTIARCH}/pkgconfig:${ROOTFS}/usr/lib/pkgconfig")
SET(ENV{PKG_CONFIG_SYSROOT_DIR} "${ROOTFS}")

# These variables make sure that pkg-config does never discard standard
# include and library paths from the compile and linking flags.
SET(ENV{PKG_CONFIG_ALLOW_SYSTEM_CFLAGS} 1)
SET(ENV{PKG_CONFIG_ALLOW_SYSTEM_LIBS} 1)
SET(PKG_CONFIG_USE_CMAKE_PREFIX_PATH TRUE)
