# Simple test program for TS2 68000 board
# Displays a "Hello, world!" message on the console.
# Calls code in the TS2 monitor ROM.

	.cpu	68000
        .org	0x00002000         | Located in RAM

PSTRING = 0x0000807c               | Monitor routine to display the string pointed to by A4

START:
        lea.l    HELLO(%PC),%A4    | Point to message string
        jsr      PSTRING           | Print it
        trap     #14               | Breakpoint, return to monitor

HELLO: .ascii   "Hello, world!\r\n\0"
