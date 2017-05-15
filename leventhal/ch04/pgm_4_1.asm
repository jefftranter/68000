DATA    EQU     $6000
PROGRAM EQU     $4000

        ORG     DATA
VALUE   DS.W    1               VALUE TO TRANSFER
RESULT  DS.W    1               STORAGE FOR TRANSFERRED DATA

        ORG     PROGRAM

PGM_4_1 MOVE.W  VALUE,D0        GET DATA TO BE MOVED
        MOVE.W  D0,RESULT       SAVE DATA

        RTS

        END     PGM_4_1
