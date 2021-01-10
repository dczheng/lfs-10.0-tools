#!/bin/bash

lfs-env() {
    set +h
    umask 022

    unset C_INCLUDE_PATH
    unset LIBRARY_PATH
    unset LD_LIBRARY_PATH
    unset CC
    unset CXX

    export LFS=/mnt
    export PKGS=$LFS/sources
    export LFS_TOOLS=$LFS/lfs-10.0-tools
    PS1="lfs@\W -> "
    export BUILD_ROOT_DIR=$LFS

    export LC_ALL=POSIX
    export LFS_TGT=$(uname -m)-lfs-linux-gnu
    export PATH=$LFS/tools/bin:/usr/bin:/bin:$LFS_TOOLS:$PATH
    export MKOPT="-j4"

    alias ls="ls --color"
    alias ll="ls -l"
    alias df="df -h"

    export LFS_BUILD_DIR1=$LFS/build1
    export LFS_BUILD_DIR2=$LFS/build2
    cd $LFS
}

lfs-build-init() {
    create-dir $LFS/bin
    create-dir $LFS/etc
    create-dir $LFS/lib
    create-dir $LFS/lib64
    create-dir $LFS/sbin
    create-dir $LFS/usr
    create-dir $LFS/var
    create-dir $LFS/tools
}

lfs-build1() {
    create-dir $LFS_BUILD_DIR1
    BUILD_BUILD_DIR=$LFS_BUILD_DIR1
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/b1/binutils
    run-build $LFS_TOOLS/b1/gcc
    run-build $LFS_TOOLS/b1/linux-api-header
    run-build $LFS_TOOLS/b1/glibc
    run-build $LFS_TOOLS/b1/libstdc++

}

lfs-build2() {
    create-dir $LFS_BUILD_DIR2
    BUILD_BUILD_DIR=$LFS_BUILD_DIR2
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/b2/m4
    run-build $LFS_TOOLS/b2/ncurses
    run-build $LFS_TOOLS/b2/bash
    run-build $LFS_TOOLS/b2/coreutils
    run-build $LFS_TOOLS/b2/diffutils
    run-build $LFS_TOOLS/b2/file
    run-build $LFS_TOOLS/b2/findutils
    run-build $LFS_TOOLS/b2/gawk
    run-build $LFS_TOOLS/b2/grep
    run-build $LFS_TOOLS/b2/gzip
    run-build $LFS_TOOLS/b2/make
    run-build $LFS_TOOLS/b2/patch
    run-build $LFS_TOOLS/b2/sed
    run-build $LFS_TOOLS/b2/tar
    run-build $LFS_TOOLS/b2/xz
    run-build $LFS_TOOLS/b2/binutils
    run-build $LFS_TOOLS/b2/gcc
    cd $LFS
}

lfs-chroot() {
    chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
    chown -R root:root $LFS/lib64
    mkdir -pv $LFS/{dev,proc,sys,run}
    mknod -m 600 $LFS/dev/console c 5 1
    mknod -m 666 $LFS/dev/null c 1 3
    mount -v --bind /dev $LFS/dev
    mount -v --bind /dev/pts $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    #if [ -h $LFS/dev/shm  ]
    #then
    #      mkdir -pv $LFS/$(readlink $LFS/dev/shm)
    #fi
    chroot "$LFS" /usr/bin/env -i   \
        HOME=/root                  \
        TERM="$TERM"                \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/bin:/usr/bin:/sbin:/usr/sbin \
        /bin/bash --login +h
}

lfs-chroot2() {
    chroot "$LFS" /usr/bin/env -i          \
    HOME=/root TERM="$TERM"            \
    PS1='(lfs chroot) \u:\w\$ '        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login
}

lfs-env
source $LFS_TOOLS/lfs-tools.sh
