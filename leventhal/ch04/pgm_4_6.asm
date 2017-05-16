DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
VALUE1   DS.L    1               FIRST VALUE
VALUE2   DS.L    1               SECOND VALUE
RESULT   DS.L    1               RESERVE LONG WORD STORAGE

         ORG     PROGRAM

PGM_4_6  MOVEM.L VALUE1,D0/D1    LOAD VALUES TO BE COMPARED
         CMP.L   D0,D1           COMPARE 32 BIT VALUES
         BHI     STORE           IF VALUE2 >= VALUE1 THEN GOTO STORE
         MOVE.L  D0,D1           ...ELSE D1 = VALUE1
STORE    MOVE.L  D1,RESULT       STORE LARGER VALUE

         RTS

         END     PGM_4_6
