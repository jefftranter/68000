#!/bin/sh

# Native build
#gcc -Wall -o rpncalc rpncalc.c
#exit 0

# CC65 6502 build for C64
#CC65_HOME=/usr/local/share/cc65 cl65 -O -t c64 rpncalc.c -L /usr/local/share/cc65/lib
#exit 0

# CC65 6502 build for Apple 2
#CC65_HOME=/usr/local/share/cc65 cl65 -O -t apple2enh rpncalc.c -L /usr/local/share/cc65/lib
#exit 0

# Classic 68K Mac build
rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=${HOME}/git/Retro68/build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake
make
#cp Rpncalc.dsk /media/tranter/218E-8984/retro68/
#umount /media/tranter/218E-8984
