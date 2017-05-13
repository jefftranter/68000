; Simple test program for TS2 68000 board
; Displays a "Hello, world!" message on the console.
; Calls code in the TUTOR monitor ROM.

        ORG	$2000                   Located in RAM

; TRAP 14 functions
OUTPUT  EQU     243
OUT1CR  EQU     227
TUTOR   EQU     228

START   MOVE.L  #HELLO,A5               Start of string
        MOVE.L  #EOS,A6                 End of string
        MOVE.B  #OUT1CR,D7              String output function
        TRAP    #14                     Call TRAP14 handler

        MOVE.B  #TUTOR,D7               Go to TUTOR function
        TRAP    #14                     Call TRAP14 handler

HELLO   DC.B                           "Hello, world!"
EOS
