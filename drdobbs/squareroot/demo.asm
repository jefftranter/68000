; Simple test program for TS2 68000 board
; Displays numbers and their square roots on the console.
; Calls code in the TUTOR monitor ROM.

  INCLUDE squareroot.asm

; TRAP 14 functions
OUTPUT  EQU     243
OUTCH   EQU     248
OUT1CR  EQU     227
TUTOR   EQU     228
HEX2DEC EQU     236
FIXBUF  EQU     251

DEMO    CLR.L   D4                      Counter, start with 0.

LOOP    MOVE.B  #FIXBUF,D7              Initialize A5 and A6 to point to BUFFER.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.L  D4,D0                   Put value in D0.
        MOVE.B  #HEX2DEC,D7             Hex to decimal conversion function.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.B  #OUTPUT,D7              String output function.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.B  #OUTCH,D7               Character output function.
        MOVE.B  #' ',D0                 Print a space.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.B  #FIXBUF,D7              Initialize A5 and A6 to point to BUFFER.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.L  D4,D0                   Put value in D0.
        JSR     lsqrt                   Calculate square root.

        MOVE.B  #HEX2DEC,D7             Hex to decimal conversion function.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.L  D4,D0                   Put value in D0.
        MOVE.B  #OUT1CR,D7              String output function.
        TRAP    #14                     Call TRAP14 handler.

        ADDQ.L  #1,D4                   Increment counter.
        CMP.L   #100000,D4              Did we reach the end yet?
        BLE     LOOP                    Go back until we reach zero.

        MOVE.B  #TUTOR,D7               Go to TUTOR function.
        TRAP    #14                     Call TRAP14 handler.
