DATA     EQU     $6000
PROGRAM  EQU     $4000

LIST     EQU     $6000

         ORG     PROGRAM

PGM_9_4B MOVEA.L LIST,A0                POINTER TO LIST LENGHT
         CLR.L   D0                     CLEAR ALL 32 BITS OF D0
         BEQ.S   DONE                   IF LENGTH = 0 THEN DONE
         LEA.L   1(A0),A1               POINTER TO SECOND ELEMENT
         BCLR    #0,D1                  EXCHANGE FLASH := 0
         SUBQ.W  #1,D0                  ADJUST COUNTER FOR DBCC INSTRUCTION
         BRA.S   NSWITCH                CHECK FOR ONLY 1 ENTRY

NEXT     CMPM.B  (A0)+,(A1)+            COMPARE ADJACENT ENTRIES
         BLS.S   NSWITCH                IF FIRST <= SECOND THEN NO SWITCH
         MOVE.B  -(A0),D2               EXCHANGE
         MOVE.B  -(A1),(A0)+            ...ENTRIES
         MOVE.B  D2,(A1)+
         BSET    #0,D1                  SET EXCHANGE FLAG

NSWITCH  DBRA    D0,NEXT                COMPARE ALL ENTRIES
         BTST    #0,D1                  EXCHANGE FLAG SET?
         BNE     PGM_9_4B               IF YES THEN REPEAT TESTING

DONE     RTS

         END     PGM_9_4B
