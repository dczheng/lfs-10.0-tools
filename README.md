# LFS-10.0 Compilation Tools

**Edit lfs.sh and lfs-chroot.sh**
> Set Environment Varibles:  
> LFS, PKGS, LFS_TOOLS, MKOPT, LFS_TGT  
> LFS_BUILD_DIR{1,2,3}, CHROOT_LFS_BUILD_DIR2

**Host System Requirements**
> Comparing the Output of `$LFS_TOOLS/version-check.sh` with "http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html" 

**Download all Packages**
> `wget --input-file=$LFS_TOOLS/wget-list --continue --directory-prefix=$PKGS`

**Initialize Compilation Environment**
> `source lfs.sh`   
> `lfs-build-init`   

**Compilling a Cross-Toolchain**
> `lfs-build1`  

**Cross Compilling Temporary Tools**
> `lfs-build2` 

**Entering Chroot and Building Additional Temporary Tools**
> `lfs-chroot`  
> `source $LFS_TOOLS/lfs-chroot.sh`  
> `lfs-chroot-init`  
> `source $LFS_TOOLS/lfs-chroot.sh`  
> `lfs-chroot-build2`  
> `lfs-clean-after-build2` 

**Building the LFS System**
> ***Installing Basic System Software***
>> `lfs-build3-1`  
>> `lfs-build3-2`  
>> `lfs-build3-3`    
>> `lfs-clean-after-build3`  
>>  exit chroot
>> 
>***System Configuration***
>> 
>> `source $LFS_TOOLS/lfs.sh`  
>> `lfs-chroot2`  
>> edit lfs-setup function in $LFS_TOOLS/lfs-chroot.sh    
>> `source $LFS_TOOLS/lfs-chroot.sh`  
>> `lfs-setup`  

**Making the LFS System Bootable**
>***Compilling Kernel***  
>>  `lfs-install-kernel`
>>
> ***Useing GRUB to Set Up the Boot Process***
>> 
>>    menuentry "GNU/Linux, Linux 5.8.3-lfs-10.0" {   
>>        insmod ext2  
>>        set root=(hd0,X) or set root="hd0,gptX"  
>>        linux /boot/vmlinuz-5.8.3-lfs-10.0 root=/dev/sdaX ro  
>>    }
