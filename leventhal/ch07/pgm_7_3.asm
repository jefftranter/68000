DATA     EQU     $6000
PROGRAM  EQU     $4000

DIGIT    EQU     $6001           ADDRESS OF DIGIT
CHAR     EQU     $6000           ADDRESS OF CHAR

         ORG     PROGRAM

PGM_7_3  MOVEQ   #-1,D1          SET ERROR FLAG
         MOVE.B  CHAR,D0         GET CHARACTER
         SUB.B   #'0',D0         IS CHARACTER BELOW ASCII ZERO?
         BCS.S   DONE            IF YES THEN NOT A DIGIT

         CMP.B   #9,D0           IS CHARACTER ABOVE ASCII NINE?
         BHI.S   DONE            IF YES THEN NOT A DIGIT

         EXG     D0,D1           GET NUMBER VALUE OF CHARACTER

DONE     MOVE.B  D1,DIGIT        SAVE DIGIT OR ERROR CODE

         RTS

         END     PGM_7_3
