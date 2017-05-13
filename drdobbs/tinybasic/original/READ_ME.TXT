	Welcome to the world of 68000 Tiny BASIC!

Thank you for your interest in my version of Tiny BASIC. This
zipped archive file contains all of the files mentioned in my
article in Dr. Dobb's Journal, plus many more. The Tiny BASIC on
this disk (TBI68K.ASM, HEX) is version 1.2, which has an
enhancement added by Marvin Lipford. The PRINT statement now has
a '$' option which allows you to send control characters to your
terminal.

For instance, if your terminal uses a sequence like
	  <ESC> = <y+32> <x+32>
to move the cursor, you could use a statement like
	  PRINT $27,'=',$Y+32,$X+32,
to move your cursor to the position pointed to by the variables X
and Y.

Version 1.2 also fixes a bug in the multiply routine MULT32. This
bug was discovered and fixed by Rick Murray of Sacramento,
California.

Here are the files that should be in this archive:

READ_ME.TXT    The file your are reading now
TBI68K.ART     The original Dr. Dobb's Journal article
TBI68K.ASM     The assembler source code for Tiny BASIC
TBI68K.TXT     Some more documentation for Tiny BASIC
TBI68K.HEX     The assembled binary for Tiny BASIC, in Motorola
		    hex format for the Educational Computer Board
TBI68K.PRN     The listing of the assembled version of TBI68K.ASM
UPDATE.TXT     Notes on the update to version 1.2
OUT68K.BAS     The CP/M to ECB transfer program from my article
BOMBARD.TXT    Various example programs. The TXT files are in a
BOMBARD.TBI	    straight ASCII format that you can look at
DDJGAMES.TXT	    with TYPE, etc. The TBI files are in the
DDJGAMES.TBI	    storage format that I described in my
EQPLOT.TXT	    article. The main difference is that the line
EQPLOT.TBI	    numbers are stored in a hexadecimal format.
SIEVE.TXT
SIEVE.TBI
STARTREK.TXT
STARTREK.TBI
TEASER.TXT
TEASER.TBI
TBI2TEXT.BAS   A Microsoft BASIC program to convert a .TBI file
		    back to text (.TXT) format

If you have any questions or problems, please don't hesitate
to write to me. You can reach me at (addresses updated in 1997):

E-mail:
	Internet:   gordo@datanet.ab.ca

Postal mail:
	Gordon Brandly
	12147 - 51 Street
	Edmonton AB  T5W 3G8
	Canada

