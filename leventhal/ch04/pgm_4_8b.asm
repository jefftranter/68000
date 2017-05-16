DATA     EQU     $6000
PROGRAM  EQU     $4000

         ORG     DATA

* TABLE OF FACTORIALS

FTABLE   DC      1                  0! := 1
         DC      1                  1! := 1
         DC      2                  2! := 2
         DC      6                  3! := 6
         DC      24                 4! := 24
         DC      120                5! := 120
         DC      720                6! := 720
         DC      5040               7! := 5040

VALUE    DS.B    1                  DETERMINE FACTORIAL OF THIS VALUE
         DS.B    1                  ALIGNMENT STORAGE
RESULT   DS.W    1                  RESULT OF FACTORIAL

         ORG     PROGRAM

PGM_4_8B CLR.W   D0                 D0(0:15) := 0
         MOVE.B  VALUE,D0           GET VALUE
         ADD.B   D0,D0              D0(0:7) := 2 * VALUE
         MOVEA.W D0,A0              MOVE TABLE OFFSET TO ADDRESS REG.
         MOVE.W  FTABLE(A0),RESULT  STORE FACTORIAL RESULT

         RTS

         END     PGM_4_8B
