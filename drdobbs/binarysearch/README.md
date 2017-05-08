This is the source for "Improved Binary Search Routine" by Michael P.
McLaughlin from Dr. Dobb's Toolbook of 68000 Programming.

It has been modified slightly to compile with the VASM assembler.

Original description:

Presented below is a simple binary search of a table of
longwords, with one modification: If the target value is not
found, it returns a negative number whose absolute value is
the position at which the target would have been found had
it been there. This modification adds to the utility of the
routine and makes possible some improvements to the
calling routine. For example, if the target is not present
you may want to insert it. The binary search makes that
easier, since you'll already know the intersection point.
