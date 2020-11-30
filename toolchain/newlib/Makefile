TMP ?= /tmp
SRC_DIR ?= ${TMP}/newlib
INSTALL_DIR ?= ${HOME}/.local
BUILD_DIR ?= ${HOME}/.local/newlib
BIN_DIR ?= ${INSTALL_DIR}/bin

NEWLIB_VER ?= 2.5.0

build:
	# Patch, build and install newlib
	@echo "*** Getting newlib ***"
	wget ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz -O ${TMP}/newlib.tar.gz

	@echo "*** Extracting newlib source ***"
	mkdir -p ${SRC_DIR}
	tar xzf ${TMP}/newlib.tar.gz --directory ${SRC_DIR}

	@echo "*** Patching newlib ***"
	cp patches/* ${SRC_DIR}/newlib-${NEWLIB_VER}/libgloss/m68k/

	@echo "*** Configuring newlib ***"
	mkdir -p ${BUILD_DIR}
	cd ${BUILD_DIR} && \
		${SRC_DIR}/newlib-${NEWLIB_VER}/configure -q \
			--prefix=${INSTALL_DIR} \
			--target=m68k-elf \
			--enable-newlib-nano-formatted-io \
			--enable-newlib-nano-malloc \
			--enable-lite-exit

	echo "*** Building newlib ***"
	make -C ${BUILD_DIR}

	echo "*** Clean up ***"
	rm ${TMP}/newlib.tar.gz

	@echo "*** Done ***"

install:
	@echo "*** Installing newlib ***"
	${MAKE} install -C ${BUILD_DIR}

	@echo "*** Removing temp files ***"
	rm -rf ${BUILD_DIR}
	rm -rf ${SRC_DIR}

	@echo "*** Done ***"
