# Toolchain
This folder contains the recipes for installing the complete pipeline from compiling, assembling, disassembling, binary 
manipulation and ROM flashing. The Makefile offers the following installation options:

## Generic install configuration options
All install recipes allow overriding the binary install directory, but often this requires root rights. By default,
programs are installed to ~/.local/bin unless stated otherwise. This path can be configured to somewhere else by 
prepending all make instructions below with `BIN_DIR=/path/to/your/bin/dir`

Also, by default the make recipes use the TMP dir to store retrieved source code files. This can also be overridden by
prepending install commands with `TMP=/path/to/your/tmp/dir`

## SREC
SREC is an easy to use tool useful for converting between assembled binaries and Motorola S-record files.

### Installation
From this directory, run:
```shell script
make srec-install
```

By default, the installation script installs to your ~/.local/bin dir so that the entire installation can be run without
root rights. Also: the entire install is now portable if your home folder is on a different partition.

### Usage
Once installed, you can call: 
- `srec2bin` to convert an S-record file to a binary file. See `srec2bin --help` for more detailed instructions.
- `bin2srec` to convert a binary file to an S-record. See `bin2srec --help` for more detailed instructions.
- `binsplit` to split a binary into even and odd bit files, for example to split a combined binary file into an odd and 
an even ROM file to flash to even and odd ROM chips.

## GCC cross-compiler
This tool is incredibly useful to write your own programs for the Motorola 68000 in more familiar languages (more 
familiar than Assembly, that is) such as C, C++, Objective-C or even Fortran or Go if you like. There's an 
[overview of supported languages](https://en.wikipedia.org/wiki/GNU_Compiler_Collection#Languages) from which you can 
choose your favorite. Note that most of these are untested for m68k targets though, but it would be very cool to see a
Go program compiled for m68k target.

### Installation
From this directory, run:
```shell script
make gcc-install
```

By default only C support is enabled in this install recipe, but you can override this setting by altering the 
GCC_LANGUAGES environment:
```shell script
GCC_LANGUAGES=c,go make gcc-install
```
Note, however, that the usage of cross-compiled languages other than C hasn't been tested. 

By default, the installation script installs to your ~/.local/bin dir so that the entire installation can be run without
root rights. Also: the entire install is now portable if your home folder is on a different partition. 

### Usage
Once installed, you can call 