* This is a simple Rock, Paper, Scissors game implemented in 68000
* assembler code to run on the TS2 single board computer with the
* TUTOR ROM monitor.
*
* It is written for the VASM cross-assembler.
*
* Copyright (C) 2017 Jeff Tranter <tranter@pobox.com>
*
* To Do:
*
* Add alternative version for "rock-paper-scissors-Spock-lizard".

*************************************************************************
*
* Constants
*
*************************************************************************

CR      equ     $0D                     Carriage return
LF      equ     $0A                     Line feed

* TUTOR TRAP 14 functions
GETNUMD equ     225                     Convert ASCII encoded decimal to hex.
TUTOR   equ     228                     Go to TUTOR; print prompt.
HEX2DEC equ     236                     Convert hex value to ASCII encoded decimal.
PORTIN1 equ     241                     Input string from port 1.
OUTPUT  equ     243                     Output string to port 1.
OUTCH   equ     248                     Output single character to port 1.
FIXDATA equ     250                     Initialize A6 to BUFFER and append string.
FIXBUF  equ     251                     Initialize A5 and A6 to BUFFER.

* Items:
ROCK     equ    0
PAPER    equ    1
SCISSORS equ    2

* Players/Winner:
TIE      equ    0
HUMAN    equ    1
COMPUTER equ    2

*************************************************************************
*
* Main Program Start
*
*************************************************************************

* Start address
        ORG     $1000                   Locate in RAM.

start:
        
        bsr     PrintString
        bra     Tutor                   Return to TUTOR

*************************************************************************
*
* Utility Functions
*
*************************************************************************

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
PrintString:
        movem.l d7/a5/a6,-(sp)          Preserve registers that are changed here or by TUTOR.
        move.l  a0,a5                   TUTOR routine wants start of string in A5.
        move.l  a0,a6                   This will be a pointer to the end of string + 1.
loop1:  cmp.b   #0,(a6)+                Find terminating null.
        bne.s   loop1                   Loop until found.
        subq.l  #1,a6                   Undo last increment.

* A5 now points to start of string and A6 points to one past end of string.

        move.b  #OUTPUT,d7              Output string function.
        trap    #14                     Call TRAP14 handler.
        movem.l (sp)+,d7/a5/a6          Restore registers.
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
GetString:
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
* Print a number to the console in decimal.
*
* Prints decimal value of a 32-bit number on the console.
*
* Inputs: DO - the number to display (longword)
* Outputs: none
* Registers changed: none
*
************************************************************************
PrintDec:
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

* Change null (0) indicating end of string to EOT (4), as required by TUTOR GETNUMD function.

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

* random - generate 32-bit random number
* rand(i,j) - return random number from i through j

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
Tutor:
        move.b  #TUTOR,d7               Go to TUTOR function.
        trap    #14                     Call TRAP14 handler.

* Table of Winning Rules

* Player 1      Player 2      Winner
* (human)       (computer)
* ------------  ------------  ------
* 0 (rock)      0 (rock)      0 (tie)
* 0 (rock)      1 (paper)     1 (paper)
* 0 (rock)      2 (scissors)  0 (rock)
* 1 (paper)     0 (rock)      1 (paper)
* 1 (paper)     1 (paper)     0 (tie)
* 1 (paper)     2 (scissors)  2 (scissors)
* 2 (scissors)  0 (rock)      0 (rock)
* 2 (scissors)  1 (paper)     2 (scissors)
* 2 (scissors)  2 (scissors)  0 (tie)


*************************************************************************
*
* Strings
*
*************************************************************************

WELCOME        dc.b    "Welcome to Rock, Paper, Scissors\r\n================================",0

* "Rock"
* "Paper"
* "Scissors"
* "How many games do you want to play? "
* "Game number: "
* " of "
* "1=Rock 2=Paper 3=Scissors"
* "1... 2... 3... What do you play? "
* "This is my choice... "
* " beats "
* ", I win."
* ", you win."
* ", a tie."
* 
* "Final game score:"
* "I have won 4 games."
* "You have won 6 games."
* "You win!"
* "I win!"
* "It's a tie!"
* "Play again (y/n)? "


*************************************************************************
*
* Variables:
*
*************************************************************************

* Total number of games
TOTALGAMES     ds.b     1

* Current game number
GAMENO         ds.b     1

* Games won by computer
COMPUTERWON    ds.b     1

* Games won by human
HUMANWON       ds.b     1
