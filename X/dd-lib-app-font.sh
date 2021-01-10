#!/bin/bash

mkdir lib
cd lib &&
grep -v '^#' ../lib.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/lib/ &&
md5sum -c ../lib.md5
cd ..

mkdir app
cd app &&
grep -v '^#' ../app.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/app/ &&
md5sum -c ../app.md5
cd ..

mkdir font
cd font &&
grep -v '^#' ../font.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/font/ &&
md5sum -c ../font.md5
cd ..

