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

        sbcd    d1,d2
        sbcd    d3,d4
        sbcd    -(a3),-(a4)
        sbcd    -(a6),-(a7)

        abcd    d1,d2
        abcd    d3,d4
        abcd    -(a3),-(a4)
        abcd    -(a6),-(a7)

        exg     d0,d1
        exg     d1,d2
        exg     a2,a3
        exg     a3,a4
        exg     d4,a5
        exg     a5,d6
        exg     d0,d0

        asl.b   d0,d0
        asl.w   d0,d0
        asl.l   d0,d0

        asl.w   d3,d4
        asl.l   d5,d6
        asl.b   #1,d7
        asl.w   #3,d1
        asl.l   #7,d2

        asr.b   d1,d2
        asr.w   d3,d4
        asr.l   d5,d6
        asr.b   #2,d7
        asr.w   #4,d1
        asr.l   #8,d2

        lsl.b   d1,d2
        lsl.w   d3,d4
        lsl.l   d5,d6
        lsl.b   #1,d7
        lsl.w   #3,d1
        lsl.l   #7,d2
       
        lsr.b   d1,d2
        lsr.w   d3,d4
        lsr.l   d5,d6
        lsr.b   #2,d7
        lsr.w   #4,d1
        lsr.l   #8,d2

        rol.b   d1,d2
        rol.w   d3,d4
        rol.l   d5,d6
        rol.b   #1,d7
        rol.w   #3,d1
        rol.l   #7,d2
       
        ror.b   d1,d2
        ror.w   d3,d4
        ror.l   d5,d6
        ror.b   #2,d7
        ror.w   #4,d1
        ror.l   #8,d2

        roxl.b   d1,d2
        roxl.w   d3,d4
        roxl.l   d5,d6
        roxl.b   #1,d7
        roxl.w   #3,d1
        roxl.l   #7,d2
       
        roxr.b   d1,d2
        roxr.w   d3,d4
        roxr.l   d5,d6
        roxr.b   #2,d7
        roxr.w   #4,d1
        roxr.l   #8,d2

        addx.b   d0,d1
        addx.w   d2,d3
        addx.l   d4,d5
        addx.b   d6,d7
        addx.b   -(a0),-(a1)
        addx.w   -(a2),-(a3)
        addx.l   -(a4),-(a5)
        addx.b   -(a6),-(a7)

        subx.b   d0,d1
        subx.w   d2,d3
        subx.l   d4,d5
        subx.b   d6,d7
        subx.b   -(a0),-(a1)
        subx.w   -(a2),-(a3)
        subx.l   -(a4),-(a5)
        subx.b   -(a6),-(a7)

        cmpm.b   (a0)+,(a1)+
        cmpm.w   (a1)+,(a2)+
        cmpm.l   (a2)+,(a3)+
        cmpm.b   (a3)+,(a4)+
        cmpm.w   (a4)+,(a5)+
        cmpm.l   (a5)+,(a6)+
        cmpm.l   (a7)+,(a7)+

        jmp      (a1)
        jmp      $1234(a2)
        jmp      $12(a3,d1)
        jmp      $34(a4,a2)
        jmp      $1234.w
        jmp      $12345678
        jmp      $1234(pc)
        jmp      $12(pc,d4)
        jmp      $12(pc,a5)

        jsr      (a1)
        jsr      $1234(a2)
        jsr      $12(a3,d1)
        jsr      $34(a3,a2)
        jsr      $1234.w
        jsr      $12345678
        jsr      $1234(pc)
        jsr      $12(pc,d4)
        jsr      $12(pc,a5)

        ori.b    #$12,d0
        ori.b    #$12,(a0)
        ori.b    #$12,(a1)+
        ori.b    #$12,-(a2)
        ori.b    #$12,$3456(a3)
        ori.b    #$34,$56(a3,d4)
        ori.b    #$34,$56(a3,a5)
        ori.b    #$56,$1234.w
        ori.b    #$78,$12345678

        ori.w    #$1234,d0
        ori.w    #$1234,(a0)
        ori.w    #$1234,(a1)+
        ori.w    #$1234,-(a2)
        ori.w    #$1234,$3456(a3)
        ori.w    #$1234,$56(a3,d4)
        ori.w    #$1234,$56(a3,a5)
        ori.w    #$5678,$1234.w
        ori.w    #$4321,$12345678

        ori.l    #$12345678,d0
        ori.l    #$12345678,(a0)
        ori.l    #$12345678,(a1)+
        ori.l    #$12345678,-(a2)
        ori.l    #$12345678,$87(a3)
        ori.l    #$12345678,$21(a3,d4)
        ori.l    #$12345678,$21(a3,a5)
        ori.l    #$12345678,$4321.w
        ori.l    #$12345678,$87654321
