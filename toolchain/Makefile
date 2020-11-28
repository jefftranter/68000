# directory to save source files into
TMP ?= /tmp
BIN_DIR ?= ${HOME}/.local/bin

SREC_VER ?= 151
SREC_BUILD ?= ${HOME}/.srec

srec-install:
	$(if $(shell which unzip), echo "unzip found", $(error "please install unzip"))
	@wget http://www.goffart.co.uk/s-record/download/srec_${SREC_VER}_src.zip -O ${TMP}/srec.zip
	@mkdir -p ${SREC_BUILD}
	@unzip ${TMP}/srec.zip -d ${SREC_BUILD}
	${MAKE} -C ${SREC_BUILD}
	@mkdir -p ${BIN_DIR}
	mv ${SREC_BUILD}/bin2srec ${BIN_DIR}/
	mv ${SREC_BUILD}/srec2bin ${BIN_DIR}/
	mv ${SREC_BUILD}/binsplit ${BIN_DIR}/
	rm ${TMP}/srec.zip
	rm -r ${SREC_BUILD}
	@echo You can now use "bin2srec", "srec2bin" and "binsplit" if ${BIN_DIR}

srec-uninstall:
	@$(if $(shell ls ${BIN_DIR} | grep bin2srec), echo "removing srec binaries", $(error "srec binaries not found in ${BIN_DIR}"))
	rm ${BIN_DIR}/bin2srec
	rm ${BIN_DIR}/srec2bin
	rm ${BIN_DIR}/binsplit

# gcc version to build
GCC_VER ?= 5.4.0
GCC_SRC := ${TMP}/gcc-${GCC_VER}
GCC_BUILD := ${HOME}/.gcc-build
GCC_INSTALL_DIR ?= ${BIN_DIR}/..
GCC_LANGUAGES ?= "c"

gcc-install:
	wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz -O ${TMP}/gcc.tar.gz
	@echo "*** Extracting gcc source ***"
	@tar xzf ${TMP}/gcc.tar.gz --directory ${TMP}
	@echo "*** Removing downloaded archive ***"
	@rm -r ${TMP}/gcc.tar.gz
	@echo "*** Downloading compile dependencies ***"
	cd ${GCC_SRC} && contrib/download_prerequisites
	@echo "*** Configuring gcc ***"
	mkdir -p ${GCC_BUILD}
	cd ${GCC_BUILD} && ${GCC_SRC}/configure \
		-q \
		--prefix=${GCC_INSTALL_DIR} \
		--target=m68k-elf \
		--enable-languages=${GCC_LANGUAGES} \
		--disable-libssp \
		--disable-nls \
		--disable-multilib
	@echo "*** Building gcc ***"
	@make all-gcc -s -j4 -C ${GCC_BUILD}
	@echo "*** Installing gcc ***"
	@make install-gcc -C ${GCC_BUILD}
	@echo "*** Removing build directory ***"
	@rm -r ${GCC_BUILD}
	@echo "*** Run cross-compilation test ***"
	@${MAKE} demo.s -C ../c_example
	@${MAKE} clean -C ../c_example

gcc-uninstall:
	@$(if $(shell which m68k-elf-gcc), echo "Removing gcc cross compiler", $(error "gcc cross-compiler not found"))
	rm ${GCC_INSTALL_DIR}/bin/m68k-elf-g*
	rm ${GCC_INSTALL_DIR}/bin/m68k-elf-cpp
	rm -r ${GCC_INSTALL_DIR}/lib/gcc
	rm -r ${GCC_INSTALL_DIR}/libexec/gcc
	rm ${GCC_INSTALL_DIR}/share/man/man1/m68-elf-cpp.1
	rm ${GCC_INSTALL_DIR}/share/man/man1/m68-elf-gcc.1
	rm ${GCC_INSTALL_DIR}/share/man/man1/m68-elf-gcov.1

MINIPRO_VER ?= 0.5
MINIPRO_DIR ?= ~/.local/minipro

minipro-install:
	@wget https://gitlab.com/DavidGriffith/minipro/-/archive/${MINIPRO_VER}/minipro-${MINIPRO_VER}.tar.gz -O ${TMP}/minipro.tar.gz
	@mkdir -p ${MINIPRO_DIR}
	@tar xvzf ${TMP}/minipro.tar.gz --directory ${MINIPRO_DIR}
	@cd ${MINIPRO_DIR}/minipro-${MINIPRO_VER} && make && sudo make install
	minipro --version
	@sudo udevadm trigger
	@sudo usermod -a -G plugdev ${USER}
	@echo "You need to log out and in again for the rules for user access to the programmer over USB to take effect. \
			Or: you can run the make recipes for burning the ROMs as root with sudo: e.g. sudo make rom-odd"

VASM_DIR ?= ~/.local/vasm

vasm-install:
	echo "Installing VASM into ${VASM_DIR}"
	mkdir -p ${VASM_DIR}
	wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz -O ${VASM_DIR}/vasm.tar.gz
	tar xvzf ${VASM_DIR}/vasm.tar.gz --directory ${VASM_DIR}/..
	make -C ${VASM_DIR} CPU=m68k SYNTAX=mot
	cp ~/.local/vasm/vasmm68k_mot ${BIN_DIR}/
	echo "Vasm m68k assembler successfully installed, you can call it using 'vasmm68k_mot'"
