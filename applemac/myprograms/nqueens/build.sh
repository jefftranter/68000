#!/bin/sh

mkdir -p build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=/home/tranter/git/Retro68/build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake
make
