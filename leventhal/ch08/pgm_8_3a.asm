DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA

NUM1     DS.W    1                      16-BIT MULTIPLICANT
NUM2     DS.W    1                      16-BIT MULTIPLIER
RESULT   DS.L    1                      32-BIT MULTIPLICATION RESULT

         ORG     PROGRAM

PGM_8_3A MOVE.W  NUM1,D0                MULTIPLICAND
         MULU    NUM2,D0                UNSIGNED MULTIPLICATION
         MOVE.L  D0,RESULT              STORE 32-BIT MULTIPLICATION RESULT

         RTS

         END     PGM_8_3A
