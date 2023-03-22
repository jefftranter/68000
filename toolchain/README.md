This folder contains a script for downloading, building, and
installing the complete toolchain from compiling, assembling,
disassembling and binary manipulation to ROM flashing. The script,
build.sh, is intended to run on a desktop Linux computer and can be
adapted as needed.

It includes the following:

## SREC

SREC is an easy to use tool useful for converting between assembled
binaries and Motorola S-record files. Once installed, you can call:
- srec2bin to convert an S-record file to a binary file. See srec2bin
  --help for more detailed instructions.
- bin2srec to convert a binary file to an S-record. See bin2srec
  --help for more detailed instructions.
- binsplit to split a binary into even and odd bit files, for example
  to split a combined binary file into an odd and an even ROM file to
  flash to even and odd ROM chips.

## GCC cross-compiler

This tool is incredibly useful to write your own programs for the
Motorola 68000 in more familiar languages (more familiar than
Assembly, that is) such as C, C++, Objective-C or even Fortran if you
like. There's an [overview of supported
languages](https://en.wikipedia.org/wiki/GNU_Compiler_Collection#Languages)
from which you can choose your favorite. Note that most of these are
untested for m68k targets though, and bear in mind that any
[garbage-collected
language](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
will come with a runtime that is almost guaranteed to exceed the
memory limitations of the TS2 board. Your safest bet is on languages
that aren't garbage-collected, such as C and C++, and even then the
ROM limitations of the TS2 are comparable with an [Arduino
Uno](https://www.arduino.cc/en/Main/arduinoBoardUno&gt;#techspecs).

By default only C support (a 'front end' in GCC terms) is enabled in
this install recipe.

Once installed, you can use m68k-elf-gcc to compile your own programs
to run on m68k hardware! Compilation is done by specifying the target
processor. See the [Makefile](../c_example/Makefile) in the c_example
dir on how to use it.

## Newlib

[Newlib](https://sourceware.org/newlib/) is a library that provides a
C standard library where there is no operating system present that can
provide such a library. Normally, you would compile programs on an OS
like Linux that provides libc out of the box. However, the TS2 Tutor
environment is nowhere near fully-fledged operating system. Newlib
therefore provides vital functionality in minimal environments, such
as the TS2.

Once installed, you can use libc-like standard library functions in your C programs:
 - see [their standard library documentation](https://sourceware.org/newlib/libc.html) 
 - see [their math library documentation](https://sourceware.org/newlib/libm.html)

It's difficult to overstate the usefulness of these libraries. Now,
you can do sines, cosines, powers, roots, quicksorts, random numbers
and all the other goodness that comes with libc. For more usage
instructions, see the [newlib README](newlib/README.md)

## Assembler

Besides the GCC m68k-elf assembler m68k-elf-as there is also a
stand-alone 68k assembler available in VASM. The benefit of having
this assembler is that it is extremely compact to download, build and
install.

See [instructions](http://sun.hasenbraten.de/vasm/index.php?view=tutorial)

## Disassembler

The toolchain includes a disassembler written in Python.
See [instructions](disasm/README.md)
