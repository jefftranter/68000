DATA     EQU     $6000
PROGRAM  EQU     $4000

INDEX    EQU     $6000                  INDEX INTO TABLE
TABLE    EQU     $6002                  START OF TABLE

         ORG     PROGRAM

PGM_9_5B MOVEA.L #TABLE,A0              GET TABLE ADDRESS
         MOVE.W  INDEX,D0               GET TABLE INDEX
         ASL.W   #2,D0                  ADJUST FOR 4 BYTE ENTRY
         MOVEA.W 0(A0,D0.W),A1          GET ADDRESS FROM JUMP TABLE
         JMP     (A1)

         RTS

         END     PGM_9_5B
