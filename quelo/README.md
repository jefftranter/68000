This is an example of cross-compiling 68000 code using the Quelo
assembler, circa 1984. The code will run on the Motorola ECB or my TS2
68000 single board computer.

The Quelo assembler was downloaded from
http://www.retro.co.za/68000/quelo.html. Get the file QUELOASM.ZIP.
You should unzip it to get the tools. The only files that are needed
to build the example are A68K.EXE, QLINK.EXE, and QSYM.EXE. There is
also a link on that site to a PDF of the full assembler user's manual.

The example is based on Laboratory 4 from the book "68000
Microcomputer Experiments, Using the Motorola Educational Computer
Board" by Alan D. Wilcox.

The example builds under Linux using dosbox, an MS-DOS emulator. It is
available for most Linux distributions, such as Ubuntu.

Description of files:

README.md - this file.

Makefile - A make file to build the code and generate an S record file
for uploading to the ECB or TS2 computer. It runs dosbox and assumes
that the Quelo assembler programs are in the same directory. If you
want to run the commands manually (e.g. to see any errors), you can
run from dosbox:

    A68K PROG1 -SXE

    QLINK PROG1 -SX

    QSYM PROG1

PROG1.A68 - The assembly language source code for the example.

PROG1.LNK - The link file needed by the Quelo tools to link.

Generated files:

PROG1.LTX - Object code output of the assembler.
PROG1.PRN - Assembly listing output of the assembler.
PROG1.SYM - Symbol listing output of the assembler.

PROG1.LST - Linker listing output of the linker.
PROG1.HEX - Motorol hex (S record) output file from the linker.

PROG1.RPT - Symbol table report from the qsym program.

When run from address 900 the program should produce the output "Hi
There" and return to TUTOR. Here is a sample run:

TUTOR  1.3 > LO1

S00E0000433A50524F47312E484558F8

S11B09004BF9000010004DF9000010081E3C00E34E4E1E3C00E44E4E76

S10B100048692054686572651B

S9030000FC

TUTOR  1.3 > GO 900

PHYSICAL ADDRESS=00000900

Hi There

TUTOR  1.3 > MD 900 20 ;DI

000900    4BF900001000         LEA.L   $00001000,A5 

000906    4DF900001008         LEA.L   $00001008,A6 

00090C    1E3C00E3             MOVE.B  #227,D7 

000910    4E4E                 TRAP    #14 

000912    1E3C00E4             MOVE.B  #228,D7 

000916    4E4E                 TRAP    #14

TUTOR  1.3 > MD 1000

001000    48 69 20 54 68 65 72 65  00 0A 00 00 00 00 00 00  Hi There........
