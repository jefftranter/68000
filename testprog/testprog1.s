; Simple test program for TS2 68000 board
; Displays a "Hello, world!" message on the console.
; Calls code in the TS2 monitor ROM.

        ORG	$2000              Locate in RAM

PSTRING EQU     $0000807C          Monitor routine to display the string pointed to by A4

START   LEA.L    HELLO(PC),A4      Point to message string
        JSR      PSTRING           Print it
        TRAP     #14               Breakpoint, return to monitor

HELLO   DC.B   "Hello, world!\r\n\0"
