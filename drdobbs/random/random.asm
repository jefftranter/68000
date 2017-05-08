;PSEUDO-RANDOM NUMBER GENERATOR -- (USES D2-D7)
;GIVEN ANY SEED (1 TO 2**31-2) IN D7 (LONGWORDS), THIS GENERATOR YIELDS A
;NON-REPEATING SEQUENCE (RAND(I)) USING ALL INTEGERS IN THE RANGE 1 TO
;2**31-2. THE AVERAGE EXECUTION TIME IS 240 MICROSECONDS (AT 8 MHZ). THIS
;GENERATOR, REFERRED TO IN THE LITERATURE AS "GGUBS", IS KNOWN TO POSSESS
;GOOD STATISTICS. THE ALGORITHM IS:
;
;              RAND(I+1) = (16807*RAND(I)) MOD (2**31)-1)
;
;WHEN PROPERLY CODED, THIS ALGORITHM WILL TRANSFORM RAND (0) = 1 INTO
;RAND(1000) = 522329230. THE FOLLOWING IMPLEMENTATION USES SYNTHETIC
;DIVISION, VIZ.,
;
;              K1 = RAND(I) DIV 127773
;              RAND(I+1) = 16807*RAND(I)-K1*127773)-K1*2836
;              IF RAND(I+1)<0 THEN RAND(I+1) = RAND(I+1)+2147483647
;
;REFERENCE:
;              BRATLEY, P., FOX, B.L. and L.E. SCHRAGE, 1983.
;              A GUIDE TO SIMULATION. SPRINGER-VERLAG.
;
;
               ORG        $1000

RANDOM         MOVE.L     D7,D6               ;copy RAND(I)
               MOVE.L     #127773,D2          ;synthetic modulus
               BSR.S      DIV                 ;divide D6 by 127773
               MOVE.L     D4,D5               ;copy K1
               MULS       #-2836,D5           ;D5 = -2836*K1
               MULU       #42591,D4           ;multiply D4 by 12773
               MOVE.L     D4,D6
               ADD.L      D4,D4
               ADD.L      D6,D4
               SUB.L      D4,D7               ;D7 = RAND(I)-K1*12773
               MOVEQ      #4,D4               ;counter
RAN1           MOVE.L     D7,D6               ;multiply D7 by 16807
               LSL.L      #3,D7
               SUB.L      D6,D7
               DBRA       D4,RAN1
               ADD.L      D5,D7               ;D7 = RAND(I+1)
               BPL.S      EXIT
               ADD.L      #2147483647,D7      ;normalize negative result
EXIT           RTS                            ;D7 = RAND(I+1)
;RAND(I) (31 BITS) DIV 127773 (17 BITS)
DIV            ADD.L      D6,D6               ;shift out unused bit
               CLR.L      D4                  ;quotient
               MOVEQ      #14,D3              ;counter
               MOVE       D6,D5               ;save low word of RAND(I)
               SWAP       D6
               AND.L      #$0FFFF,D6          ;D6 = RAND(I) DIV 2**15
DIV1           ADD        D4,D4               ;line up quotient
               ADD        D5,D5               ;and dividend
               ADDX.L     D6,D6               ;shift in bit of low word
               CMP.L      D2,D6               ;trial subtraction
               BMI.S      DIV2
               SUB.L      D2,D6               ;real subtraction
               ADDQ       #1,D4               ;put 1 in quotient
DIV2           DBRA       D3,DIV1             ;decrement counter and loop
               RTS
               END
