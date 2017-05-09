;BINARY SEARCH -- (USES D4-D7,A6)
;TO SEARCH A SORTED ARRAY OF SIGNED LONGWORDS BEGINNING WITH A DUMMY ENTRY
;SMALLER THAN ANY POTENTIAL ENTRY, INITIALIZE THE REGISTERS AS FOLLOWS:
;         A6 = BASE ADDRESS OF ENTIRE ARRAY (LONGWORD)
;         D4 = TARGET LONGWORD
;         D7 = LENGTH OF ARRAY, IN BYTES, LESS DUMMY (LONGWORD)
;THE SEARCH RETURNS, IN D6, THE DISPLACEMENT (BYTES FROM BASE)
;OF THE START OF THE TARGET LONGWORD, IF PRESENT, OR -DISPLACEMENT IF THE
;TARGET IS ABSENT.
;
;
BINSRCH        CLR.L      D5                  ;D5 = pointer to bottom
               CLR.L      D6

B1             CMP.L      D5,D7               ;bottom > top?
               BMI.S      FAILURE             ;yes, exit
               MOVE.L     D7,D6               ;else D6 = (D5+D7) div 2
               ADD.L      D5,D6
               LSR.L      #1,D6
               AND.L      #$0FFFFFFFD,D6      ;back to longword boundary
               CMP.L      0(A6,D6.L),D4       ;is this it?
               BEQ.S      SUCCESS             ;yes
               BGT.S      B2                  ;no, target is bigger
               SUBQ.L     #4,D6               ;target is smaller
               MOVE.L     D6,D7               ;try lower half
               BRA        B1
B2             ADDQ.L     #4,D6               ;try upper half
               MOVE.L     D6,D5
               BRA        B1
FAILURE        NEG.L      D5                  ;return -displacement
               MOVE.L     D5,D6
SUCCESS        RTS
               END
