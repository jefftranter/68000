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
GETNUMD EQU     225                     Convert ASCII encoded decimal to hex.
GETNUMA EQU     226                     Convert ASCII encoded hex to hex.
TUTOR   EQU     228                     Go to TUTOR; print prompt.
PNT8HX  EQU     230                     Convert 8 hex digits to ASCII.
HEX2DEC EQU     236                     Convert hex value to ASCII encoded decimal.
PORTIN1 EQU     241                     Input string from port 1.
OUTPUT  EQU     243                     Output string to port 1.
INCHE   EQU     247                     Input single character from port 1.
OUTCH   EQU     248                     Output single character to port 1.
FIXDATA EQU     250                     Initialize A6 to BUFFER and append string.
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
        bsr     stack_print

; Display prompt
        lea.l   PROMPT,a0               Get prompt string.
        bsr     printstring             Display it.

; Get line of input
        bsr     getstring

; Figure out what command was typed and then call appropriate routine.

; Help - '?'
        cmp.b   #'?',(a0)               Is command '?'
        bne.s   tryequals
        lea.l   HELP,a0                 Get help string.
        bsr     printstring             Display it.
        bra.s   mainloop

; = - print stack
tryequals:
        cmp.b   #'=',(a0)               Is command '=' ?
        bne.s   tryadd
        bsr     stack_print
        bra.s   mainloop

; + - add
tryadd:
        cmp.b   #'+',(a0)               Is command '+' ?
        bne.s   trysub
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        add.l   d1,d0                   Add.
        bvc.s   nov1                    Branch if no overflow
        bsr     overflow                Display overflow warning message.
nov1:   bsr     stack_push              Push result.
        bra.s   mainloop

; - - subtract
trysub:
        cmp.b   #'-',(a0)               Is command '-' ?
        bne.s   trymul
        cmp.b   #0,1(a0)                Is next character null?
        bne.s   trymul                  If not, then assume this is a minus sign for a decimal number.
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        sub.l   d1,d0                   Subtract.
        bvc.s   nov2                    Branch if no overflow
        bsr     overflow                Display overflow warning message.
nov2:   bsr     stack_push              Push result.
        bra.s   mainloop

; * - multiply
trymul:
        cmp.b   #'*',(a0)               Is command '*' ?
        bne.s   trydiv
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        bsr     MULT32                  32-bit multiply D0 = D0 * D1
        bsr     stack_push              Push result.
        bra     mainloop

; / - divide
trydiv:
        cmp.b   #'/',(a0)               Is command '/' ?
        bne.s   tryrem
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        tst.w   d1                      Check for divide by zero.
        beq.s   dividebyzero
        bsr     DIV32                   Call 32-bit divide routine.
        bsr     stack_push              Push result.
        bra     mainloop

; Handle divide by zero error.
dividebyzero:
        lea.l   DIVZERO,a0              Divide by zero error message.
        bsr     printstring             Display it.
        bra     mainloop

; % - remainder (modulus)
tryrem:
        cmp.b   #'%',(a0)               Is command '%' ?
        bne.s   trycomp2
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        tst.w   d1                      Check for divide by zero.
        beq.s   dividebyzero
        bsr     DIV32                   Call 32-bit divide routine.
        move.l  d1,d0                   Put remainder in D0.
        bsr     stack_push              Push result.
        bra     mainloop

; ! - 2's complement
trycomp2:
        cmp.b   #'!',(a0)               Is command '!' ?
        bne.s   trycomp1
        bsr     stack_pop               Get TOS in D0.
        neg.l   d0                      2's complement
        bsr     stack_push              Push result.
        bra     mainloop

; ~ - 1's complement
trycomp1:
        cmp.b   #'~',(a0)               Is command '~' ?
        bne.s   tryand
        bsr     stack_pop               Get TOS in D0.
        not.l   d0                      1's complement
        bsr     stack_push              Push result.
        bra     mainloop

; & - logical AND
tryand:
        cmp.b   #'&',(a0)               Is command '&' ?
        bne.s   tryor
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        and.l   d1,d0                   AND values.
        bsr     stack_push              Push result.
        bra     mainloop

; | - logical OR
tryor:
        cmp.b   #'|',(a0)               Is command '|' ?
        bne.s   tryexor
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        or.l    d1,d0                   OR values.
        bsr     stack_push              Push result.
        bra     mainloop

; ^ - logical exclusive OR
tryexor:
        cmp.b   #'^',(a0)               Is command '^' ?
        bne.s   tryshiftl
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        eor.l   d1,d0                   EXOR values.
        bsr     stack_push              Push result.
        bra     mainloop

; < -shift left
tryshiftl:
        cmp.b   #'<',(a0)               Is command '<' ?
        bne.s   tryshiftr
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        asl.l   d1,d0                   Shift right.
        bsr     stack_push              Push result.
        bra     mainloop

; > - shift right
tryshiftr:
        cmp.b   #'>',(a0)               Is command '>' ?
        bne.s   tryh
        bsr     stack_pop               Get TOS in D0.
        move.l  d0,d1                   Put in D1.
        bsr     stack_pop               Get TOS in D0.
        asr.l   d1,d0                   Shift right.
        bsr     stack_push              Push result.
        bra     mainloop

; h - set base to hex
tryh:
        cmp.b   #'h',(a0)               Is command 'h' ?
        beq.s   hex
        cmp.b   #'H',(a0)               Is command 'H' ?
        bne.s   trydec
hex:    move.b  #16,base
        lea.l   HEX,a0                  Base set to hex message.
        bsr     printstring             Display it.
        bra     mainloop

; n - set base to decimal
trydec:
        cmp.b   #'n',(a0)               Is command 'n' ?
        beq.s   dec
        cmp.b   #'N',(a0)               Is command 'N' ?
        bne.s   trydig
dec:    move.b  #10,base
        lea.l   DEC,a0                  Base set to decimal message.
        bsr     printstring             Display it.
        bra     mainloop

; decimal digit 0-9
trydig: cmp.b   #10,base                Is base set to 10?
        bne.s   tryhex                  Branch if not.
        move.b  #0,d1                   Clear flag indicating negative number.
        cmp.b   #'-',(a0)               Does it start with '-' ?
        bne.s   plus                    Branch if not.
        addq.l  #1,a0                   Skip over minus sign.
        move.b  #1,d1                   Set flag to make result negative later.
plus:   cmp.b   #'0',(a0)               Does it start with '0' ?
        blt     tryq                    Branch if lower.
        cmp.b   #'9',(a0)               Does it start with '9' ?
        bgt     tryq                    Branch if higher.
        bsr     validdec                Check for valid decimal number
        bvc.s   okay                    Branch if okay.
        move.l  a0,a1                   Save pointer to string.
        lea.l   BADDEC,a0               Bad number error message.
        bsr     printstring             Display it.
        move.l  a1,a0                   Get pointer to string.
        bsr     printstring             Display it.
        move.b  #"'",d0                 Display closing quote.
        bsr     printchar
        bsr     crlf                    And CRLF
        bra     mainloop

okay:   bsr     dec2bin                 Convert decimal string to 32-bit binary value.
        tst.b   d1                      Did we set flag for negative number?
        beq.s   noneg                   Branch if not.
        neg.l   d0                      Make number negative (2's complement).
noneg:  bsr     stack_push              Push it on the stack.
        bra     mainloop

; hex digit 0-9 a-f A-F
tryhex:
        cmp.b   #'0',(a0)               Does it start with '0' ?
        blt.s   tryq                    If lower, then not a valid digit.
        cmp.b   #'9',(a0)               Does it start with '9' ?
        ble.s   ishex                   If lower or equal, then it is a valid digit.
        cmp.b   #'A',(a0)               Does it start with 'A' ?
        blt.s   tryq                    If lower, then not a valid hex digit.
        cmp.b   #'F',(a0)               Does it start with 'F' ?
        ble.s   ishex                   If lower or equal, then it is a valid digit.
        cmp.b   #'a',(a0)               Does it start with 'a' ?
        blt.s   tryq                    If lower, then not a valid hex digit.
        cmp.b   #'f',(a0)               Does it start with 'f' ?
        ble.s   ishex r                 If lower or equal, then it is a valid digit.
        bra.s   tryq                    Otherwise not a digit.

ishex:

; Convert any lowercase digits a-f to A-F, otherwise reports error and goes to TUTOR monitor.
        bsr     uppercase
        bsr     validhex                Check for valid hex number.
        bvc.s   okay1                   Branch if okay.
        move.l  a0,a1                   Save pointer to string.
        lea.l   BADHEX,a0               Bad number error message.
        bsr     printstring             Display it.
        move.l  a1,a0                   Get pointer to string.
        bsr     printstring             Display it.
        move.b  #"'",d0                 Display closing quote.
        bsr     printchar
        bsr     crlf                    And CRLF
        bra     mainloop

okay1:  bsr     hex2bin                 Convert hex string to 32-bit binary value.
        bsr.s   stack_push              Push it on the stack.
        bra     mainloop

; q - quit
tryq:   cmp.b   #'q',(a0)               Is command 'q' ?
        beq.s   quit
        cmp.b   #'Q',(a0)               Is command 'Q' ?
        bne.s   invalid
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
clear:  move.l  #0,(a0)+                Clear stack element.
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
        bne.s   phex                    Branch if not.
        bsr     printdec                Print it in decimal.
        bra.s   pnt2
phex:   bsr.s   printhex                Print it in hex.
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
*
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
*
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
        bne.s   loop1                   Loop until found.
        subq.l  #1,a6                   Undo last increment.

; A5 now points to start of string and A6 points to one past end of string.

        move.b  #OUTPUT,d7              Output string function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,d7/a5/a6          Restore registers.
        rts

************************************************************************
*
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
*
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
*
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
*
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
*
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
* Convert decimal string to 32-bit value.
*
* Inputs: A0 points to string, which must be terminated in a null.
* Outputs: D0 contains the binary value
* Registers changed: D0
*
************************************************************************
dec2bin:
        movem.l d7/a1/a5/a6,-(sp)       Preserve registers that are changed here or by TUTOR.

; Change null (0) indicating end of string to EOT (4), as required by TUTOR GETNUMD function.

        move.l  a0,a1                   Initialize index to start of string.
find1:  cmp.b   #0,(a1)+                Is it a null?
        bne.s   find1
        subq.l  #1,a1                   Go back to position of null.
        move.b  #4,(a1)                 Change it to EOT.

        move.l  a0,a5                   Put string start in A5.
        move.b  #FIXDATA,d7             Copy string to buffer function.
        trap    #14                     Call TRAP14 handler.

        move.b  #GETNUMD,d7             Decimal to binary function.
        trap    #14                     Call TRAP14 handler.

        movem.l (sp)+,d7/a1/a5/a6       Restore registers.
        rts

************************************************************************
*
* Convert hexadecimal string to 32-bit value.
*
* Inputs: A0 points to string, which must be terminated in a null.
* Outputs: D0 contains the binary value
* Registers changed: D0
*
************************************************************************
hex2bin:
        movem.l d7/a1/a5/a6,-(sp)       Preserve registers that are changed here or by TUTOR.

; Change null (0) indicating end of string to EOT (4), as required by TUTOR GETNUMD function.

        move.l  a0,a1                   Initialize index to start of string.
find2:  cmp.b   #0,(a1)+                Is it a null?
        bne.s   find2
        subq.l  #1,a1                   Go back to position of null.
        move.b  #4,(a1)                 Change it to EOT.

        move.l  a0,a5                   Put string start in A5.
        move.b  #FIXDATA,d7             Copy string to buffer function.
        trap    #14                     Call TRAP14 handler.

        move.b  #GETNUMA,d7             Hex to binary function.
        trap    #14                     Call TRAP14 handler.

        movem.l (sp)+,d7/a1/a5/a6       Restore registers.
        rts

************************************************************************
*
* validdec
*
* Check for string being a valid decimal number, i.e. only the
* characters 0-9.
*
* Inputs: A0 points to string, which must be terminated in a null.
* Outputs: Sets overflow bit if invalid, clears if valid.
* Registers changed: none
*
************************************************************************
validdec:
        movem.l a0,-(sp)                Preserve registers.

scan:   tst.b   (a0)                    Have we reached end of string?
        beq.s   good                    If so, we're done and string is valid.
        cmp.b   #'0',(a0)               Does it start with '0' ?
        blt.s   bad                     Invalid character if lower.
        cmp.b   #'9',(a0)+              Does it start with '9' ?
        bgt.s   bad                     Invalid character if higher.
        bra.s   scan                    go back and continue.

bad:    or      #$02,CCR                Set overflow bit to indicate error.
        bra.s   ret

good:   and     #$02,CCR                Clear overflow bit to indicate good.
ret:    movem.l (sp)+,a0                Restore registers.
        rts

************************************************************************
*
* validhdex
*
* Check for string being a valid hex number, i.e. only the
* characters 0-9 and A-F.
*
* Inputs: A0 points to string, which must be terminated in a null.
* Outputs: Sets overflow bit if invalid, clears if valid.
* Registers changed: none
*
************************************************************************
validhex:
        movem.l a0,-(sp)                Preserve registers.
scan1:  tst.b   (a0)                    Have we reached end of string?
        beq.s   good                    If so, we're done and string is valid.
        cmp.b   #'0',(a0)               Is it '0' ?
        blt.s   bad                     Invalid character if lower.
        cmp.b   #'9',(a0)               Is it '9' ?
        ble.s   isgood                  If lower or equal, then it is a valid digit.
        cmp.b   #'A',(a0)               Is it 'A' ?
        blt.s   bad                     If lower, then not a valid hex digit.
        cmp.b   #'F',(a0)               Is it 'F' ?
        ble.s   isgood                  If lower or equal, then it is a valid digit.
        bra.s   bad                     Otherwise not a digit.
isgood: addq.l  #1,a0                   Advance pointer to next character.
        bra.s   scan1                   And continue scanning.

************************************************************************
*
* uppercase
*
* Convert a string to all uppercase. Converts characters a-z to A-Z.
*
* Inputs: A0 points to string, which must be terminated in a null.
* Outputs: String is updated in place.
* Registers changed: none
*
************************************************************************
uppercase:
        movem.l a0,-(sp)                Preserve registers.
scan2:  tst.b   (a0)                    Have we reached end of string?
        beq.s   done                    If so, we're done.
        cmp.b   #'a',(a0)               Is it 'A' ?
        blt.s   nochange                No change if less than.
        cmp.b   #'z',(a0)               Is it 'z' ?
        bgt.s   nochange                No change if greater than.
        sub.b   #$20,(a0)               Convert lower to uppercase ASCII character.
nochange:
        addq.l  #1,a0                   Advance pointer to next character.
        bra.s   scan2                   And continue scanning.

done:   movem.l (sp)+,a0                Restore registers.
        rts


************************************************************************
*
* uppercase
*
* Display "Warning: overflow" message.
*
* Inputs: none.
* Outputs: none.
* Registers changed: none
*
************************************************************************
overflow:
        movem.l a0,-(sp)                Preserve registers.
        lea.l   OVERFLOW,a0             Get overflow error string.
        bsr     printstring             Display it.
        movem.l (sp)+,a0                Restore registers.
        rts

************************************************************************
*
* The multiply and divide routines below were adapted from "Tiny BASIC
* for the Motorola MC68000" by Gordon Brandly.
*
* Copyright (C) 1984 by Gordon Brandly. This program may be freely
* distributed for personal use only. All commercial rights are
* reserved.
*
************************************************************************

*
* ===== Multiplies the 32 bit values in D0 and D1, returning
*       the 32 bit result in D0.
*
MULT32
        movem.l d2/d4,-(sp)     Save registers.
        MOVE.L  D1,D4
        EOR.L   D0,D4           see if the signs are the same
        TST.L   D0              take absolute value of D0
        BPL     MLT1
        NEG.L   D0
MLT1    TST.L   D1              take absolute value of D1
        BPL     MLT2
        NEG.L   D1
MLT2    CMP.L   #$FFFF,D1       is second argument <= 16 bits?
        BLS     MLT3            OK, let it through
        EXG     D0,D1           else swap the two arguments
        CMP.L   #$FFFF,D1       and check 2nd argument again
        BHI.W   OVFLOW          one of them MUST be 16 bits
MLT3    MOVE    D0,D2           prepare for 32 bit X 16 bit multiply
        MULU    D1,D2           multiply low word
        SWAP    D0
        MULU    D1,D0           multiply high word
        SWAP    D0
*** Rick Murray's bug correction follows:
        TST     D0              if lower word not 0, then overflow
        BNE.W   OVFLOW          if overflow, say "How?"
        ADD.L   D2,D0           D0 now holds the product
        BMI.W   OVFLOW          if sign bit set, it's an overflow
        TST.L   D4              were the signs the same?
        BPL     MLTRET
        NEG.L   D0              if not, make the result negative
MLTRET  movem.l (sp)+,d2/d4     Restore registers.
        RTS

OVFLOW: bsr     overflow
        bra     MLTRET
*
* ===== Divide the 32 bit value in D0 by the 32 bit value in D1.
*       Returns the 32 bit quotient in D0, remainder in D1.
*
DIV32   movem.l d2/d3/d4,-(sp)  Save registers.
        MOVE.L  D1,D2
        MOVE.L  D1,D4
        EOR.L   D0,D4           see if the signs are the same
        TST.L   D0              take absolute value of D0
        BPL     DIV1
        NEG.L   D0
DIV1    TST.L   D1              take absolute value of D1
        BPL     DIV2
        NEG.L   D1
DIV2    MOVEQ   #31,D3          iteration count for 32 bits
        MOVE.L  D0,D1
        CLR.L   D0
DIV3    ADD.L   D1,D1           (This algorithm was translated from
        ADDX.L  D0,D0           the divide routine in Ron Cain's
        BEQ     DIV4            Small-C run time library.)
        CMP.L   D2,D0
        BMI     DIV4
        ADDQ.L  #1,D1
        SUB.L   D2,D0
DIV4    DBRA    D3,DIV3
        EXG     D0,D1           put rem. & quot. in proper registers
        TST.L   D4              were the signs the same?
        BPL     DIVRT
        NEG.L   D0              if not, results are negative
        NEG.L   D1
DIVRT   movem.l (sp)+,d2/d3/d4  Restore registers.
        RTS

************************************************************************
*
* Strings
*
************************************************************************
VERSION  dc.b                          "RPN Calculator v1.0",CR,LF,0

PROMPT   dc.b                          "? ",0

INVALID1 dc.b                          "Invalid command '",0

INVALID2 dc.b                          "', type ? for help",CR,LF,0

HEX      dc.b                          "Base set to hex",CR,LF,0

DEC      dc.b                          "Base set to decimal",CR,LF,0

DIVZERO  dc.b                          "Error: divide by zero",CR,LF,0

OVERFLOW dc.b                          "Warning: overflow",CR,LF,0

BADDEC   dc.b                          "Invalid decimal number: '",0

BADHEX   dc.b                          "Invalid hex number: '",0

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
