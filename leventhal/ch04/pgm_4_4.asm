DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
VALUE    DS.W    1               VALUE TO BE SHIFTED LEFT

         ORG     PROGRAM

PGM_4_4  MOVE.W  VALUE,D0        GET VALUE TO BE SHIFTED
         LSL.W   #1,D0           SHIFT LEFT LOGICALLY ONE BIT
         MOVE.W  D0,VALUE        STORE SHIFTED RESULT

         RTS

         END     PGM_4_4
