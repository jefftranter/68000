# Simple test program for TS2 68000 board
# Displays a "Hello, world!" message on the console.
# Calls code in the TUTOR monitor ROM.

	.cpu	68000
        .org	0x00002000         | Located in RAM

# TRAP 14 functions
OUTPUT = 243
OUT1CR = 227
TUTOR  = 228

HELLO = 0x00002020

START:
        move.l   #HELLO,%A5        | Start of string
        move.l   #HELLO+13,%A6     | End of string
#       move.b  #OUTPUT,%D7        | String output function
        move.b  #OUT1CR,%D7        | String output function
        trap    #14                | Call TRAP14 handler

        move.b  #TUTOR,%D7         | Go to TUTOR function
        trap    #14                | Call TRAP14 handler

        .org 0x00002020
        .ascii   "Hello, world!"
