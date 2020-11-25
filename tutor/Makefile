# directory to save source files into
TMP ?= /tmp

SREC_VER := 151
SREC_BUILD := ${HOME}/.srec
SREC_FOUND := 		"You can now use bin2srec, srec2bin and binsplit from the command line."
SREC_NOT_FOUND := 	"bin2srec, srec2bin and binsplit are in ~/.local/bin but this folder isn't in your PATH, please \
					add it: see https://www.howtogeek.com/658904/how-to-add-a-directory-to-your-path-in-linux/."

srec-install:
	$(if $(shell which unzip), echo "unzip found", $(error "please install unzip"))
	@wget http://www.goffart.co.uk/s-record/download/srec_${SREC_VER}_src.zip -O ${TMP}/srec.zip
	@mkdir -p ${SREC_BUILD}
	@unzip ${TMP}/srec.zip -d ${SREC_BUILD}
	${MAKE} -C ${SREC_BUILD}
	@mkdir -p ~/.local/bin
	mv ${SREC_BUILD}/bin2srec ~/.local/bin/
	mv ${SREC_BUILD}/srec2bin ~/.local/bin/
	mv ${SREC_BUILD}/binsplit ~/.local/bin/
	rm ${TMP}/srec.zip
	rm -r ${SREC_BUILD}
	@echo You can now use "bin2srec", "srec2bin" and "binsplit" from your ~/.local/bin

# gcc version to build
GCC_VER := 5.4.0
GCC_SRC := ${TMP}/gcc-${GCC_VER}
GCC_BUILD := ${HOME}/.gcc-build
GCC_INSTALL := ${HOME}/.local

gcc-install:
	wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz -O ${TMP}/gcc.tar.gz
	@echo "*** Extracting gcc source ***"
	cd ${TMP} && tar xzf gcc.tar.gz
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

MINIPRO_VER := 0.5
MINIPRO_BUILD := ~/.local/minipro

# Capture output from stderr from minipro to see whether the device is connected
# CONNECTED := "$(shell minipro-0.5/minipro --presence_check 2>&1)"

minipro-install:
	@wget https://gitlab.com/DavidGriffith/minipro/-/archive/${MINIPRO_VER}/minipro-${MINIPRO_VER}.tar.gz -O ${TMP}/minipro.tar.gz
	@mkdir -p ${MINIPRO_BUILD}
	@tar xvzf ${TMP}/minipro.tar.gz --directory ${MINIPRO_BUILD}
	@cd ${MINIPRO_BUILD}/minipro-${MINIPRO_VER} && make && sudo make install
	minipro --version
	@sudo udevadm trigger
	@sudo usermod -a -G plugdev ${USER}
	@echo "You need to log out and in again for the rules for user access to the programmer over USB to take effect. \
			Or: you can run the make recipes for burning the ROMs as root with sudo: e.g. sudo make rom-odd"

rom-odd:
ifeq ($(CONNECTED), "[No programmer found]")
	@echo "No minipro device detected, please connect one"; exit 1
else
	minipro --write=tutor13_odd.bin --device=28C64B
endif

rom-even:
ifeq ($(CONNECTED), "[No programmer found]")
	@echo "No minipro device detected, please connect one"; exit 1
else
	minipro --write=tutor13_even.bin --device=28C64B
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

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin tutor13.hex
	$(RM) tutor13_even.run tutor13_odd.run
