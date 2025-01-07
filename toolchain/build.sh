#!/bin/sh

# Script to build toolchain for TS2. Adapt as needed for your
# environment. Tested on Ubuntu Linux.

# Set components to build here.
BUILD_SREC=1
BUILD_DISASM=1
BUILD_VASM=1
BUILD_MINIPRO=1
BUILD_BINUTILS=1
BUILD_GCC=1
BUILD_NEWLIB=0
BUILD_NEWLIB_NANO=1

# Enable to first remove any existing install
UNINSTALL=0

# Set versions to use here.
SREC_VER=151
MINIPRO_VER=0.7
NEWLIB_VER=4.5.0.20241231
BINUTILS_VER=2.43
GCC_VER=14.2.0

if [ "${UNINSTALL}" = 1 ]
then
sudo rm -rf /usr/local/m68k/elf
sudo rm -rf /usr/local/bin/m68k-elf*
sudo rm -rf /usr/local/bin/minipro
sudo rm -rf /usr/local/bin/miniprohex
sudo rm -rf /usr/local/bin/vasmm68k_mot
sudo rm -rf /usr/local/bin/vobjdump
sudo rm -rf /usr/local/bin/disasm68k.py
sudo rm -rf /usr/local/bin/bin2srec
sudo rm -rf /usr/local/bin/binsplit
sudo rm -rf /usr/local/bin/srec2bin
sudo rm -rf /usr/local/lib/libcc1*
fi

# Build S record utilities
if [ "${BUILD_SREC}" = 1 ]
then
echo "Building S record utilities"
if [ ! -f srec_${SREC_VER}_src.zip ]
then
  wget http://www.goffart.co.uk/s-record/download/srec_${SREC_VER}_src.zip
fi
mkdir srec
cd srec
unzip ../srec_${SREC_VER}_src.zip
make -s -j4
sudo mv bin2srec srec2bin binsplit /usr/local/bin
cd ..
rm -rf srec
#rm srec_${SREC_VER}_src.zip
fi

# Build disasm
if [ "${BUILD_DISASM}" = 1 ]
then
echo "Building diasm"
sudo cp disasm/disasm68k.py /usr/local/bin
fi

# Build vasm
if [ "${BUILD_VASM}" = 1 ]
then
echo "Building vasm"
if [ ! -f vasm.tar.gz ]
then
  wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
fi
tar xzf vasm.tar.gz
cd vasm
make -s -j4 CPU=m68k SYNTAX=mot
sudo cp vasmm68k_mot vobjdump /usr/local/bin
cd ..
rm -rf vasm
#rm vasm.tar.gz
fi

# Build minipro
if [ "${BUILD_MINIPRO}" = 1 ]
then
echo "Building minipro"
if [ ! -f minipro-${MINIPRO_VER}.tar.gz ]
then
  wget https://gitlab.com/DavidGriffith/minipro/-/archive/${MINIPRO_VER}/minipro-${MINIPRO_VER}.tar.gz
fi
tar xzf minipro-${MINIPRO_VER}.tar.gz
cd minipro-${MINIPRO_VER}
make -s -j4
sudo make install
cd ..
rm -rf minipro-${MINIPRO_VER}
#rm minipro-${MINIPRO_VER}.tar.gz
fi

# Build binutils
if [ "${BUILD_BINUTILS}" = 1 ]
then
echo "Building binutils"
if [ ! -f binutils-${BINUTILS_VER}.tar.xz ]
then
  wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz
fi
tar xf binutils-${BINUTILS_VER}.tar.xz
cd binutils-${BINUTILS_VER}
./configure --with-cpu=68000 --target=m68k-elf --with-newlib --disable-plugins --disable-werror --enable-tui --disable-nls
make -s -j4
sudo make install
cd ..
rm -rf binutils-${BINUTILS_VER}
#rm binutils-${BINUTILS_VER}.tar.xz
fi

# Build gcc
if [ "${BUILD_GCC}" = 1 ]
then
echo "Building gcc"
if [ ! -f gcc-${GCC_VER}.tar.gz ]
then
  wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz
fi
tar xf gcc-${GCC_VER}.tar.gz
cd gcc-${GCC_VER}
mkdir objdir
cd objdir
../configure --with-cpu=68000 --enable-libgcc-rebuild --target=m68k-elf --enable-languages=c --disable-libssp --disable-nls --disable-multilib
make -s -j4
sudo make install
cd ../..
rm -rf gcc-${GCC_VER}
#rm gcc-${GCC_VER}.tar.gz
fi

# Build newlib
if [ "${BUILD_NEWLIB}" = 1 ]
then
echo "Building newlib"
if [ ! -f newlib-${NEWLIB_VER}.tar.gz ]
then
  wget ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz
fi
tar xzf newlib-${NEWLIB_VER}.tar.gz
cd newlib-${NEWLIB_VER}
cp ../newlib/patches/* libgloss/m68k
./configure --with-cpu=68000 --target=m68k-elf --enable-newlib-nano-formatted-io --enable-newlib-nano-malloc --enable-lite-exit --disable-libssp --disable-nls --disable-multilib
make -s -j4
sudo make install
cd ..
rm -rf newlib-${NEWLIB_VER}
#rm newlib-${NEWLIB_VER}.tar.gz
fi

if [ "${BUILD_NEWLIB_NANO}" = 1 ]
then
  git clone https://github.com/32bitmicro/newlib-nano-1.0.git
  cd newlib-nano-1.0
  chmod a+x configure
  cp ../newlib/patches/* libgloss/m68k
  ./configure --with-cpu=68000 --target=m68k-elf --enable-newlib-nano-formatted-io --enable-newlib-nano-malloc --enable-lite-exit --disable-libssp --disable-nls --disable-multilib
  make -s -j4
  sudo make install
  cd ..
  rm -rf newlib-nano-1.0
fi

echo "Done"
