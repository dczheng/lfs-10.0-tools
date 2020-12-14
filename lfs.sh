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
    lfs-create-dir $LFS/bin
    lfs-create-dir $LFS/etc
    lfs-create-dir $LFS/lib
    lfs-create-dir $LFS/lib64
    lfs-create-dir $LFS/sbin
    lfs-create-dir $LFS/usr
    lfs-create-dir $LFS/var
    lfs-create-dir $LFS/tools
}

lfs-build1() {
    lfs-create-dir $LFS_BUILD_DIR1
    LFS_BUILD_DIR=$LFS_BUILD_DIR1
    export EXIT_FLAG=""
    lfs-build-aux $LFS_TOOLS/b1/binutils
    lfs-build-aux $LFS_TOOLS/b1/gcc
    lfs-build-aux $LFS_TOOLS/b1/linux-api-header
    lfs-build-aux $LFS_TOOLS/b1/glibc
    lfs-build-aux $LFS_TOOLS/b1/libstdc++

}

lfs-build2() {
    lfs-create-dir $LFS_BUILD_DIR2
    LFS_BUILD_DIR=$LFS_BUILD_DIR2
    export EXIT_FLAG=""
    lfs-build-aux $LFS_TOOLS/b2/m4
    lfs-build-aux $LFS_TOOLS/b2/ncurses
    lfs-build-aux $LFS_TOOLS/b2/bash
    lfs-build-aux $LFS_TOOLS/b2/coreutils
    lfs-build-aux $LFS_TOOLS/b2/diffutils
    lfs-build-aux $LFS_TOOLS/b2/file
    lfs-build-aux $LFS_TOOLS/b2/findutils
    lfs-build-aux $LFS_TOOLS/b2/gawk
    lfs-build-aux $LFS_TOOLS/b2/grep
    lfs-build-aux $LFS_TOOLS/b2/gzip
    lfs-build-aux $LFS_TOOLS/b2/make
    lfs-build-aux $LFS_TOOLS/b2/patch
    lfs-build-aux $LFS_TOOLS/b2/sed
    lfs-build-aux $LFS_TOOLS/b2/tar
    lfs-build-aux $LFS_TOOLS/b2/xz
    lfs-build-aux $LFS_TOOLS/b2/binutils
    lfs-build-aux $LFS_TOOLS/b2/gcc
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
