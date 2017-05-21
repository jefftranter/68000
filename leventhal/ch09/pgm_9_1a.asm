DATA     EQU     $6000
PROGRAM  EQU     $4000

ITEM     EQU     $6000                  SEARCH ITEM
LIST     EQU     $6002                  POINTER TO START OF LIST

         ORG     PROGRAM

PGM_9_1A MOVE.W  ITEM,D0                GET SEARCH ITEM
         MOVEA.L LIST,A0                A0 - POINTER TO LIST
         MOVEA.L A0,A1                  SAVE POINTER TO LIST COUNT
         MOVE.W  (A0)+,D1               D1.W - NUMBER OF ELEMENTS IN LIST
         SUBQ.W  #1,D1                  ADJUST FOR DBEQ

LOOP     CMP.W   (A0)+,D0               TEST NEXT ELEMENT FOR MATCH
         DBEQ    D1,LOOP                CONTINUE UNTIL MATCH OR LIST END
         BEQ.S   DONE                   IF MATCH THEN DONE

         MOVE.W  D0,(A0)                ...ELSE ADD ELEMENT TO LIST
         ADDQ.W  #1,(A1)                INCREMENT LIST COUNT

DONE     RTS

         END     PGM_9_1A
