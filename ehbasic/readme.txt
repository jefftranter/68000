This is a port of Lee Davison's Enhanced Basic for 68000 to my TS2
single board computer. 

It should be assembled using the VASM retargetable assembler. It can
be loaded into RAM and started from address $0800 or built to run
from EPROM at $C000.

The following notes may be useful when porting programs written for
other Basic language dialects:

Keywords must be in all uppercase, but variable names can be upper or
lowercase and variables that different in case only (e.g. "X" and "x")
are considered distinct. The first three letters of variable names are
used to determine if the variables are unique.

The RND() function has different behavior from Microsoft-derived
Basics. You can read the documentation for details, but essentially,
if you want a series of random numbers you should call RND(0). Most
programs written for other Basic dialects typically call RND(1).

While most Microsoft-derived Basics assume an array size of 10 if you
don't specify otherwise, you need to explicitly specify the size of
arrays using the DIM statement.

By default, using the value of a variable that has not been
initialized will generate an Undefined Variable error. You can change
this to make it more compatible with other basic dialects, using a
build time option (novar).

By default, an INPUT statement with an empty response will cause the
program to break. This can be changed using a build time option
(nobrk).

PRINT statements do not output any extra spaces between items. So, for
example,

  PRINT A";"B"

Will output "AB", whereas in many dialects of Basic it will be "A B".

It appears that a RETURN statement is not valid in some sittationsa,
such as when control flow leaves from inside a FOR/NEXT loop. The
following program will display "RETURN without GOSUB Error in line
210" when run:

10 GOSUB 100
20 STOP
100 FOR I = 1 TO 10
110 IF I = 3 THEN 200
120 NEXT I
130 RETURN
200 PRINT "HERE"
210 RETURN

In the 68000 version, the interrupt related commands (ON IRQ|NMI, IRQ
ON|OFF|CLEAR, NMI ON|OFF|CLEAR, RETIRQ, and RETNMI) are not present.

Also, unlike the 6502 version, there is no warm/cold start or memory
size? prompt on startup.

References:

1. http://www.sunrise-ev.com/photos/6502/EhBASIC-manual.pdf
2. http://retro.hansotten.nl/home/lee-davison-web-site/
3. http://www.easy68k.com/applications.htm
4. http://sun.hasenbraten.de/vasm/

------------------------------------------------------------------------

 EhBASIC68

 Enhanced BASIC is a BASIC interpreter for the 68k family microprocessors. It
 is constructed to be quick and powerful and easily ported between 68k systems.
 It requires few resources to run and includes instructions to facilitate easy
 low level handling of hardware devices. It also retains most of the powerful
 high level instructions from similar BASICs.

 EhBASIC is copyright Lee Davison 2002 - 2012 and free for educational or
 personal use only.
 For commercial use please contact me at leeedavison@lgooglemail.com for conditions.

 For more information on EhBASIC68, other versions of EhBASIC and other projects
 please visit my site at ..

	 http://mycorner.no-ip.org/index.html
