DATA     EQU     $6000
PROGRAM  EQU     $4000

ITEM     EQU     $6000
INDEX    EQU     $6002
LIST     EQU     $6004

         ORG     PROGRAM

PGM_9_2A MOVE.W  ITEM,D0                GET SEARCH OBJECT
         MOVEA.L LIST,A0                GET START ADDRESS OF TO LIST
         MOVEQ   #0,D1                  CLEAR THE ELEMENT COUNT
         MOVE.W  (A0),D1                GET THE ELEMENT COUNT
         BEQ.S   MISSING                IF LENGTH = 0, OBJECT IS NOT IN THE LIST

         ADD.W   D1,D1                  EACH ELEMENT CONSISTS OF TWO BYTES
         SUBQ.W  #2,D1                  INDEX RANGE = 0 - (LENGTH*2 -2) !

LOOP     CMP.W   2(A0,D1.W),D0          SEARCH FROM END OF LIST TO START
         BEQ.S   DONE                   OBJECT IS IN LIST, D1 HOLDS INDEX
         BHI.S   MISSING                LIST ELEMENT SMALLER, OBJ NOT IN LIST
         SUBQ.W  #2,D1                  INDEX FOR NEXT SMALLER ELEMENT
         BCC     LOOP                   INDEX >= 0 - CONTINUE

MISSING  MOVEQ   #-1,D1                 "NOT FOUND"-INDEX

DONE     RTS

         END     PGM_9_2A
