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
        move.b  #16,base

; Initialize stack
         bsr    stack_init

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

; Help - '?'
        cmp.b   #'?',(a0)               Command is '?'
        bne     next1

        lea.l   HELP,a0                 Get help string.
        bsr     printstring             Display it.
        bra     mainloop

; decimal or hex digit
next1:

; = - print stack
        cmp.b   #'=',(a0)               Command is '=' ?
        bne     next2
        bsr     stack_print
        bra     mainloop

; + - add
next2:
        cmp.b   #'+',(a0)               Command is '+' ?
        bne     next3
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        add.l   d1,d0                   Add.
        bsr     stack_push              Push result.
        bra     mainloop

; - - subtract
next3:
        cmp.b   #'-',(a0)               Command is '-' ?
        bne     next4
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        sub.l   d1,d0                   Subtract.
        bsr     stack_push              Push result.
        bra     mainloop

; * - multiply
next4:
        cmp.b   #'*',(a0)               Command is '*' ?
        bne     next5
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        muls.w  d1,d0                   Multiply (only uses lower 16-bits).
        bsr     stack_push              Push result.
        bra     mainloop

; / - divide
next5:
        cmp.b   #'/',(a0)               Command is '/' ?
        bne     next6
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        tst.w   d1                      Check for divide by zero.
        beq     dividebyzero
        divs.w  d1,d0                   Divide (remainder in upper word, quotient in lower word).
        ext.l   d0                      Extend quotient to 32 bits.
        bsr     stack_push              Push result.
        bra     mainloop

dividebyzero:
        lea.l   DIVZERO,a0              Divide by zero error message.
        bsr     printstring             Display it.
        bra     mainloop

; % - remainder (modulus)
next6:
        cmp.b   #'%',(a0)               Command is '%' ?
        bne     next7
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        tst.w   d1                      Check for divide by zero.
        beq     dividebyzero
        divs.w  d1,d0                   Divide (remainder in upper word, quotient in lower word).
        swap    d0                      Move remainder into low word.
        ext.l   d0                      Extend remainder to 32 bits.
        bsr     stack_push              Push result.
        bra     mainloop

; !
next7:

; ~

; &

; |

; ^

; <

; >

; h - set base to hex
        cmp.b   #'h',(a0)               Command is 'h' ?
        beq     hex
        cmp.b   #'H',(a0)               Command is 'H' ?
        bne     next9
hex:    move.b  #16,base
        lea.l   HEX,a0                  Base set to hex message.
        bsr     printstring             Display it.
        bra     mainloop

; n - set base to decimal
next9:  cmp.b   #'n',(a0)               Command is 'n' ?
        beq     dec
        cmp.b   #'N',(a0)               Command is 'N' ?
        bne     next10
dec:    move.b  #10,base
        lea.l   DEC,a0                  Base set to decimal message.
        bsr     printstring             Display it.
        bra     mainloop

; q - quit
next10: cmp.b   #'q',(a0)               Command is 'q' ?
        beq     quit
        cmp.b   #'Q',(a0)               Command is 'Q' ?
        bne     invalid
quit:   jmp     tutor

; Invalid command
invalid:
        move.l  a0,a1                   Save command string in A1.
        lea.l   INVALID1,a0             Invalid command message.
        bsr     printstring             Display it.
        move.l  a1,a0                   Put command string back in A0.
        bsr     printstring             Display it.
        lea.l   INVALID2,a0             Invalid command message.
        bsr     printstring             Display it.

; Go back and get next command
        bra     mainloop

************************************************************************
*
* Stack functions
*

************************************************************************
*
* Initialize stack to all zero values.
*
* Inputs: none
* Outputs: none
* Registers changed: none
*
************************************************************************

stack_init:
        move.l  #STKSIZE-1,d0           Get size of stack (number of elements).
        lea.l   stack,a0                Get address of start of stack.
;clear:  move.l  #0,(a0)+                Clear stack element.
clear:  move.l  d0,(a0)+                Clear stack element.
        tst.l   d0                      Is D0 zero?
        dbeq    d0,clear                Branch and continue until it is.
        rts

************************************************************************
*
* Stack Push
*
* Push a value on the top of stack. Moves all elements up, throwing
* away bottom of stack, and adds new value to top. e.g. pushing 9 on
* the stack:
*
* Before:  After:
* +-----+ +-----+
* |  5  | |  4  | <-stack
* +-----+ +-----+
* |  4  | |  3  |
* +-----+ +-----+
* |  3  | |  2  |
* +-----+ +-----+
* |  2  | |  1  |
* +-----+ +-----+
* |  1  | |  9  |
* +-----+ +-----+
*
* Inputs: D0 - value to push (longword)
* Outputs: none
* Registers changed: none
*
************************************************************************

stack_push:
        movem.l d1/a0,-(sp)             Preserve registers.
        move.l  #STKSIZE-2,d1           Get size of stack (number of elements) less two.
        lea.l   stack,a0                Get address of bottom of stack.
up:     move.l  4(a0),(a0)+             Copy element to previous stack entry.
        tst.l   d1                      Is loop counter zero?
        dbeq    d1,up                   Branch and continue until it is.
        move.l  d0,(a0)                 Write new value to top of stack
        movem.l (sp)+,d1/a0             Restore registers.
        rts

************************************************************************
*
* Stack Pop
*
* Pop a value from the top of the stack.
* Puts zero on bottom of stack and moves all elements up. Returns
* original top of stack, e.g.:
*
* Before:  After:
* +-----+ +-----+
* |  5  | |  0  | <-stack
* +-----+ +-----+
* |  4  | |  5  |
* +-----+ +-----+
* |  3  | |  4  |
* +-----+ +-----+
* |  2  | |  3  |
* +-----+ +-----+
* |  1  | |  2  |
* +-----+ +-----+
* Returns 1
*
* Inputs: none
* Outputs: D0 - value pulled (longword)
* Registers changed: D0
*
************************************************************************

stack_pop:
        movem.l d1/a0,-(sp)             Preserve registers.
        move.l  #STKSIZE-1,d1           Get size of stack (number of elements) less one.
        asl.l   #2,d1                   Multiply by element size (4).
        lea.l   stack,a0                Get address of bottom of stack.
        add.l   d1,a0                   Calculate address of top of stack.
        move.l  (a0),d0                 Get top of stack as return value.

        move.l  #STKSIZE-2,d1           Get size of stack (number of elements) less two.
down:   move.l  -4(a0),(a0)             Copy element to next stack entry.
        subq.l  #4,a0                   Advance pointer to previous entry.
        tst.l   d1                      Is loop counter zero?
        dbeq    d1,down                 Branch and continue until it is.
        move.l  #0,(a0)                 Write zero value to bottom of stack
        movem.l (sp)+,d1/a0             Restore registers.
        rts

************************************************************************
*
* Print the values on the stack. Uses current base.
*
* Inputs: none
* Outputs: none
* Registers changed: none
*
************************************************************************

stack_print:
        movem.l d0/d1/a0,-(sp)          Preserve registers that are changed here or by TUTOR.
        move.l  #STKSIZE-1,d1           Get size of stack (number of elements).
        lea.l   stack,a0                Get address of start of stack.
pnt1:   move.l  (a0)+,d0                Put next stack value in d0.
        cmp.b   #10,base                Base set to decimal?
        bne     phex                    Branch if not.
        bsr     printdec                Print it in decimal.
        bra     pnt2
phex:   bsr     printhex                Print it in hex.
pnt2:   bsr     crlf                    Print CR/LF.
        tst.l   d1                      Is loop counter zero?
        dbeq    d1,pnt1                 Branch and continue until it is.
        movem.l (sp)+,d0/d1/a0          Restore registers.
        rts

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
* Send CRLF to the console.
*
* Send carriage return, line feed to the console.
*
* Inputs: none
* Outputs: none
* Registers changed: none
*
************************************************************************
crlf:
        movem.l d0,-(sp)                Preserve registers that are changed here or by TUTOR.
        move.b  #CR,d0                  Print CR
        bsr     printchar
        move.b  #LF,d0                  Print LF
        bsr     printchar
        movem.l (sp)+,d0                Restore registers.
        rts

************************************************************************
*
* Strings
*
************************************************************************
VERSION  dc.b                          "RPN Calculator v0.1",CR,LF,0

PROMPT   dc.b                          "? ",0

INVALID1 dc.b                          "Invalid command '",0

INVALID2 dc.b                          "', type ? for help",CR,LF,0

HEX      dc.b                          "Base set to hex",CR,LF,0

DEC      dc.b                          "Base set to decimal",CR,LF,0

DIVZERO  dc.b                          "Error: divide by zero",CR,LF,0

HELP     dc.b                          "Valid commands:",CR,LF
         dc.b                          "[number]  Put number on stack",CR,LF
         dc.b                          "=         Display stack",CR,LF
         dc.b                          "+         Add",CR,LF
         dc.b                          "-         Subtract",CR,LF
         dc.b                          "*         Multiply",CR,LF
         dc.b                          "/         Divide",CR,LF
         dc.b                          "%         Remainder",CR,LF
         dc.b                          "!         2's complement",CR,LF
         dc.b                          "~         1's complement",CR,LF
         dc.b                          "&         Bitwise AND",CR,LF
         dc.b                          "|         Bitwise inclusive OR",CR,LF
         dc.b                          "^         Bitwise exclusive OR",CR,LF
         dc.b                          "<         Shift left",CR,LF
         dc.b                          ">         Shift right",CR,LF
         dc.b                          "h         Set base to hex",CR,LF
         dc.b                          "n         Set base to decimal",CR,LF
         dc.b                          "q         Quit",CR,LF
         dc.b                          "?         Help",CR,LF,0

************************************************************************
*
* Storage
*
************************************************************************

; The current base for input/output. Only 10 (decimal) and 16 (hex)
; are currently supported.

base    ds.b    1

* Stack
* One longword for each element.
* First (lowest address) entry is bottom of stack
* Last (highest address) entry is top of stack
*
* +-----+
* | BOS | <-stack
* +-----+
* |     |
* +-----+
* |     |
* +-----+
* |     |
* +-----+
* | TOS |
* +-----+

        align   1
stack:
        ds.l    STKSIZE
