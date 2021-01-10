#!/bin/bash

lfs-chroot() {
    export LFS=/mnt
    mount -v --bind /dev $LFS/dev
    mount -v --bind /dev/pts $LFS/dev/pts
    mount -v --bind /home $LFS/home
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    chroot "$LFS" /usr/bin/env -i \
        TERM="$TERM"
        PS1="(lfs chroot) \u@\W > " \
        PATH=/bin:/usr/bin/:/sbin:/usr/sbin \
        /bin/bash --login +h
}

X-env() {

    export XDIR="/home/dczheng/work/lfs-10.0-tools/X"
    export BUILD_ROOT_DIR=$XDIR
    cd $XDIR

    source $XDIR/../build-tools.sh

    export XORG_PREFIX="/usr"
    export XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"

    export MKOPT="-j4"
    alias ls="ls --color"
    alias ll="ls -l"
    alias df="df -h"
}

X-build() {
    
    cd $BUILD_ROOT_DIR
    export PKGS=$BUILD_ROOT_DIR/base
    create-dir "base-build"
    BUILD_BUILD_DIR="base-build"
    export EXIT_FLAG=""
    
    #run-build $XDIR/base-b/freetype
    #run-build $XDIR/base-b/fontconfig
    #run-build $XDIR/base-b/libpng

    #run-build $XDIR/base-b/util-macros
    #run-build $XDIR/base-b/xorgproto
    #run-build $XDIR/base-b/libXau
    #run-build $XDIR/base-b/libXdmcp
    #run-build $XDIR/base-b/xcb-proto
    #run-build $XDIR/base-b/libxcb

    #lib-build

    #run-build $XDIR/base-b/xcb-util
    #run-build $XDIR/base-b/xcb-util-image
    #run-build $XDIR/base-b/xcb-util-keysyms
    #run-build $XDIR/base-b/xcb-util-renderutil
    #run-build $XDIR/base-b/xcb-util-wm
    #run-build $XDIR/base-b/xcb-util-cursor

    #run-build $XDIR/base-b/libdrm
    #run-build $XDIR/base-b/markupsafe
    #run-build $XDIR/base-b/mako
    #run-build $XDIR/base-b/mesa

    #run-build $XDIR/base-b/xbitmaps

    #app-build

    #run-build $XDIR/base-b/xcursor-themes

    #font-build
    #run-build $XDIR/base-b/xkeyboard-config
    #run-build $XDIR/base-b/pixman
    #run-build $XDIR/base-b/xorg-server
    #
    #run-build $XDIR/base-b/xterm
    #run-build $XDIR/base-b/xclock
    #run-build $XDIR/base-b/xinit

    #run-build $XDIR/base-b/libevdev
    #run-build $XDIR/base-b/xf86-input-synaptics
    #run-build $XDIR/base-b/xf86-video-intel

    run-build $XDIR/base-b/mtdev
    run-build $XDIR/base-b/xf86-input-evdev
    run-build $XDIR/base-b/libinput

}

lib-build() {

cd $XDIR/lib
for package in $(grep -v '^#' $XDIR/lib.md5 | awk '{print $2}')
do

  if [ 'x'$EXIT_FLAG != 'x' ]
  then
    cd $XDIR
    return
  fi

  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  docdir="--docdir=/usr/share/doc/$packagedir"

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
  esac \
  && make $MKOPT \
  && make install
  set-error-flag $? $packagedir
  popd

  rm -rf $packagedir
  /sbin/ldconfig

done
cd $XDIR
}

app-build() {
cd $XDIR/app
for package in $(grep -v '^#' $XDIR/app.md5 | awk '{print $2}')
do
  if [ 'x'$EXIT_FLAG != 'x' ]
  then
      cd $XDIR
	  return
  fi

  packagedir=${package%.tar.?z*}
  tar -xf $package
  pushd $packagedir
     case $packagedir in
       luit-[0-9]* )
         sed -i -e "/D_XOPEN/s/5/6/" configure
       ;;
     esac

     ./configure $XORG_CONFIG \
     && make $MKOPT \
     && make install
     set-error-flag $? $packagedir
  popd
  rm -rf $packagedir
done
rm -f /usr/bin/xkeystone
cd $XDIR
echo $EXIT_FLAG
}

font-build() {

cd $XDIR/font
for package in $(grep -v '^#' $XDIR/font.md5 | awk '{print $2}')
do
  if [ 'x'$EXIT_FLAG != 'x' ]
  then
      cd $XDIR
	  return
  fi

  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG \
    && make $MKOPT \
    && make install
    set-error-flag $? $packagedir
  popd
  rm -rf $packagedir
done

install -v -d -m755 /usr/share/fonts  &&
cd $XDIR

}

X-env
