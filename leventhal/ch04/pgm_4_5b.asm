DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
VALUE    DS.B    1               BYTE TO BE DISASSEMBLED
         DS.B    1               ALIGN RESULT ON WORD BOUNDARY
RESULT   DS.W    1               STORAGE FOR DISASSEMBLED BYTE        

         ORG     PROGRAM

PGM_4_5B CLR.W   D0              CLEAR DATA REGISTER D0(0:15)
         MOVE.B  VALUE,D0        BYTE TO BE DISASSEMBLED IN D0(0:7)
         ROL.W   #4,D0           MOVE BYTE TO D0(4:11)
         LSR.B   #4,D0           SHIFT D0(4:7) TO D0(0:3)
         MOVE.W  D0,RESULT       STORE DISASSEMBLED BYTE

         RTS

         END     PGM_4_5B
