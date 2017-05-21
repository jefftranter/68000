DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
NUM1     DS.L    1                      32-BIT DIVIDEND
NUM2     DS.W    1                      16-BIT DIVISOR
REMAIND  DS.W    1                      16-BIT REMAINDER
QUOTIENT DS.W    1                      16-BIT QUOTIENT

         ORG     PROGRAM

PGM_8_4  MOVE.L  NUM1,D0                32-BIT DIVIDEND
         DIVU    NUM2,D0                UNSIGNED DIVIDE - NUM1/NUM2
         MOVE.L  D0,REMAIND             STORE RESULTS-REMAINDER & QUOTIENT

         RTS

         END     PGM_8_4
