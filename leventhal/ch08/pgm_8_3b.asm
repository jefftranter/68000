DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA

NUM1     DS      1                      16-BIT MULTIPLICAND
NUM2     DS      1                      16-BIT MULTIPLIER
RESULT   DS.L    1                      32-BIT MULTIPLICATION RESULT

         ORG     PROGRAM

PGM_8_3B CLR.L   D0                     CLEAR 32-BIT PRODUCT
         MOVE.L  D0,D1                  UPPER WORD MUST BE CLEAR FOR ADD.L
         MOVE.W  NUM1,D1                16-BIT MUITPLICAND
         MOVE.W  NUM2,D2                16-BIT MULTIPLIER
         MOVEQ   #16-1,D3               LOOP COUNT := 16 (-1 FOR DBRA)

LOOP     ADD.L   D0,D0                  SHIFT PRODUCT LEFT 1 BIT
         ADD.W   D2,D2                  SHIFT MULTIPLIER LEFT 1 BIT
         BCC.S   STEP                   IF MULTIPLIER[15] WAS 1

         ADD.L   D1,D0                  ...THEN ADD MULTIPLICAND

STEP     DBRA    D3,LOOP                ...ELSE CONTINUE
         MOVE.L  D0,RESULT              STORE RESULT

         RTS

         END     PGM_8_3B
