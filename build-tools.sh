#!/bin/bash

create-dir() {
    if [ -d $1 ]
    then
        rm -rf $1
    fi
    mkdir -p $1
}

set-error-flag() {
   if [ $1 != 0 ]
   then
       echo "Failed to build $2"
       export EXIT_FLAG="Failed"
   fi
}

run-build() {

    if [ 'x'$EXIT_FLAG != 'x' ]
    then
        return
    fi

    cd $BUILD_BUILD_DIR
    #echo $BUILD
    source $1
    set-error-flag $? $1

    cd $BUILD_ROOT_DIR
}
