These files were originally downloaded from:

http://home.hccnet.nl/a.w.m.van.der.horst/forthimpl.html
http://home.hccnet.nl/a.w.m.van.der.horst/fig68k.zip
http://home.hccnet.nl/a.w.m.van.der.horst/figdoc.zip

It runs on my TS2 680000-based single board computer. I made one small
source change and added a Makefile to build it using the VASM
cross-assembler. It loads into RAM and the start address is $3648.

------------------------------------------------------------------------

Distribution by HCC-FORTH-GG     1994 nov 10

F68K.ASM        68000 assembler source listing for FIG Forth
F68K.WS         Documentation in Wordstar format
F68K.DOC        ASCII version of F68K.WS, such as printed
F68K.TXT        ASCII version of F68K.WS, printable on screen
README.TXT      This file

Using this with a cross assembler and an eprom programmer is still
a viable way to bring up a small Forth system.
Note that the FIG standard has been superseeded by F79, F83 and ANSI.
What has survived is the FIG implementation model, where you start
with an assembly source listing, not assuming any Forth tools
available.
A print out of this once was available from our user group and a
fotocopy kan still be had from me.
You kan reach me on the Forth gg board 085-422164
(From abroad 31-85-422164)

                                Albert van der Horst
                                HCC-FORTH-GG
