Reverse Polish (infix) Calculator Demo
======================================

This is a simple math evaluation program/calculator written in 68000
assembler and written for my TS2 single board computer.

It works with 32-bit signed integers and supports some basic math and
bitwise functions and input and output in hex and decimal.

The stack size is programmable at build time and defaults to five.

It is written for the VASM cross-assembler.

Operation               Description
---------               ------------

number <Enter>          Enter number (32-bit signed), put on top of stack

.                       Display stack

+                       Add two numbers on stack, pop them, push result ( i j -- i+j )

-                       Subtract two numbers on stack, pop them, push result ( i j -- i-j )

*                       Multiply two numbers on stack, pop them, push result ( i j -- i*j )

/                       Divide two numbers on stack, pop them, push result ( i j -- i/j )

%                       Divide two numbers on stack, pop them, push remainder ( i j -- i%j )

!                       2's complement ( n -- -n )

~                       1's complement ( n -- ~n )

&                       Bitwise AND ( i j -- i^j )

|                       Bitwise inclusive OR ( i j -- i|j )

^                       Bitwise exclusive OR ( i j -- i^j )

<                       Shift left ( i j -- i<<j )

>                       Shift right ( i j -- i>>j )

=                       Pop and compare two values on top of stack. Push 1 if they are same, otherwise 0 ( i j -- k )

h                       Set input and output base to hexadecimal.

n                       Set input and output base to decimal.

q                       Quit to TUTOR monitor.

?                       Help (Show summary of commands)

The next four commands are inspired by the FORTH programming language:

DROP                    Removes the number from top of stack ( a -- )

SWAP                    Exchanges the top 2 numbers on the stack ( a b -- b a )

DUP                     Duplicates the value on the top of stack ( a -- a a )

ROT                     Rotates the top 3 numbers on the top of the stack ( a b c -- b c a )

Example:

RPN Calculator v1.0
00000000
00000000
00000000
00000000
00000000
? 3
00000000
00000000
00000000
00000000
00000003
? 4
00000000
00000000
00000000
00000003
00000004
? *
00000000
00000000
00000000
00000000
0000000C
? !
00000000
00000000
00000000
00000000
FFFFFFF4
? n
Base set to decimal
0
0
0
0
-12
? 10
0
0
0
-12
10
? *
0
0
0
0
-120
?
