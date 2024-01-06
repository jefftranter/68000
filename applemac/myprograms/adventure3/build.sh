#!/bin/sh

rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=${HOME}/git/Retro68/build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake
make
#cp Adventure3.dsk /media/tranter/218E-8984/retro68/
#umount /media/tranter/218E-8984
