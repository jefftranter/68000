DATA     EQU     $6000
PROGRAM  EQU     $4000

DIGIT    EQU     $6000           ADDRESS OF DIGIT
CHAR     EQU     $6001           ADDRESS OF CHAR

         ORG     PROGRAM

PGM_7_1  MOVE.B  DIGIT,D0        GET HEX-DIGIT
         CMP.B   #10,D0          IS DIGIT < 10?
         BLT.S   ADD_0           IF YES THEN ADD '0' ONLY

         ADD.B   #'A'-'0'-10,D0  ...ELSE ADD OFFSET FOR 'A'-'F' ALSO

ADD_0    ADD.B   #'0',D0         CONVERT TO ASCII
         MOVE.B  D0,CHAR         STORE ASCII DIGIT

         RTS

         END     PGM_7_1
