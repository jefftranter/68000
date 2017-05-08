This is the source for "Improved Integer Square Root Routine" by Jim
Cathey from Dr. Dobb's Toolbook of 68000 Programming.

It has been modified slightly to compile with the VASM assembler.

Original description:

Here's an integer square root routine that has been optimized
for arguments of different sizes. The actual routine is broken
into three parts: a part for arguments no larger than a single
word; a part for arguments larger than a word (with two
of the loops unrolled so that a quick word-oriented loop may
be used where there is no danger of overflow); and a special
routine that handles particularly small arguments, used
when it would be quicker than the normal word routine.
This program yields correct results over the entire
range of arguments from 0 to $FFFFFFFF.
