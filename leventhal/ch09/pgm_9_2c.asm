DATA     EQU     $6000
PROGRAM  EQU     $4000

ITEM     EQU     $6000
INDEX    EQU     $6002
LIST     EQU     $6004

         ORG     PROGRAM

PGM_9_2C MOVEA.L LIST,A0                GET START ADDRESS OF LIST
         MOVE.W  (A0),D1                GET THE ELEMENT COUNT
         BEQ.S   MISSING                IF LENGTH = 0, OBJECT IS NOT IN THE LIST

         SUBQ.W  #1,D1                  ADJUST FOR DBCC AND INDEX RANGE
         MOVE.W  D1,D2                  D2 IS THE LOOP COUNTER

         ADD.W   D1,D1                  EACH ELEMENT CONSISTS OF TWO BYTES
         ADDQ.W  #2,D1                  ADJUST FOR 1:ST PREDECREMENT IN LOP
         LEA     2(A0,D1.W),A0          POINTER BEYOND END OF LIST

         MOVE.W  ITEM,D0                GET SEARCH OBJECT

LOOP     CMP.W   -(A0),D0               SEARCH FROM END OF LIST
         DBCC    D2,LOOP                TEST NEXT IF ELEM>OBJ AND ELEM LEFT
         BEQ.S   MATCHING               OBJECT IS IN LIST, D2 HAS INDEX

MISSING  MOVEQ   #-1,D2                 "NOT FOUND"-INDEX
         BRA.S   DONE

MATCHING ADD.W   D2,D2                  ADJUST INDEX TO WORD SIZE
DONE     MOVE.W  D2,INDEX               SAVE IT

         RTS

         END     PGM_9_2C
