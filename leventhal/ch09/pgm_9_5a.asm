DATA     EQU     $6000
PROGRAM  EQU     $4000

INDEX    EQU     $6000                  INDEX INTO TABLE
TABLE    EQU     $6002                  START OF TABLE

         ORG     PROGRAM

PGM_9_5A MOVEA.W INDEX,A0               GET TABLE INDEX
         ADDA.W  A0,A0                  ADJUST INDEX FOR WORD OFFSET
         MOVEA.W TABLE(A0),A1           GET ADDRESS FROM TABLE
         JMP     (A1)

         RTS

         END     PGM_9_5A
