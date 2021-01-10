#!/bin/bash

tools-env() {

    export TOOLSDIR="/home/dczheng/work/lfs-10.0-tools/tools"
    export BUILD_ROOT_DIR=$TOOLSDIR
    export PKGS=$BUILD_ROOT_DIR/sources
    cd $TOOLSDIR

    source $TOOLSDIR/../build-tools.sh

    export MKOPT="-j4"
    alias ls="ls --color"
    alias ll="ls -l"
    alias df="df -h"
}

tools-build() {
    
    cd $BUILD_ROOT_DIR
    create-dir "build"
    BUILD_BUILD_DIR="build"
    export EXIT_FLAG=""
    

    run-build $TOOLSDIR/b/tree
    run-build $TOOLSDIR/b/libuv
    run-build $TOOLSDIR/b/libarchive
    run-build $TOOLSDIR/b/curl
    run-build $TOOLSDIR/b/cmake
    run-build $TOOLSDIR/b/sudo
    run-build $TOOLSDIR/b/ntfs-3g
    run-build $TOOLSDIR/b/fish
    run-build $TOOLSDIR/b/openssh
    run-build $TOOLSDIR/b/which
    run-build $TOOLSDIR/b/pciutils
    run-build $TOOLSDIR/b/libnl
    run-build $TOOLSDIR/b/wpa_supplicant
    run-build $TOOLSDIR/b/dhcpcd


}

tools-env
