# Toolchain
This folder contains the recipes for installing the complete pipeline from compiling, assembling, disassembling, binary 
manipulation and ROM flashing. The Makefile offers the following installation options:

## SREC
SREC is an easy to use tool useful for converting between assembled binaries and Motorola S-record files.

### Installation
From this directory, run:
```shell script
make srec-install
```

### Usage
Once installed, you can call: 
- `srec2bin` to convert an S-record file to a binary file. See `srec2bin --help` for more detailed instructions.
- `bin2srec` to convert a binary file to an S-record. See `bin2srec --help` for more detailed instructions.
- `binsplit` to split a binary into even and odd bit files, for example to split a combined binary file into an odd and 
an even ROM file to flash to even and odd ROM chips.



