DATA     EQU     $6000
PROGRAM  EQU     $4000

STRING   EQU     $6001           ADDRESS OF FOUR DIGIT BCD STRING
RESULT   EQU     $6004           ADDRESS OF RESULT

         ORG     PROGRAM

PGM_7_4A MOVEA.W #STRING,A0      POINTER TO FIRST BCD DIGIT
         MOVEQ   #4-1,D0         NUMBER OF DIGITS(-1) TO PROCESS
         CLR.L   D1              CLEAR FINAL RESULT - D1
         CLR.L   D2              CLEAR DIGIT REGISTER
         BRA.S   NOMULT          SKIP MULTIPLY FIRST TIME

LOOP     ADD.W   D1,D1           2X
         MOVE.W  D1,D3
         LSL.W   #2,D3           8X = 2X * 4
         ADD.W   D3,D1           10X = 8X + 2X

NOMULT   MOVE.B  (A0)+,D2        NEXT BCD DIGIT,(D2[15-8] UNCHANGED)
         ADD.W   D2,D1           ADD NEXT DIGIT
         DBRA    D0,LOOP         CONTINUE PROCESSING IF STILL DIGITS

         MOVE.W  D1,RESULT       STORE RESULT

         RTS

         END     PGM_7_4A
