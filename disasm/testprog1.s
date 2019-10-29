        org	$1000

start:
        nop
        dc.w    $F123
        dc.w    $A234
        illegal
        reset
        rte
        rts
        trapv
        rtr
        trap    #0
        trap    #15
        ori     #$aa,ccr
        ori     #$aa55,sr
        eori    #$aa,ccr
        eori    #$aa55,sr
        andi    #$55,ccr
back:   andi    #$aa55,sr
        stop    #$1234
        bra.s   fwd
        bra.s   back
        bra.w   fwd
        bra.w   back
        bhi.s   fwd
        bls.s   fwd
        bcc.s   fwd
        bcs.s   fwd
        bne.s   fwd
        beq.s   fwd
        bvc.s   fwd
        bcs.s   fwd
        bpl.s   fwd
        bmi.s   fwd
        bge.s   fwd
        blt.s   fwd
        bgt.s   fwd
        ble.s   fwd

        bhi.w   fwd
        bls.w   fwd
        bcc.w   fwd
        bcs.w   fwd
        bne.w   fwd
        beq.w   fwd
        bvc.w   fwd
        bcs.w   fwd
        bpl.w   fwd
        bmi.w   fwd
        bge.w   fwd
        blt.w   fwd
        bgt.w   fwd
        ble.w   fwd
fwd:
        bsr.s   fwd
        bsr.s   back
        bsr.w   fwd
        bsr.w   back
        beq.s   back
        beq.s   fwd
        beq.w   fwd
        beq.w   back

        link    a1,#$1234
        link    a7,#$AA55
        unlk    a1
        unlk    a6

        swap    d1
        swap    d7

        ext.l   d2
        ext.w   d6

        move    USP,a1
        move    a2,USP

loop1:
        dbt     d0,loop1
        dbf     d1,loop2
        dbhi    d2,loop1
        dbls    d3,loop2
        dbcc    d4,loop1
        dbcs    d5,loop2
        dbne    d6,loop1
        dbeq    d7,loop2
        dbvc    d0,loop1
        dbvs    d1,loop2
        dbpl    d2,loop1
        dbmi    d4,loop2
        dbge    d4,loop1
        dblt    d5,loop2
        dbgt    d6,loop1
        dble    d7,loop2
loop2:
        movep.w d1,($1010,a2)
        movep.l d2,($2030,a3)
        movep.w ($3040,a4),d3
        movep.l ($55aa,a5),d4
loop3:
        moveq   #1,d1
        moveq   #-1,d2
        moveq   #127,d3
        moveq   #$55,d4

        abcd.b  d1,d2
        abcd.b  -(a2),-(a3)

        move.b  d1,d2
        move.w  d3,d4
        move.l  a1,a2

        move.w  d0,d0
        move.w  a0,d0
        move.w  (a0),d0
        move.w  (a0)+,d0
        move.w  -(a0),d0
        move.w  ($10,a0),d0
        move.w  ($10,a0,d0),d0
        move.w  ($10,a0,d0),d0
        move.w  $12345678,d0
        move.w  #1,d0
        move.w  ($10,pc),d0
        move.w  ($10,pc,d0),d0
        move.w  ($1000,pc),d0

        move.w  d0,d0
        move.w  d0,a0
        move.w  d0,(a0)
        move.w  d0,(a0)+
        move.w  d0,-(a0)
        move.w  d0,($10,a0)
        move.w  d0,($10,a0,d0)
        move.w  d0,($10,a0,d0)
        move.w  d0,$12345678

        ori.b   #$01,d0
        ori.w   #$0102,d0
        ori.l   #$01020304,d0
        ori.b   #$ff,$12
        ori.w   #$ff,$1234
        ori.l   #$ff,$12345678

        nop
        move.b  d1,d2
        move.w  a1,d3
        move.l  d4,a2
        bra.s   end
        bra.w   start
end:    jmp     start
