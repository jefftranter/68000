; Simple test program for TS2 68000 board
; Displays random numbers on the console.
; Calls code in the TUTOR monitor ROM.

  INCLUDE random.asm

; TRAP 14 functions
OUTPUT  EQU     243
OUTCH   EQU     248
OUT1CR  EQU     227
TUTOR   EQU     228
HEX2DEC EQU     236
FIXBUF  EQU     251

DEMO    MOVE.L  #1,D6                   Random seed, start with 1.

LOOP    MOVE.L  D6,D7                   Put value in D7.
        MOVEM.L D0-D6,-(SP)             Save registers.
        JSR     RANDOM                  Calculate random number.
        MOVEM.L (SP)+,D0-D6             Restore registers
        MOVE.L  D7,D6                   Get random result.

        MOVE.B  #FIXBUF,D7              Initialize A5 and A6 to point to BUFFER.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.L  D6,D0                   Value to convert to decimal.
        MOVE.B  #HEX2DEC,D7             Hex to decimal conversion function.
        TRAP    #14                     Call TRAP14 handler.

        MOVE.B  #OUT1CR,D7              String output function.
        TRAP    #14                     Call TRAP14 handler.

        BRA     LOOP                    Go back and do it again forever.
