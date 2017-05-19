DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
START    DS.L    1               ADDRESS OF STRING

         ORG     PROGRAM

PGM_6_4  MOVEA.L START,A0        POINTER TO START OF STRING
         MOVE.W  (A0)+,D2        STRING LENGTH TO D2
         BEQ.S   DONE            IF LENGTH = 0 THEN DONE
         SUBQ.W  #1,D2           ADJUST STRING COUNTER FOR DBRA
         MOVEQ   #0,D3           CONSTANT ZERO FOR ADDX INSTRUCTION

MAIN_LOOP EQU    *
         MOVE.B  (A0)+,D1        GET CURRENT CHARACTER
         MOVEQ   #0,D0           CLEAR BIT COUNTER

PARITY_LOOP EQU  *
         LSL.B   #1,D1           SHIFT MSB OF CHAR INTO C & X-BITS
         ADDX.B  D3,D0           ADD X-BIT TO BIT COUNT
         TST.B   D1              TEST IF ALL BITS = 1 COUNTED
         BNE     PARITY_LOOP     IF NO THEN CONTINUE COUNTING

         BTST    #0,D0           ...ELSE CHECK FOR ODD PARITY
         BEQ.S   NEXT_CHAR       IF EVEN THEN PROCESS NEXT CHAR

         BSET.B  #7,-1(A0)       ...ELSE SET PARITY BIT

NEXT_CHAR EQU    *
         DBRA    D2,MAIN_LOOP    CONTINUE OF CHAR LEFT IN STRING

DONE     EQU     *               STRING NOW HAS EVEN PARITY

         RTS

         END     PGM_6_4
