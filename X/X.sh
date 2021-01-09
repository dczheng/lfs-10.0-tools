#!/bin/bash

X-env() {

    export LFS="/home/dczheng/work/lfs-10.0-tools/X"
    export PKGS=$LFS/base
    source $LFS/../lfs-tools.sh
    export XORG_PREFIX=/usr
    export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
    cd $LFS

    export MKOPT="-j4"
    alias ls="ls --color"
    alias ll="ls -l"
    alias df="df -h"
}

X-build() {
    lfs-create-dir build
    LFS_BUILD_DIR="build"
    export EXIT_FLAG=""
    lfs-build-aux $LFS/base-b/util-macros
    lfs-build-aux $LFS/base-b/xorgproto
    lfs-build-aux $LFS/base-b/libXau
    lfs-build-aux $LFS/base-b/libXdmcp
    lfs-build-aux $LFS/base-b/xcb-proto
    lfs-build-aux $LFS/base-b/libxcb

    lib-build

    lfs-build-aux $LFS/base-b/xcb-util
    lfs-build-aux $LFS/base-b/xcb-util-image
    lfs-build-aux $LFS/base-b/xcb-util-keysyms
    lfs-build-aux $LFS/base-b/xcb-util-renderutil
    lfs-build-aux $LFS/base-b/xcb-util-wm
    lfs-build-aux $LFS/base-b/xcb-util-cursor
    lfs-build-aux $LFS/base-b/mesa
    lfs-build-aux $LFS/base-b/xbitmaps

    app-build

    lfs-build-aux $LFS/base-b/xcursor-themes

    font-build

    lfs-build-aux $LFS/base-b/xkeyboard-config
    lfs-build-aux $LFS/base-b/xterm
    lfs-build-aux $LFS/base-b/xclock
    lfs-build-aux $LFS/base-b/xinit

}

lib-build() {

bash -e
cd $LFS/lib
for package in $(grep -v '^#' $LFS/lib.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  docdir="--docdir=$XORG_PREFIX/share/doc/$packagedir"
  case $packagedir in
    libICE* )
      ./configure $XORG_CONFIG $docdir ICE_LIBS=-lpthread
    ;;

    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-devel-docs
    ;;

    libXt-[0-9]* )
      ./configure $XORG_CONFIG $docdir \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac
  make
  #make check 2>&1 | tee ../$packagedir-make_check.log
  make install
  popd
  rm -rf $packagedir
 /sbin/ldconfig
done
exit
ln -sv $XORG_PREFIX/lib/X11 /usr/lib/X11 &&
ln -sv $XORG_PREFIX/include/X11 /usr/include/X11
}

app-build() {
bash -e
cd $LFS/app
for package in $(grep -v '^#' $LFS/app.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.?z*}
  tar -xf $package
  pushd $packagedir
     case $packagedir in
       luit-[0-9]* )
         sed -i -e "/D_XOPEN/s/5/6/" configure
       ;;
     esac

     ./configure $XORG_CONFIG
     make
     make install
  popd
  rm -rf $packagedir
done
exit
rm -f $XORG_PREFIX/bin/xkeystone
}

font-build() {
bash -e
cd $LFS/font

for package in $(grep -v '^#' $LFS/font.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG
    make
    make install
  popd
  rm -rf $packagedir
done
exit

install -v -d -m755 /usr/share/fonts  &&
ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF &&
ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF

}

driver-build() {
    export EXIT_FLAG=""
    lfs-build-aux $LFS/driver/libevdev
    lfs-build-aux $LFS/driver/xf86-input-synaptics
    lfs-build-aux $LFS/driver/xf86-video-intel
}

X-env
