# Toolchain
This folder contains the recipes for installing the complete toolchain from compiling, assembling, disassembling and binary 
manipulation to ROM flashing. The Makefile offers the following installation options:

## Generic install configuration options
All install recipes allow overriding the binary install directory, but often this requires root rights. By default,
programs are installed to ~/.local/ unless stated otherwise. This makes the installation now portable, for example if
your home folder is on a different partition. The install path can be configured to point somewhere else by 
prepending all make instructions below with `INSTALL_DIR=/path/to/your/install/dir`, unless stated otherwise.

Also, by default the make recipes use the TMP dir to store retrieved source code files. This can also be overridden by
prepending install commands with `TMP=/path/to/your/tmp/dir`

## SREC
SREC is an easy to use tool useful for converting between assembled binaries and Motorola S-record files.

### Installation
From this directory, run:
```shell script
make srec-install
```

By default, the installation script installs to your ~/.local/ dir so that the entire installation can be run without
root rights. You can install to a different dir by prepending the make command with INSTALL_DIR=/path/to/your/install/dir.


### Uninstall
```shell script
make srec-uninstall
```

Note that you have to specify the same install dir if you specified a custom INSTALL_DIR during installation.

## SRecord
SRecord is (somewhat confusingly) a very elaborate set of tools useful for working with ROM files.

### Installation
S-record need to install libboost and libtool for your OS. On Debian-like systems this amounts to 
```shell script
sudo apt-get install -y libboost-dev libtool-bin ghostscript
```
but on other distributions you will require, yum, dnf or whatever package manager is available on your system. Note that
libtool-bin installs the required `libtool` executable, the one that the `configure` script for SRecord looks for. 
Oddly enough, this is executable is not in the `libtool` package, but in `libtool-bin`, at least not in recent Debian or
Debian-derivative distributions. The ghostscript package is required for building the documentation.

From this directory, run:
```shell script
make srecord-install
```

By default, the installation script installs to your ~/.local/ dir so that the entire installation can be run without
root rights. You can install to a different dir by prepending the make command with INSTALL_DIR=/path/to/your/install/dir.

### Uninstall
```shell script
make srecord-uninstall
```

### Usage
Once installed, you can call: 
- `srec2bin` to convert an S-record file to a binary file. See `srec2bin --help` for more detailed instructions.
- `bin2srec` to convert a binary file to an S-record. See `bin2srec --help` for more detailed instructions.
- `binsplit` to split a binary into even and odd bit files, for example to split a combined binary file into an odd and 
an even ROM file to flash to even and odd ROM chips.

## GCC cross-compiler
This tool is incredibly useful to write your own programs for the Motorola 68000 in more familiar languages (more 
familiar than Assembly, that is) such as C, C++, Objective-C or even Fortran if you like. There's an 
[overview of supported languages](https://en.wikipedia.org/wiki/GNU_Compiler_Collection#Languages) from which you can 
choose your favorite. Note that most of these are untested for m68k targets though, and bear in mind that any 
[garbage-collected language](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)) will come with a 
runtime that is almost guaranteed to exceed the memory limitations of the TS2 board. Your safest bet is on languages
that aren't garbage-collected, such as C and C++, and even then the ROM limitations of the TS2 are comparable with an
[Arduino Uno](https://www.arduino.cc/en/Main/arduinoBoardUno&gt;#techspecs). 

### Installation
From this directory, run:
```shell script
make gcc-install
```

By default only C support (a 'front end' in GCC terms) is enabled in this install recipe, but you can override this 
setting by using the GCC_LANGUAGES variable:
```shell script
GCC_LANGUAGES=c,c++ make gcc-install
```

By default, the installation script installs to your ~/.local/bin dir so that the entire installation can be run without
root rights. You can install to a different bin dir by prepending the make command with INSTALL_DIR=/path/to/your/bin/dir.

### Uninstall
```shell script
make gcc-uninstall
```

Note that you have to specify the same install dir if you specified a custom INSTALL_DIR during installation.

### Usage
Once installed, you can use `m68k-elf-gcc` to compile your own programs to run on m68k hardware! Compilation is done by
specifying the target processor. See the [Makefile](../c_example/Makefile) in the c_example dir on how to use it.