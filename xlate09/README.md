Motorola 6809 to 68000 Assembly Language Source Translator
==========================================================

In 1986, Motorola offered a tool to help programmers port their code
from the 6809 to 68000 microprocessor. The tool, written in Pascal,
was intended to do about 90% of the work of translation.

Included here are some sample files and instructions on how to run
this tool, which is now mostly of historical interest.

I originally downloaded the code from
http://www.retro.co.za/68000/XLATE09/

A number of modifications were made to the original files:

I was able to compile the tool using the Free Pascal compiler under
Linux with the addition of one line: "Uses Crt;". I made a few other
changes to remove warnings about unused variables.

The data files used by the program needed to be renamed to lower case
as Linux is case sensitive. I renamed all the files to all lower case.

I removed some Control-Z characters from some of the files. This
character indicated the end of file back in the days of MS-DOS, but
nowadays can cause some problems.

Included here is the following:

A 6809 test file which can be converted to 68000 code using the tool.

The original trans09.com executable will run under Linux the dosbox
MS-DOS emulator on Linux. It may also run on Windows, I have not tried
it.

The Pascal source can be compiled to generate a Linux executable which
will run. The data files must be in the same same directory where the
tool is run.

The supplied make file will build the tool under Linux and run the demo
under dosbox and under Linux.

Under Ubuntu Linux, dosbox is available in the package "dosbox" and
the Free Pascal compiler in the package "fp-compiler".

To actually use this tool you may need to modify it and/or the data
files to work with your particular 68000 cross-assembler. For example,
the VASM assembler I use does not like the stub routine names starting
with two dots like "..RTS" but will accept them with only one dot
(e.g. ".RTS").

Description of files:

README.md - This file.

Makefile - make file for building code and running examples.

xlate09.arc - The original download archive of files. Under Linux, the "arc" program can extract the files.

readme.txt - The original README file for the package.

manual.txt - The full manual for the tool.

trans09.com - An MS-DOS executable for the tool.

trans09.pas - Pascal source code for the tool.

codes.dbb - Table 1 data file used by the program.

codes2.dbb - Table 2 data file used by the program.

stubxref.dbb - Stub XREF source file used by the program.

example.09 - Example 6809 source code.

stub09.txt - Source code for stubs that can be referenced in the generated code (see the manual).

testfile.asc - A larger 6809 test file that can be used to test the tool.

Generated files:

trans09 - The Linux executable (compiled using Free Pascal).

example.68 - Converted output of the tool when run with example.09 as input.

testfile.out - Converted output of the tool when run with testfile.asc as input.

error.txt - Error output from the trans09 program.
