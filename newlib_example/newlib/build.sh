#!/bin/sh

# Build versions of gcc and newlib that will work with the TS2 single
# board computer.

set -e

# Set to 1 to build gcc.
BUILD_GCC=1

# Set to 1 to build newlib.
BUILD_NEWLIB=1

# GCC version to use.
GCC_VER=5.4.0

# Newlib version to use.
NEWLIB_VER=2.5.0

if [ "$BUILD_GCC" -eq "1" ]
then

# Get gcc.
if [ ! -f gcc-${GCC_VER}.tar.gz ]
then
   echo "*** Getting gcc ***"
   wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz
fi

# Build and install gcc
echo "*** BUILDING GCC ***"

echo "*** Removing old build ***"
rm -rf gcc-${GCC_VER} gcc-build

echo "*** Extracting gcc source ***"
tar xzf gcc-${GCC_VER}.tar.gz
mkdir gcc-build
echo "*** Configuring gcc ***"
cd gcc-build
../gcc-${GCC_VER}/configure -q --target=m68k-elf --enable-languages=c --disable-libssp

echo "*** Building gcc ***"
make -s -j4

echo "*** Installing gcc ***"
sudo make -s install
cd ..

fi

if [ "$BUILD_NEWLIB" -eq "1" ]
then

# Patch, build and install newlib
echo "*** BUILDING NEWLIB ***"

# Get newlib.
if [ ! -f newlib-${NEWLIB_VER}.tar.gz ]
then
   echo "*** Getting newlib ***"
   wget ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz
fi

echo "*** Building newlib ***"

echo "*** Removing old build ***"
rm -rf newlib-${NEWLIB_VER} m68k-elf-none

echo "*** Extracting newlib source ***"
tar xzf newlib-${NEWLIB_VER}.tar.gz

echo "*** Patching newlib ***"
cd patches
for file in crt0.S Makefile.in ts2.ld tutor.h tutor.S
do
  cp $file ../newlib-${NEWLIB_VER}/libgloss/m68k/$file
done
cd ..

echo "*** Configuring newlib ***"
mkdir m68k-elf-none
cd m68k-elf-none
../newlib-${NEWLIB_VER}/configure -q --target=m68k-elf --enable-newlib-nano-formatted-io --enable-newlib-nano-malloc --enable-lite-exit

echo "*** Building newlib ***"
make -s -j4

echo "*** Installing newlib ***"
sudo make -s install
cd ..

fi

echo "*** Done ***"
