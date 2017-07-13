*************************************************************************
*
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
*
*************************************************************************

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

* Initialize variables

        move.b  #1,TOTALGAMES           Total number of games.
        move.b  #1,GAMENO               Current game number.
        move.b  #0,COMPUTERWON          Games won by computer.
        move.b  #0,HUMAN                Games won by human player.

        lea.l   (S_WELCOME,pc),a0       Get startup message.
        bsr     PrintString             Display it.
enter
        lea.l   (S_HOWMANY,pc),a0       "How many games do you want to play?"
        bsr     PrintString             Display it.

        bsr     GetString               Get response.
        bsr     ValidDec                Make sure it is a valid number.
        bvs     invalid                 Complain if invalid.
        bsr     Dec2Bin                 Convert it to number.

        cmp.l   #1,d0                   Make sure it is in range from 1 to 10.
        blt     invalid                 Too small.
        cmp.l   #10,d0
        ble     okay                    It is valid.

invalid
        lea.l   (S_INVALID1,pc),a0      "Please enter a number from 1 to 10."
        bsr     PrintString             Display it.
        bra     enter                   Try again.

okay
        move.b  d0,TOTALGAMES           Set total games to play.

gameloop

; Display "Game number: 1 of 10"

        lea.l   (S_GAMENUMBER,pc),a0    "Game number: "
        bsr     PrintString             Display it.
        move.b  GAMENO,d0               Get game number
        bsr     PrintDec                Display it.
        lea.l   (S_OF,pc),a0            " of "
        bsr     PrintString             Display it.
        move.b  TOTALGAMES,d0           Get total games.
        bsr     PrintDec                Display it.
        bsr     CrLf                    Newline.

enter1
        lea.l   (S_PLAY,pc),a0          "What do you play?"
        bsr     PrintString             Display it.

        bsr     GetString               Get response.
        bsr     ValidDec                Make sure it is a valid number.
        bvs     invalid1                Complain if invalid.
        bsr     Dec2Bin                 Convert it to number.

        cmp.l   #1,d0                   Make sure it is in range from 1 to 3.
        blt     invalid1                Too small.
        cmp.l   #3,d0
        ble     okay1                   It is valid.

invalid1
        lea.l   (S_INVALID2,pc),a0      "Please enter a number from 1 to 3."
        bsr     PrintString             Display it.
        bra     enter1                  Try again.

okay1
        move.b  d0,HUMANPLAY            Save player's move.

; This is my choice... Paper

; Paper beats Rock, I win.

        add.b   #1,GAMENO               Increment game number.

        move.b  GAMENO,d0               Get game number.
        cmp.b   TOTALGAMES,d0           Last game played?
        ble     gameloop                If not, play next game.

; Final game score:
; I have won 4 games.
; You have won 6 games.
; It's a tie!

; Play again (y/n)? N


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
PrintString
        movem.l d7/a5/a6,-(sp)          Preserve registers that are changed here or by TUTOR.
        move.l  a0,a5                   TUTOR routine wants start of string in A5.
        move.l  a0,a6                   This will be a pointer to the end of string + 1.
loop1   cmp.b   #0,(a6)+                Find terminating null.
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
GetString
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
PrintDec
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
PrintChar
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
CrLf
        movem.l d0,-(sp)                Preserve registers that are changed here or by TUTOR.
        move.b  #CR,d0                  Print CR
        bsr     PrintChar
        move.b  #LF,d0                  Print LF
        bsr     PrintChar
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
Dec2Bin
        movem.l d7/a1/a5/a6,-(sp)       Preserve registers that are changed here or by TUTOR.

* Change null (0) indicating end of string to EOT (4), as required by TUTOR GETNUMD function.

        move.l  a0,a1                   Initialize index to start of string.
find1   cmp.b   #0,(a1)+                Is it a null?
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
ValidDec
        movem.l a0,-(sp)                Preserve registers.

scan    tst.b   (a0)                    Have we reached end of string?
        beq.s   good                    If so, we're done and string is valid.
        cmp.b   #'0',(a0)               Does it start with '0' ?
        blt.s   bad                     Invalid character if lower.
        cmp.b   #'9',(a0)+              Does it start with '9' ?
        bgt.s   bad                     Invalid character if higher.
        bra.s   scan                    go back and continue.

bad     or      #$02,CCR                Set overflow bit to indicate error.
        bra.s   ret

good    and     #$02,CCR                Clear overflow bit to indicate good.
ret     movem.l (sp)+,a0                Restore registers.
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
Tutor
        move.b  #TUTOR,d7               Go to TUTOR function.
        trap    #14                     Call TRAP14 handler.

************************************************************************
*
* Random
*
* Generate a random 32-bit number between i and j.
*
* Inputs: D0.l: minimum value, D1.l: maximum value
* Outputs: D2.l: returned random number
* Registers used: D2
*
************************************************************************
Random
        move.l  #0,d2
        rts

************************************************************************
*
* Table of Winning Rules
*
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

S_WELCOME       dc.b    "Welcome to Rock, Paper, Scissors\r\n================================\r\n", 0
S_HOWMANY       dc.b    "How many games do you want to play? ", 0
S_INVALID1      dc.b    "Please enter a number from 1 to 10.\r\n", 0
S_INVALID2      dc.b    "Please enter a number from 1 to 3.\r\n", 0
S_GAMENUMBER    dc.b    "Game number: ", 0
S_OF            dc.b    " of ", 0
S_PLAY          dc.b    "1=Rock 2=Paper 3=Scissors\r\n1... 2... 3... What do you play? ", 0

* "Rock"
* "Paper"
* "Scissors"

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

* Human player's most recent play.
HUMANPLAY      ds.b     1

* Computer's most recent play.
COMPUTERPLAY   ds.b     1
