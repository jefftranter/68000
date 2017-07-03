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

; Stack size (in elements)
STKSIZE EQU   5

; Constants
CR      EQU     $0D                     Carriage return
LF      EQU     $0A                     Line feed

; TUTOR TRAP 14 functions
TUTOR   EQU     228                     Go to TUTOR; print prompt.
OUTPUT  EQU     243                     Output string to port 1.
INCH    EQU     247                     Input single character from port 1.
OUTCH   EQU     248                     Output single character to port 1.

        ORG     $2000                   Located in RAM.

start:
        lea.l   HELLO,a0                Get address of string to print.
        jsr     printstring

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
        movem.l a5/a6,-(sp)             Preserve registers that are changed here or by TUTOR.
        move.l  a0,a5                   TUTOR routine wants start of string in A5.
        move.l  a0,a6                   This will be a pointer to the end of string + 1.
loop1:  cmp.b   #0,(a6)+                Find terminating null.
        bne     loop1                   Loop until found.
        subq    #1,a6                   Undo last increment.
; A5 now points to start of string and A6 points to one past end of string.
        move.b  #OUTPUT,d7              Output string function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,a5/a6             Restore registers.
        rts

************************************************************************
* Get character from the console.
*
getchar:
        rts

************************************************************************
* Get a string from the console, terminated in newline.
*
getstring:
        rts

************************************************************************
* Print a number to the console in hexadecimal.
*
printhex:
        rts

************************************************************************
* Print a number to the console in decimal.
*
printdec:
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
HELLO   DC.B                           "Hello, world!",0
