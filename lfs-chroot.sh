#!/bin/bash

lfs-chroot-init() {
    mkdir -pv /{boot,home,mnt,opt,srv}
    mkdir -pv /etc/{opt,sysconfig}
    mkdir -pv /lib/firmware
    mkdir -pv /media/{floppy,cdrom}
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
    mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv /usr/{,local/}share/man/man{1..8}
    mkdir -pv /var/{cache,local,log,mail,opt,spool}
    mkdir -pv /var/lib/{color,misc,locate}

    ln -sfv /run /var/run
    ln -sfv /run/lock /var/lock

    install -dv -m 0750 /root
    install -dv -m 1777 /tmp /var/tmp
    
    ln -sv /proc/self/mounts /etc/mtab
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

    cat > /etc/passwd << EOF
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
    
    cat > /etc/group << EOF
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF
    
    echo "tester:x:$(ls -n $(tty) | cut -d" " -f3):101::/home/tester:/bin/bash" >> /etc/passwd
    echo "tester:x:101:" >> /etc/group
    install -o tester -d /home/tester
    
    exec /bin/bash --login +h
}

lfs-chroot-env() {
    touch /var/log/{btmp,lastlog,faillog,wtmp}
    chgrp -v utmp /var/log/lastlog
    chmod -v 664  /var/log/lastlog
    chmod -v 600  /var/log/btmp
    export LFS="/"
    export LFS_TOOLS=${LFS}lfs-10.0-tools
    export BUILD_ROOT_DIR=$LFS
    export PKGS=${LFS}sources
    export LFS_BUILD_DIR1=${LFS}build1
    export LFS_BUILD_DIR2=${LFS}build2
    export CHROOT_LFS_BUILD_DIR2=${LFS}chroot-build2
    export LFS_BUILD_DIR3=${LFS}build3
    source $LFS_TOOLS/lfs-tools.sh
    export MKOPT="-j4"
    alias ls="ls --color"
    alias ll="ls -l"
    alias df="df -h"
}

lfs-chroot-build2() {
    BUILD_BUILD_DIR=$CHROOT_LFS_BUILD_DIR2
    create-dir $BUILD_BUILD_DIR
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/chroot-b2/libstdc++
    run-build $LFS_TOOLS/chroot-b2/gettext
    run-build $LFS_TOOLS/chroot-b2/bison
    run-build $LFS_TOOLS/chroot-b2/perl
    run-build $LFS_TOOLS/chroot-b2/python
    run-build $LFS_TOOLS/chroot-b2/texinfo
    run-build $LFS_TOOLS/chroot-b2/util-linux

    lfs-clean-after-build2
}

lfs-clean-after-build2() {
    find /usr/{lib,libexec} -name \*.la -delete
    rm -rf /usr/share/{info,man,doc}/*
}

lfs-build3-1() {
    BUILD_BUILD_DIR=$LFS_BUILD_DIR3
    create-dir $BUILD_BUILD_DIR
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/b3/man-pages
    run-build $LFS_TOOLS/b3/tcl
    run-build $LFS_TOOLS/b3/expect
    run-build $LFS_TOOLS/b3/dejagnu
    run-build $LFS_TOOLS/b3/iana-etc
    run-build $LFS_TOOLS/b3/glibc
}

lfs-build3-2() {
    BUILD_BUILD_DIR=$LFS_BUILD_DIR3
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/b3/glibc-after-check
    run-build $LFS_TOOLS/b3/glibc-locale
    run-build $LFS_TOOLS/b3/glibc-conf
    run-build $LFS_TOOLS/b3/zlib
    run-build $LFS_TOOLS/b3/bzip2
    run-build $LFS_TOOLS/b3/xz
    run-build $LFS_TOOLS/b3/zstd
    run-build $LFS_TOOLS/b3/file
    run-build $LFS_TOOLS/b3/readline
    run-build $LFS_TOOLS/b3/m4
    run-build $LFS_TOOLS/b3/bc
    run-build $LFS_TOOLS/b3/flex
    run-build $LFS_TOOLS/b3/binutils
    run-build $LFS_TOOLS/b3/gmp
    run-build $LFS_TOOLS/b3/mpfr
    run-build $LFS_TOOLS/b3/mpc
    run-build $LFS_TOOLS/b3/attr
    run-build $LFS_TOOLS/b3/acl
    run-build $LFS_TOOLS/b3/libcap
    run-build $LFS_TOOLS/b3/shadow
    run-build $LFS_TOOLS/b3/gcc
}

lfs-build3-3() {
    BUILD_BUILD_DIR=$LFS_BUILD_DIR3
    export EXIT_FLAG=""
    run-build $LFS_TOOLS/b3/pkg-config
    run-build $LFS_TOOLS/b3/ncurses
    run-build $LFS_TOOLS/b3/sed
    run-build $LFS_TOOLS/b3/psmisc
    run-build $LFS_TOOLS/b3/gettext
    run-build $LFS_TOOLS/b3/bison
    run-build $LFS_TOOLS/b3/grep
    run-build $LFS_TOOLS/b3/bash
    run-build $LFS_TOOLS/b3/libtool
    run-build $LFS_TOOLS/b3/gdbm
    run-build $LFS_TOOLS/b3/gperf
    run-build $LFS_TOOLS/b3/expat
    run-build $LFS_TOOLS/b3/inetutils
    run-build $LFS_TOOLS/b3/perl
    run-build $LFS_TOOLS/b3/xml-parser
    run-build $LFS_TOOLS/b3/intltool
    run-build $LFS_TOOLS/b3/autoconf
    run-build $LFS_TOOLS/b3/automake
    run-build $LFS_TOOLS/b3/kmod
    run-build $LFS_TOOLS/b3/elfutils
    run-build $LFS_TOOLS/b3/libffi
    run-build $LFS_TOOLS/b3/openssl
    run-build $LFS_TOOLS/b3/Python
    run-build $LFS_TOOLS/b3/ninja
    run-build $LFS_TOOLS/b3/meson
    run-build $LFS_TOOLS/b3/coreutils
    run-build $LFS_TOOLS/b3/check
    run-build $LFS_TOOLS/b3/diffutils
    run-build $LFS_TOOLS/b3/gawk
    run-build $LFS_TOOLS/b3/findutils
    run-build $LFS_TOOLS/b3/groff
    run-build $LFS_TOOLS/b3/grub
    run-build $LFS_TOOLS/b3/less
    run-build $LFS_TOOLS/b3/gzip
    run-build $LFS_TOOLS/b3/iproute2
    fs-build-aux $LFS_TOOLS/b3/kbd
    run-build $LFS_TOOLS/b3/libpipline
    run-build $LFS_TOOLS/b3/make
    run-build $LFS_TOOLS/b3/patch
    run-build $LFS_TOOLS/b3/man-db
    run-build $LFS_TOOLS/b3/tar
    run-build $LFS_TOOLS/b3/texinfo
    run-build $LFS_TOOLS/b3/vim
    run-build $LFS_TOOLS/b3/eudev
    run-build $LFS_TOOLS/b3/procps-ng
    run-build $LFS_TOOLS/b3/util-linux
    run-build $LFS_TOOLS/b3/e2fsprogs
    run-build $LFS_TOOLS/b3/sysklogd
    run-build $LFS_TOOLS/b3/sysvinit

}

lfs-clean-after-build3() {

rm -rf /tmp/*

rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libctf{,-nobfd}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libz.a

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester

rm -rf $LFS_BUILD_DIR1
rm -rf $LFS_BUILD_DIR2
rm -rf $CHROOT_LFS_BUILD_DIR2
rm -rf $LFS_BUILD_DIR3

}

lfs-setup() {
	SETUP_DIR=${LFS}setup
	mkdir $SETUP_DIR
	cd $SETUP_DIR
	tar xvf $PKGS/lfs-bootscripts-20200818.tar.xz
	cd lfs-bootscripts-20200818
	make install
	cd ..
	
	cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda4     /            ext4    defaults            1     1
/dev/sda5     /home            ext4    defaults            1     1
/dev/sda2     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF
    cat /etc/fstab
    
 cd /etc/sysconfig/
cat > ifconfig.enp0s25 << "EOF"
ONBOOT=yes
IFACE=enp0s25
SERVICE=ipv4-static
IP=192.168.20.221
GATEWAY=192.168.20.254
PREFIX=24
BROADCAST=192.168.20.255
EOF

cat > /etc/resolv.conf << "EOF"
nameserver 223.5.5.5
EOF
    
    cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF

    cat /etc/inittab
    
    cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

    cat /etc/inputrc
    
    cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

    cat /etc/shells

    
cat > /etc/hostname << EOF
LFS
EOF
cat /etc/hostname 

cat > /etc/profile << EOF
#Begin /etc/profile
export PS1="\u@\W -> "
alias  ls="ls --color"
alias  ll="ls -l"
#End /etc/prifile
EOF
source /etc/profile
cat /etc/profile

cd $LFS
		
}


lfs-install-kernel() {
    cd $LFS/setup
    tar xvf $PKGS/linux-5.8.3.tar.xz
    cd linux-5.8.3
    make mrproper
    make menuconfig
    make
    make modules_install
    cp -iv arch/x86_64/boot/bzImage /boot/vmlinuz-5.8.3-lfs-10.0
    cp -iv System.map /boot/System.map-5.8.3
    install -d /usr/share/doc/linux-5.8.3
    cp -r Documentation/* /usr/share/doc/linux-5.8.3

    mkdir -pv /etc/modprobe.d
    install -v -m755 -d /etc/modprobe.d
    cat > /etc/modprobe.d/usb.conf << "EOF"  
#Begin /etc/modprobe.d/usb.conf  
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
#End /etc/modprobe.d/usb.conf
EOF
}

lfs-chroot-env
