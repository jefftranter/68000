; Simple test program for TS2 68000 board
; Displays decimal numbers on the console.
; Calls code in the TUTOR monitor ROM.

        ORG	$2000                   Located in RAM

; TRAP 14 functions
OUTPUT  EQU     243
OUT1CR  EQU     227
TUTOR   EQU     228
HEX2DEC EQU     236
FIXBUF  EQU     251

        CLR.L   D2                      Counter, start with 0.

LOOP    MOVE.B  #FIXBUF,D7              Initialize A5 and A6 to point to BUFFER.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.L  D2,D0                   Put value in D0.
        MOVE.B  #HEX2DEC,D7             Hex to decimal conversion function.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.B  #OUT1CR,D7              String output function.
        TRAP    #14                     Call TRAP14 handler.

        ADDQ.L  #1,D2                   Increment counter.
        CMP.L   #1000,D2                Did we reach 1000 yet?
        BLE     LOOP                    Go back until we reach zero.

        MOVE.B  #TUTOR,D7               Go to TUTOR function.
        TRAP    #14                     Call TRAP14 handler.
