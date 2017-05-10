        ORG     $2000

RANDOM  EQU     $1000           external random function

CURVEPARM dc.w  4               adjust for desired distribution shape

        MOVEQ   #0,d2           initialize sum
        MOVE.W  CURVEPARM,d1    initialize loop counter
LOOP    JSR     RANDOM          get random # into d0
        ADD.W   d0,d2           add random # into sum
        SUBQ    #1,d1           decrement loop counter
        BNE     LOOP            loop logic
        DIVS    CURVEPARM,d2    normalize sum
