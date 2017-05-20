DATA     EQU     $6000
PROGRAM  EQU     $4000

NUM1     EQU     $6000                  ADDRESS OF 1:ST 64-BIT BINARY NUMBER
NUM2     EQU     $6200                  ADDRESS OF 2:ND 64-BIT BINARY NUMBER
BYTECOUNT EQU    $8                     NUMBER OF BYTES TO ADD

         ORG     PROGRAM

PGM_8_1A MOVEA.L #NUM1+BYTECOUNT,A0     ADDRESS BEYOND END OF FIRST NUMBER
         MOVEA.L #NUM2+BYTECOUNT,A1     ADDRESS BEYOND END OF SECOND NUMBER
         MOVE    #0,CCR                 CLEAR EXTEND FLAG(AND OTHER FLAGS)
         MOVEQ   #BYTECOUNT-1,D2        LOOPCOUNTER, ADJUSTED FOR DBRA

LOOP     MOVE.B  -(A0),D0
         MOVE.B  -(A1),D1
         ADDX.B  D1,D0                  D0[0-7]:= D0[0-7] + D1[0-7] + (EXT)
         MOVE.B  D0,(A0)                STORE RESULT
         DBRA    D2,LOOP                CONTINUE

         RTS

         END     PGM_8_1A
