DATA     EQU     $6000
PROGRAM  EQU     $4000

LENGTH   EQU     $6000                  LENGTH OF BCD NUMBER IN BYTES
BCDNUM1  EQU     $6001                  ADDRESS OF FIRST BCD NUMBER
BCDNUM2  EQU     $6101                  ADDRESS OF SECOND BCD NUMBER

         ORG     PROGRAM

PGM_8_2B CLR.W   D2
         MOVE.B  LENGTH,D2
         MOVE.W  D2,A2                  A2[0-31] = BYTES IN BCD NUMBER
         MOVEA.L #BCDNUM1,A0            POINTER TO START OF BCDNUM1
         MOVEA.L #BCDNUM2,A1            POINTER TO START OF BCDNUM2
         LEA     0(A0,D2.W),A0          ADJUST TO POINT BEYOND END OF VALUE
         LEA     0(A1,D2.W),A1          ADJUST TO POINT BEYOND END OF VALUE

         SUBQ.w  #1,D2                  ADJUST LENGTH FOR LOOP TERMINATION
         MOVE    #0,CCR                 CLEAR EXTEND FLAG FOR ABCD

LOOP     ABCD.B  -(A1),-(A0)            BCD ADDITION WITH EXTEND
         DBRA    D2,LOOP                CONTINUE

         RTS

         END     PGM_8_2B
