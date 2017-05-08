*************************************************************************
*                                                                       *
*       Integer Square Root (32 to 16 bit).                             *
*                                                                       *
*       (Exact method, not approximate).                                *
*                                                                       *
*       Call with:                                                      *
*               D0.L = Unsigned number.                                 *
*                                                                       *
*       Returns:                                                        *
*               D0.L - SQRT(D0.L)                                       *
*                                                                       *
*       Notes:  Result fits in D0.W, but is valid in longword.          *
*               Takes from 122 to 1272 cycles (including rts).          *
*               Averages 610 cycles measured over first 65535 roots.    *
*               Averages 1104 cycles measured over first 500000 roots.  *
*                                                                       *
*************************************************************************

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

*************************************************************************
*                                                                       *
*       Faster Integer Square Root (16 to 8 bit).  For small arguments. *
*                                                                       *
*       (Exact method, not approximate).                                *
*                                                                       *
*       Call with:                                                      *
*               D0.W = Unsigned number.                                 *
*                                                                       *
*       Returns:                                                        *
*               D0.W - SQRT(D0.W)                                       *
*                                                                       *
*       Notes:  Result fits in D0.B, but is valid in word.              *
*               Takes from 72 (d0=1) to 504 cycles (d0=625) cycles      *
*               (including rts).                                        *
*                                                                       *
*       Algorithm supplied by Motorola.                                 *
*                                                                       *
*************************************************************************

* Use the theorem that a perfect square is the sum of the first
* sqrt(arg) number of odd integers.
 
*                       Cycles
        move.w d1,-(sp) (8)
        move.w #-1,d1   (8)
qsqrt1  addq.w #2,d1    (4)
        sub.w d1,d0     (4)
        bpl  qsqrt1     (10/8)
        asr.w #1,d1     (8)
        move.w d1,d0    (4)
        move.w (sp)+,d1 (12)
done    rts             (16)

*************************************************************************
*                                                                       *
*       Integer Square Root (16 to 8 bit).                              *
*                                                                       *
*       (Exact method, not approximate).                                *
*                                                                       *
*       Call with:                                                      *
*               D0.W = Unsigned number.                                 *
*                                                                       *
*       Returns:                                                        *
*               D0.L - SQRT(D0.W)                                       *
*                                                                       *
*       Uses:   D1-D4 as temporaries --                                 *
*               D1 = Error term;                                        *
*               D2 = Running estimate;                                  *
*               D3 = High bracket;                                      *
*               D4 = Loop counter.                                      *
*                                                                       *
*       Notes:  Result fits in D0.B, but is valid in word.              *    
*                                                                       *
*               Takes from 512 to 592 cycles (including rts).           *
*                                                                       *
*               Instruction times for branch-type instructions          *
*               listed as (X/Y) are for (taken/not taken).              *
*                                                                       *
*************************************************************************

*                       Cycles
gsqrt   movem.w d1-d4,-(sp) (24)
        move.w #7,d4    (8)     ; Loop count (bits-1 of result).
        clr.w d1        (4)     ; Error term in D1.
        clr.w d2        (4)
sqrt1   add.w d0,d0     (4)     ; Get 2 leading bits a time and add
        addx.w d1,d1    (4)     ; into Error term for interpolation.
        add.w d0,d0     (4)     ; (Classical method, easy in binary).
        addx.w d1,d1    (4)
        add.w d2,d2     (4)     ; Running estimate *2.
        move.w d2,d3    (4)
        add.w d3,d3     (4)
        cmp.w d3,d1     (4)
        bls.s sqrt2     (10/8)  ; New Error term > 2* Running estimate?
        addq.w #1,d2    (4)     ; Yes, we want a '1' bit then.
        addq.w #1,d3    (4)     ; Fix up new Error term.
        sub.w d3,d1     (4)
sqrt2   dbra d4,sqrt1   (10/14) ; Do all 8 bit-pairs.
        move.w d2,d0    (4)
        movem.w (sp)+,d1-d4 (28)
        rts             (16)

*************************************************************************
*                                                                       *
*       Integer Square Root (32 to 16 bit).                             *
*                                                                       *
*       (Exact method, not approximate).                                *
*                                                                       *
*       Call with:                                                      *
*               D0.L = Unsigned number.                                 *
*                                                                       *
*       Returns:                                                        *
*               D0.L - SQRT(D0.L)                                       *
*                                                                       *
*       Uses:   D1-D4 as temporaries --                                 *
*               D1 = Error term;                                        *
*               D2 = Running estimate;                                  *
*               D3 = High bracket;                                      *
*               D4 = Loop counter.                                      *
*                                                                       *
*       Notes:  Result fits in D0.W, but is valid in longword.          *    
*                                                                       *
*               Takes from 1080 to 1236 cycles (including rts).         *
*                                                                       *
*               Two of the 16 passes are unrolled from the loop so that *
*               quicker instructions may be used where there is no      *
*               danger of overflow (in the early passes).               *
*                                                                       *
*               Instruction times for branch-type instructions          *
*               listed as (X/Y) are for (taken/not taken).              *
*                                                                       *
*************************************************************************

*                       Cycles
glsqrt  movem.w d1-d4,-(sp) (40)
        moveq #13,d4    (4)     ; Loop count (bits-1 of result).
        moveq #0,d1     (4)     ; Error term in D1.
        moveq #0,d2     (4)
lsqrt1  add.l d0,d0     (8)     ; Get 2 leading bits a time and add
        addx.w d1,d1    (4)     ; into Error term for interpolation.
        add.l d0,d0     (8)     ; (Classical method, easy in binary).
        addx.w d1,d1    (4)
        add.w d2,d2     (4)     ; Running estimate * 2.
        move.w d2,d3    (4)
        add.w d3,d3     (4)
        cmp.w d3,d1     (4)
        bls.s lsqrt2    (10/8)  ; New Error term > 2* Running estimate?
        addq.w #1,d2    (4)     ; Yes, we want a '1' bit then.
        addq.w #1,d3    (4)     ; Fix up new Error term.
        sub.w d3,d1     (4)
lsqrt2  dbra d4,lsqrt1  (10/14) ; Do first 14 bit-pairs.
        add.l d0,d0     (8)     ; Do 15-th bit-pair.
        addx.w d1,d1    (4)
        add.l d0,d0     (8)
        addx.l d1,d1    (8)
        add.w d2,d2     (4)
        move.l d2,d3    (4)
        add.w d3,d3     (4)
        cmp.l d3,d1     (6)
        bls.s lsqrt3    (10/8)
        addq.w #1,d2    (4)
        addq.w #1,d3    (3)
        sub.l d3,d1     (8)

lsqrt3  add.l d0,d0     (8)     ; Do 16-th bit-pair.
        addx.l d1,d1    (8)
        add.l d0,d0     (8)
        addx.l d1,d1    (8)
        add.w d2,d2     (4)
        move.l d2,d3    (4)
        add.l d3,d3     (8)
        cmp.l d3,d1     (6)
        bls.s lsqrt4    (10/8)
        addq.w #1,d2    (4)
lsqrt4  move.w d2,d0    (4)
        movem.l (sp)+,d1-d4 (44)
        rts             (16)

        end
