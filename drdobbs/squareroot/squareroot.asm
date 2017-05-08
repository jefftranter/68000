************************************************************************
*                                                                      *
*       Integer Square Root (32 to 16 bit).                            *
*                                                                      *
*       (Exact method, not approximate).                               *
*                                                                      *
*       Call with:                                                     *
*               D0.L = Unsigned number.                                *
*                                                                      *
*       Returns:                                                       *
*               D0.L - SQRT(D0.L)                                      *
*                                                                      *
*       Notes:  Result fits in D0.W, but is valid in longword.         *
*               Takes from 122 to 1272 cycles (including rts).         *
*               Averages 610 cycles measured over first 65535 roots.   *
*               Averages 1104 cycles measured over first 500000 roots. *
*                                                                      *
************************************************************************

        xdef lsqrt
*                       Cycles
lsqrt   tst.l d0        (4)     ; skip doing zero.
        beq.s done      (10/8)
        cmp.l #$10000,d0 (14)   ; If it is a longword, use the long routine.
        bhs.s glsqrt    (10/8)
        cmp.w #625,d0   (8)     ; Would the short word routine be quicker?
        bhi.s gsqrt     (10/8)  ; No, use general purpose word routine.
*                               ; Otherwise fall into special routine.
*
*  For speed, we use three exit points.
*  This is cheesy, but this is a speed-optimized subroutine!

************************************************************************

