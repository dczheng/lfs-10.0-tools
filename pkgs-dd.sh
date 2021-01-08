#!/bin/bash
url="http://mirrors.ustc.edu.cn/lfs/lfs-packages/10.0/"
for p in `cat pkgs-name`
do
    wget $url/$p --directory-prefix=./sources
done
