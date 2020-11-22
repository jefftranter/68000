# gcc version to build
GCC_VER=5.4.0
# directory to save source files into
TMP := /tmp
GCC_SRC := ${TMP}/gcc-${GCC_VER}
GCC_BUILD := ${HOME}/.gcc-build
GCC_INSTALL := ${HOME}/gcc-elf-m68k-${GCC_VER}

all:	tutor13.run tutor13.bin tutor13.hex tutor13_even.bin tutor13_odd.bin

gcc-install:
	wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz -O ${GCC_SRC}.tar.gz
	@echo "*** Extracting gcc source ***"
	cd ${TMP} && tar xzf gcc-${GCC_VER}.tar.gz
	@echo "*** Downloading compile dependencies ***"
	cd ${GCC_SRC} && contrib/download_prerequisites
	@echo "*** Configuring gcc ***"
	mkdir -p ${GCC_BUILD}
	cd ${GCC_BUILD} && ${GCC_SRC}/configure \
		-q \
		--prefix=${GCC_INSTALL} \
		--target=m68k-elf \
		--enable-languages=c \
		--disable-libssp \
		--disable-nls \
		--disable-multilib
	@echo "*** Building gcc ***"
	cd ${GCC_BUILD} && make all-gcc -s -j4
	@echo "*** Installing gcc ***"
	cd ${GCC_BUILD} && sudo make install-gcc

minipro-install:
ifeq ($(pkg-config --version && $(dpkg -l | grep libusb-1.0)), 0)
	wget https://gitlab.com/DavidGriffith/minipro/-/archive/0.5/minipro-0.5.tar.gz -O /tmp/minipro-0.5.tar.gz
	tar xvzf minipro-0.5.tar.gz
	cd minipro-0.5 && make && ./minipro --version
	sudo cp minipro-0.5/udev/*.rules /etc/udev/rules.d/
	sudo udevadm trigger
	sudo usermod -a -G plugdev ${USER}
	@echo "You need to log out and in again for the rules to take effect. Or: you can run the make recipes for burning the ROMs as root with sudo."
else
	@echo "pkg-config and libusb-1.0 are required; install with sudo apt-get install pkg-config libusb-1.0"; exit 1
endif

rom-odd: minipro-0.5/minipro
ifeq ($(minipro-0.5/minipro --devices), 0)
	@# Method from https://www.linuxquestions.org/questions/linux-general-1/linux-command-to-copy-every-other-byte-from-file-708566/#post3462413
	@# We need two $$ signs to escape to a single $ in Makefile
	od -w2 -t u1 -v tutor13.bin | awk ' { printf("%c", strtonum($$2)) } ' > tutor13_odd.bin
	minipro --write tutor13_odd.bin
else
	@echo "No minipro device detected, please connect one"; exit 1
endif

rom-even: minipro-0.5/minipro
ifeq ($(minipro-0.5/minipro --devices), 0)
	od -w2 -t u1 -v tutor13.bin | awk ' { printf("%c", strtonum($$3)) } ' > tutor13_even.bin
	minipro --write tutor13_even.bin
else
	@echo "No minipro device detected, please connect one"; exit 1
endif

tutor13.o: tutor13.s
	m68k-elf-as -m68000 -alms -a=tutor13.lst -o tutor13.o tutor13.s

tutor13.run: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O srec tutor13.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -Output_Block_Size 16 -o tutor13.run
	srec_cat tutor13.run -split 2 0 -offset 0x4000 -o tutor13_even.run
	srec_cat tutor13.run -split 2 1 -offset 0x4000 -o tutor13_odd.run
	$(RM) temp

tutor13.bin: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O binary tutor13.o tutor13.bin

tutor13.hex: tutor13.run
	srec_cat tutor13.run -Motorola -output tutor13.hex -Intel

tutor13_even.bin: tutor13_even.run
	srec_cat tutor13_even.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_even.bin -Binary

tutor13_odd.bin: tutor13_odd.run
	srec_cat tutor13_odd.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_odd.bin -Binary

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin tutor13.hex
	$(RM) tutor13_even.run tutor13_odd.run
	$(RM) tutor13_even.bin tutor13_odd.bin
