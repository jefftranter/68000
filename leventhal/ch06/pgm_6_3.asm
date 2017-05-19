DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA
START    DS.L    1               ADDRESS OF STRING

CHAR_0   EQU     '0'             ASCII VALUE FOR ZERO
BLANK    EQU     ' '             ASCII VALUE FOR BLANK/SPACE

         ORG     PROGRAM

PGM_6_3  MOVEA.L START,A0        POINTER TO START OF STRING
         MOVEQ   #CHAR_0,D1      INITIALIZE WITH ASCII ZERO
         MOVEQ   #BLANK,D1       INITIALIZE WITH ASCII BLANK
         MOVE.W  (A0)+,D2        STRING LENGTH TO D2
         BEQ.S   DONE            IF LENGTH = 0 THEN DONE
         SUBQ.W  #1,D2           ADJUST STRING COUNTER FOR DBRA

LOOP     CMP.B   (A0)+,D0        IS CURRENT CHAR A ZERO?
         BNE.S   DONE            IF NO THEN DONE

         MOVE.B  D1,-1(A0)       REPLACE ZERO BY BLANK IN CURR CHAR
         DBRA    D2,LOOP         STOP SCAN IF ALL CHAR = '0'

DONE     EQU     *               DONE

         RTS

         END     PGM_6_3
