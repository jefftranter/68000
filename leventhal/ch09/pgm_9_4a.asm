DATA     EQU     $6000
PROGRAM  EQU     $4000

LIST     EQU     $6000

         ORG     PROGRAM

PGM_9_4A MOVEA.L LIST,A0                POINTER TO START OF LIST
         CLR.W   D0
         MOVE.B  (A0)+,D0               LENGTH OF LIST
         LEA     -1(A0,D0.W),A1         POINTER TO LAST LIST ELEMENT

SORT     CLR.W   D1                     COUNTER FOR EXCHANGES
         MOVEA.L A0,A2                  POINTER TO START OF LIST

NEXT     MOVE.B  (A2)+,D0               GET NEXT ELEMENT
         CMP.B   (A2),D0                COMPARE IT WITH FOLLOWING ELEMENT
         BCS.S   NSWITCH                IF PREVIOUS ELEMENT >= THEN DO NEXT

         MOVE.B  (A2),D1                ...ELSE EXCHANGE ELEMENTS
         MOVE.B  D1,-1(A2)
         MOVE.B  D0,(A2)
         ADDQ.W  #1,D1                  INCREMENT EXCHANGE COUNT

NSWITCH  CMPA.L  A2,A1                  END OF LIST
         BHI     NEXT                   IF NOT THEN LOOK AT NEXT ELEMENT
         TST.W   D1                     EXCHANGE OCCURRED?
         BNE     SORT                   YES, CONTINUE SORT
         RTS

         END     PGM_9_4A
