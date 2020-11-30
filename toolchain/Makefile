# directory to save source files into
TMP ?= /tmp
INSTALL_DIR ?= ${HOME}/.local
BIN_DIR ?= ${INSTALL_DIR}/bin

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

SRECORD_VER ?= "1.64"
SRECORD_BUILD ?= ${HOME}/.srecord

srecord-install:
	@wget http://srecord.sourceforge.net/srecord-${SRECORD_VER}.tar.gz -O ${TMP}/srecord.tar.gz
	@mkdir -p ${SRECORD_BUILD}
	@tar xzf ${TMP}/srecord.tar.gz --directory ${SRECORD_BUILD}
	@rm ${TMP}/srecord.tar.gz
	@cd ${SRECORD_BUILD}/srecord-${SRECORD_VER} && \
		./configure \
			--prefix=${INSTALL_DIR} \
			--without-gcrypt
	${MAKE} -C ${SRECORD_BUILD}/srecord-${SRECORD_VER}
	${MAKE} install -C ${SRECORD_BUILD}/srecord-${SRECORD_VER}
	@echo "Checking correct installation"
	srec_cat --version

srecord-uninstall:
	@$(if $(shell ls ${BIN_DIR} | grep srec_cat), echo "removing SRecord", $(error "SRecord binaries not found in ${BIN_DIR}"))
	${MAKE} uninstall -C ${SRECORD_BUILD}/srecord-${SRECORD_VER}
	@rm -r ${SRECORD_BUILD}/srecord-${SRECORD_VER}


BINUTILS_VER ?= 2.35
BINUTILS_SRC := ${TMP}/binutils-${BINUTILS_VER}
GCC_VER ?= 5.4.0
GCC_SRC := ${TMP}/gcc-${GCC_VER}
GCC_BUILD := ${HOME}/.gcc-build
GCC_LANGUAGES ?= "c"

gcc-install:
	@# Cross-compiler binutils phase
	@echo "Installing cross-compiler binutils first, gcc is of little use without it"
	wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.gz -O ${TMP}/binutils.tar.gz
	@echo "*** Extracting binutils source ***"
	tar xzf ${TMP}/binutils.tar.gz --directory ${TMP}
	@echo "*** Removing downloaded archive ***"
	rm -r ${TMP}/binutils.tar.gz
	cd ${BINUTILS_SRC} && ./configure \
		--prefix=${INSTALL_DIR} \
		--target=m68k-elf \
		--with-newlib \
		--disable-plugins \
		--disable-werror \
		--enable-tui \
		--disable-nls
	${MAKE} -C ${BINUTILS_SRC}
	${MAKE} install -C ${BINUTILS_SRC}
	rm -rf ${BINUTILS_SRC}

	@# GCC install phase
	wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz -O ${TMP}/gcc.tar.gz
	@echo "*** Extracting gcc source ***"
	tar xzf ${TMP}/gcc.tar.gz --directory ${TMP}
	@echo "*** Downloading compile dependencies ***"
	cd ${GCC_SRC} && contrib/download_prerequisites
	@echo "*** Configuring gcc ***"
	mkdir -p ${GCC_BUILD}
	cd ${GCC_BUILD} && ${GCC_SRC}/configure \
		-q \
		--prefix=${INSTALL_DIR} \
		--enable-libgcc-rebuild \
		--target=m68k-elf \
		--enable-languages=${GCC_LANGUAGES} \
		--disable-libssp \
		--disable-nls \
		--disable-multilib
	@echo "*** Building gcc ***"
	${MAKE} all-gcc -s -j4 -C ${GCC_BUILD}
	@echo "*** Installing gcc ***"
	${MAKE} install-gcc -C ${GCC_BUILD}
	@echo "*** Installing libgcc ***"
	${MAKE} all-target-libgcc -C ${GCC_BUILD}
	${MAKE} install-target-libgcc -C ${GCC_BUILD}
	@echo "*** Run cross-compilation test ***"
	${MAKE} demo.run -C ../c_example
	${MAKE} clean -C ../c_example
	@echo "*** Cleaning up source files ***"
	rm -r ${GCC_SRC}
	rm -r ${TMP}/gcc.tar.gz
	@echo "*** Done ***"

gcc-uninstall:
	@$(if $(shell which m68k-elf-gcc), echo "Removing gcc cross compiler", $(error "gcc cross-compiler not found"))
	@echo "Removing binutils"
	rm -r ${INSTALL_DIR}/m68k-elf

	@echo "Removing gcc"
	@echo "*** Removing build directory ***"
	rm -rf ${GCC_BUILD}
	@echo "*** Removing binary executables ***"
	rm ${INSTALL_DIR}/bin/m68k-elf-*
	rm -r ${INSTALL_DIR}/lib/gcc
	rm -r ${INSTALL_DIR}/libexec/gcc
	rm ${INSTALL_DIR}/share/man/man1/m68k-elf-cpp.1
	rm ${INSTALL_DIR}/share/man/man1/m68k-elf-gcc.1
	rm ${INSTALL_DIR}/share/man/man1/m68k-elf-gcov.1
	@echo "*** Done ***"

NEWLIB_VER ?= 2.5.0

newlib-install:
	NEWLIB_VER=${NEWLIB_VER} ${MAKE} -C newlib/ && ${MAKE} install -C newlib/

MINIPRO_VER ?= 0.5
MINIPRO_DIR ?= ~/.local/minipro

minipro-install:
	wget https://gitlab.com/DavidGriffith/minipro/-/archive/${MINIPRO_VER}/minipro-${MINIPRO_VER}.tar.gz -O ${TMP}/minipro.tar.gz
	mkdir -p ${MINIPRO_DIR}
	tar xzf ${TMP}/minipro.tar.gz --directory ${MINIPRO_DIR}
	${MAKE} -C ${MINIPRO_DIR}/minipro-${MINIPRO_VER}
	@echo Minipro requires a priviledged install to have proper access to the USB ports and the supported chip list
	sudo ${MAKE} install
	minipro --version
	sudo udevadm trigger
	sudo usermod -a -G plugdev ${USER}
	@echo "*** Done ***"
	@echo "You need to log out and in again for the rules for user access to the programmer over USB to take effect. \
			Or: you can run the make recipes for burning the ROMs as root with sudo: e.g. sudo make rom-odd"

# Minor versions are separated using underscores for downloads, so version 1.8i becomes 1_8i
VASM_VER ?= 1_8i
BUILD_DIR ?= ~/.local/vasm

vasm-install:
	@echo " *** Installing VASM ***"
	mkdir -p ${BUILD_DIR}
	wget http://phoenix.owl.de/tags/vasm${VASM_VER}.tar.gz -O ${BUILD_DIR}/vasm.tar.gz
	tar xzf ${BUILD_DIR}/vasm.tar.gz --directory ${BUILD_DIR}/..
	make -C ${BUILD_DIR} CPU=m68k SYNTAX=mot
	cp ~/.local/vasm/vasmm68k_mot ${BIN_DIR}/
	@echo "*** Done ***"
	@echo "Vasm m68k assembler successfully installed, you can call it using 'vasmm68k_mot'"
