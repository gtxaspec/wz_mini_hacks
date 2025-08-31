#!/bin/bash

#set release date before generation
date +"%Y-%m-%d_%H:%M:%S" > SD_ROOT/wz_mini/usr/bin/app.ver

rm -f file.chk
find SD_ROOT/ -type f -exec md5sum "{}" + > file.chk

#Ignore demo.bin
find v2_install -type f ! -name "demo.bin" -exec md5sum "{}" + >> file.chk
