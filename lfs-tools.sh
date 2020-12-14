#!/bin/bash

lfs-create-dir() {
    if [ -d $1 ]
    then
        rm -rf $1
    fi
    mkdir -p $1
}

lfs-build-aux() {

    if [ 'x'$EXIT_FLAG != 'x' ]
    then
        return
    fi

    cd $LFS_BUILD_DIR
    #echo $BUILD
    source $1

    if [ $? != 0 ]
    then
        echo "Failed to build $1"
    	export EXIT_FLAG="Failed"
    fi
    cd $LFS
}
