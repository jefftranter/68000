DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA

DIGIT    DS.B    1               DIGIT
CODE     DS.B    1               BCD CODE
SSEG     DC.B    $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F  CONVERSION TABLE

         ORG     PROGRAM

PGM_7_2  MOVEA.L #SSEG,A0        POINTER TO CONVERSION TABLE
         CLR.B   D1
         MOVE.B  DIGIT,D0        GET DIGIT
         CMP.B   #9,D0           VALID DIGIT?
         BHI.S   DONE            IF NOT VALID THEN CLEAR RESULT

         EXT.W   D0              MAKE INDEX BYTE LOOK LIKE A WORD
         MOVE.B  0(A0,D0),D1     GET SEVEN-SEGMENT CODE FROM TABLE

DONE     MOVE.B  D1,CODE         SAVR BCD CODE

         RTS

         END     PGM_7_2
