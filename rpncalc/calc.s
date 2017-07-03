; This is a simple math evaluation program/calculator written in 68000
; assembler and written for my TS2 single board computer.
;
; It works with 32-bit signed integers and supports some basic math
; and bitwise functions and input and output in hex and decimal.
;
; The stack size is programmable at build time and defaults to five.
;
; It is written for the VASM cross-assembler.
;
; Copyright (C) 2017 Jeff Tranter <tranter@pobox.com>

; Stack size (number of elements)
STKSIZE EQU   5

; Constants
CR      EQU     $0D                     Carriage return
LF      EQU     $0A                     Line feed

; TUTOR TRAP 14 functions
TUTOR   EQU     228                     Go to TUTOR; print prompt.
PNT8HX  EQU     230                     Convert 8 hex digits to ASCII.
HEX2DEC EQU     236                     Convert hex value to ASCII encoded decimal.
PORTIN1 EQU     241                     Input string from port 1.
OUTPUT  EQU     243                     Output string to port 1.
INCHE   EQU     247                     Input single character from port 1.
OUTCH   EQU     248                     Output single character to port 1.
FIXBUF  EQU     251                     Initialize A5 and A6 to BUFFER.

; Start address
        ORG     $2000                   Located in RAM.

start:

; Initialize base to hex
        move.b #16,base

; Initialize stack

; Display startup message
        lea.l   VERSION,a0              Get startup message.
        bsr     printstring             Display it.

; Start of main command polling loop.
mainloop:

; Display stack in current base

; Display prompt
        lea.l   PROMPT,a0               Get prompt string.
        bsr     printstring             Display it.

; Get line of input
        bsr     getstring

; Figure out what command was typed and then call appropriate routine.

; Go back and get next command
        bra     mainloop

        jmp     tutor

************************************************************************
*
* I/O and conversion routines
*
* Most of these use TRAP14 handler functions from the TUTOR monitor
* firmware.
*
************************************************************************

************************************************************************
* Print a character to the console.
*
* Output the character in D0 to the console.
*
* Inputs: D0 - character to output (in low byte).
* Outputs: none
* Registers changed: none
*
*************************************************************************
printchar:
        movem.l a0/d0/d1/d7,-(sp)       Preserve registers that are changed here or by TUTOR.
        move.b  #OUTCH,d7               Output character function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,a0/d0/d1/d7       Restore registers.
        rts

************************************************************************
* Print a string to the console.
*
* Outputs null-terminated string pointed to by A0 to the console.
*
* Inputs: A0 - pointer to start of string.
* Outputs: none
* Registers changed: none
*
*************************************************************************
printstring:
        movem.l d7/a5/a6,-(sp)          Preserve registers that are changed here or by TUTOR.
        move.l  a0,a5                   TUTOR routine wants start of string in A5.
        move.l  a0,a6                   This will be a pointer to the end of string + 1.
loop1:  cmp.b   #0,(a6)+                Find terminating null.
        bne     loop1                   Loop until found.
        subq    #1,a6                   Undo last increment.

; A5 now points to start of string and A6 points to one past end of string.

        move.b  #OUTPUT,d7              Output string function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,d7/a5/a6          Restore registers.
        rts

************************************************************************
* Get character from the console.
*
* Gets character and returns it in low order byte of D0.
*
* Inputs: none
* Outputs: D0 - character input (in low byte).
* Registers changed: D0
*
************************************************************************
getchar:
        movem.l a0/d1/d7,-(sp)          Preserve registers that are changed here or by TUTOR.
        move.b  #INCHE,d7               Input char function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,a0/d1/d7          Restore registers.
        rts

************************************************************************
* Get a string from the console, terminated in newline.
*
* Input a string from the console until the user enters newline
* (Enter) and return pointer in A0. String does not include the
* newline character. The same internal buffer is used on each call, so
* copy the string if you need to to be persistent before calling the
* routine again.
*
* Inputs: none
* Outputs: A0 - pointer to start of null-terminated string.
* Registers changed: A0
*
************************************************************************
getstring:
        movem.l d7/a5/a6,-(sp)          Preserve registers that are changed here or by TUTOR.

        move.B  #FIXBUF,d7              Initialize A5 and A6 to point to BUFFER.
        trap    #14                     Call TRAP14 handler.

        move.b  #PORTIN1,d7             Input string function.
        trap    #14                     Call TRAP14 handler.

        clr.b   (a6)                    Write null to end of string (A5 points to end+1).
        move.l  a5,a0                   Point pointer to start of string in A0.

        movem.l (sp)+,d7/a5/a6          Restore registers.
        rts

************************************************************************
* Print a number to the console in hexadecimal.
*
* Prints hexadecimal value of a 32-bit number on the console.
*
* Inputs: DO - the number to display (longword)
* Outputs: none
* Registers changed: none
*
************************************************************************
printhex:
        movem.l d0/d1/d2/d7/a5/a6,-(sp) Preserve registers that are changed here or by TUTOR.

        move.b  #FIXBUF,d7              Initialize A5 and A6 to point to BUFFER.
        trap    #14                     Call TRAP14 handler.

        move.b  #PNT8HX,d7              Hex to ASCII conversion function.
        trap    #14                     Call TRAP14 handler.

        move.b  #OUTPUT,d7              String output function.
        trap    #14                     Call TRAP14 handler.

        movem.l (sp)+,d0/d1/d2/d7/a5/a6 Restore registers.
        rts

************************************************************************
* Print a number to the console in decimal.
*
* Prints decimal value of a 32-bit number on the console.
*
* Inputs: DO - the number to display (longword)
* Outputs: none
* Registers changed: none
*
************************************************************************
printdec:
        movem.l d0/d7/a5/a6,-(sp)       Preserve registers that are changed here or by TUTOR.

        move.b  #FIXBUF,d7              Initialize A5 and A6 to point to BUFFER.
        trap    #14                     Call TRAP14 handler.

        move.b  #HEX2DEC,d7             Hex to decimal conversion function.
        trap    #14                     Call TRAP14 handler.

        move.b  #OUTPUT,d7              String output function.
        trap    #14                     Call TRAP14 handler.

        movem.l (sp)+,d0/d7/a5/a6       Restore registers.
        rts

************************************************************************
* Go to TUTOR monitor.
*
* Go to the TUTOR monitor and display prompt. Does not do full
* initialization but does set stack pointer and status register. Does
* not return.
*
* Inputs: none
* Outputs: none
* Registers used: n/a
*
************************************************************************
tutor:
        move.b  #TUTOR,d7               Go to TUTOR function.
        trap    #14                     Call TRAP14 handler.

************************************************************************
*
* Strings
*
************************************************************************
VERSION  dc.b                          "RPN Calculator v0.1",CR,LF,0
PROMPT   dc.b                          "? ",0

************************************************************************
*
* Storage
*
************************************************************************

; The current base for input/output. Only 10 (decimal) and 16 (hex)
; are currently supported.

base    ds.b    1

stack:
