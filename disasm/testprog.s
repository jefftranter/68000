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

        roxl.b  d1,d2
        roxl.w  d3,d4
        roxl.l  d5,d6
        roxl.b  #1,d7
        roxl.w  #3,d1
        roxl.l  #7,d2
       
        roxr.b  d1,d2
        roxr.w  d3,d4
        roxr.l  d5,d6
        roxr.b  #2,d7
        roxr.w  #4,d1
        roxr.l  #8,d2

        addx.b  d0,d1
        addx.w  d2,d3
        addx.l  d4,d5
        addx.b  d6,d7
        addx.b  -(a0),-(a1)
        addx.w  -(a2),-(a3)
        addx.l  -(a4),-(a5)
        addx.b  -(a6),-(a7)

        subx.b  d0,d1
        subx.w  d2,d3
        subx.l  d4,d5
        subx.b  d6,d7
        subx.b  -(a0),-(a1)
        subx.w  -(a2),-(a3)
        subx.l  -(a4),-(a5)
        subx.b  -(a6),-(a7)

        cmpm.b  (a0)+,(a1)+
        cmpm.w  (a1)+,(a2)+
        cmpm.l  (a2)+,(a3)+
        cmpm.b  (a3)+,(a4)+
        cmpm.w  (a4)+,(a5)+
        cmpm.l  (a5)+,(a6)+
        cmpm.l  (a7)+,(a7)+

        jmp     (a1)
        jmp     $1234(a2)
        jmp     $12(a3,d1)
        jmp     $34(a4,a2)
        jmp     $1234.w
        jmp     $12345678
        jmp     $1234(pc)
        jmp     $12(pc,d4)
        jmp     $12(pc,a5)

        jsr     (a1)
        jsr     $1234(a2)
        jsr     $12(a3,d1)
        jsr     $34(a3,a2)
        jsr     $1234.w
        jsr     $12345678
        jsr     $1234(pc)
        jsr     $12(pc,d4)
        jsr     $12(pc,a5)

        ori.b   #$12,d0
        ori.b   #$12,(a0)
        ori.b   #$12,(a1)+
        ori.b   #$12,-(a2)
        ori.b   #$12,$3456(a3)
        ori.b   #$34,$56(a3,d4)
        ori.b   #$34,$56(a3,a5)
        ori.b   #$56,$1234.w
        ori.b   #$78,$12345678

        ori.w   #$1234,d0
        ori.w   #$1234,(a0)
        ori.w   #$1234,(a1)+
        ori.w   #$1234,-(a2)
        ori.w   #$1234,$3456(a3)
        ori.w   #$1234,$56(a3,d4)
        ori.w   #$1234,$56(a3,a5)
        ori.w   #$1234,$5678.w
        ori.w   #$1234,$87654321

        ori.l   #$12345678,d0
        ori.l   #$12345678,(a0)
        ori.l   #$12345678,(a1)+
        ori.l   #$12345678,-(a2)
        ori.l   #$12345678,$3456(a3)
        ori.l   #$12345678,$76(a3,d4)
        ori.l   #$12345678,$76(a3,a5)
        ori.l   #$12345678,$4321.w
        ori.l   #$12345678,$87654321

        andi.b  #$12,d0
        andi.b  #$12,(a0)
        andi.b  #$12,(a1)+
        andi.b  #$12,-(a2)
        andi.b  #$12,$3456(a3)
        andi.b  #$34,$56(a3,d4)
        andi.b  #$34,$56(a3,a5)
        andi.b  #$56,$1234.w
        andi.b  #$78,$12345678

        andi.w  #$1234,d0
        andi.w  #$1234,(a0)
        andi.w  #$1234,(a1)+
        andi.w  #$1234,-(a2)
        andi.w  #$1234,$3456(a3)
        andi.w  #$1234,$56(a3,d4)
        andi.w  #$1234,$56(a3,a5)
        andi.w  #$1234,$5678.w
        andi.w  #$1234,$87654321

        andi.l  #$12345678,d0
        andi.l  #$12345678,(a0)
        andi.l  #$12345678,(a1)+
        andi.l  #$12345678,-(a2)
        andi.l  #$12345678,$3456(a3)
        andi.l  #$12345678,$76(a3,d4)
        andi.l  #$12345678,$76(a3,a5)
        andi.l  #$12345678,$4321.w
        andi.l  #$12345678,$87654321

        subi.b  #$12,d0
        subi.b  #$12,(a0)
        subi.b  #$12,(a1)+
        subi.b  #$12,-(a2)
        subi.b  #$12,$3456(a3)
        subi.b  #$34,$56(a3,d4)
        subi.b  #$34,$56(a3,a5)
        subi.b  #$56,$1234.w
        subi.b  #$78,$12345678

        subi.w  #$1234,d0
        subi.w  #$1234,(a0)
        subi.w  #$1234,(a1)+
        subi.w  #$1234,-(a2)
        subi.w  #$1234,$3456(a3)
        subi.w  #$1234,$56(a3,d4)
        subi.w  #$1234,$56(a3,a5)
        subi.w  #$1234,$5678.w
        subi.w  #$1234,$87654321

        subi.l  #$12345678,d0
        subi.l  #$12345678,(a0)
        subi.l  #$12345678,(a1)+
        subi.l  #$12345678,-(a2)
        subi.l  #$12345678,$3456(a3)
        subi.l  #$12345678,$76(a3,d4)
        subi.l  #$12345678,$76(a3,a5)
        subi.l  #$12345678,$4321.w
        subi.l  #$12345678,$87654321

        addi.b  #$12,d0
        addi.b  #$12,(a0)
        addi.b  #$12,(a1)+
        addi.b  #$12,-(a2)
        addi.b  #$12,$3456(a3)
        addi.b  #$34,$56(a3,d4)
        addi.b  #$34,$56(a3,a5)
        addi.b  #$56,$1234.w
        addi.b  #$78,$12345678

        addi.w  #$1234,d0
        addi.w  #$1234,(a0)
        addi.w  #$1234,(a1)+
        addi.w  #$1234,-(a2)
        addi.w  #$1234,$3456(a3)
        addi.w  #$1234,$56(a3,d4)
        addi.w  #$1234,$56(a3,a5)
        addi.w  #$1234,$5678.w
        addi.w  #$1234,$87654321

        addi.l  #$12345678,d0
        addi.l  #$12345678,(a0)
        addi.l  #$12345678,(a1)+
        addi.l  #$12345678,-(a2)
        addi.l  #$12345678,$3456(a3)
        addi.l  #$12345678,$76(a3,d4)
        addi.l  #$12345678,$76(a3,a5)
        addi.l  #$12345678,$4321.w
        addi.l  #$12345678,$87654321

        eori.b  #$12,d0
        eori.b  #$12,(a0)
        eori.b  #$12,(a1)+
        eori.b  #$12,-(a2)
        eori.b  #$12,$3456(a3)
        eori.b  #$34,$56(a3,d4)
        eori.b  #$34,$56(a3,a5)
        eori.b  #$56,$1234.w
        eori.b  #$78,$12345678

        eori.w  #$1234,d0
        eori.w  #$1234,(a0)
        eori.w  #$1234,(a1)+
        eori.w  #$1234,-(a2)
        eori.w  #$1234,$3456(a3)
        eori.w  #$1234,$56(a3,d4)
        eori.w  #$1234,$56(a3,a5)
        eori.w  #$1234,$5678.w
        eori.w  #$1234,$87654321

        eori.l  #$12345678,d0
        eori.l  #$12345678,(a0)
        eori.l  #$12345678,(a1)+
        eori.l  #$12345678,-(a2)
        eori.l  #$12345678,$3456(a3)
        eori.l  #$12345678,$76(a3,d4)
        eori.l  #$12345678,$76(a3,a5)
        eori.l  #$12345678,$4321.w
        eori.l  #$12345678,$87654321

        cmpi.b  #$12,d0
        cmpi.b  #$12,(a0)
        cmpi.b  #$12,(a1)+
        cmpi.b  #$12,-(a2)
        cmpi.b  #$12,$3456(a3)
        cmpi.b  #$34,$56(a3,d4)
        cmpi.b  #$34,$56(a3,a5)
        cmpi.b  #$56,$1234.w
        cmpi.b  #$78,$12345678

        cmpi.w  #$1234,d0
        cmpi.w  #$1234,(a0)
        cmpi.w  #$1234,(a1)+
        cmpi.w  #$1234,-(a2)
        cmpi.w  #$1234,$3456(a3)
        cmpi.w  #$1234,$56(a3,d4)
        cmpi.w  #$1234,$56(a3,a5)
        cmpi.w  #$1234,$5678.w
        cmpi.w  #$1234,$87654321

        cmpi.l  #$12345678,d0
        cmpi.l  #$12345678,(a0)
        cmpi.l  #$12345678,(a1)+
        cmpi.l  #$12345678,-(a2)
        cmpi.l  #$12345678,$3456(a3)
        cmpi.l  #$12345678,$76(a3,d4)
        cmpi.l  #$12345678,$76(a3,a5)
        cmpi.l  #$12345678,$4321.w
        cmpi.l  #$12345678,$87654321

        btst    d0,d2
        btst    d1,(a2)
        btst    d2,(a3)+
        btst    d3,-(a4)
        btst    d4,$1234(a5)
        btst    d5,$12(a6,a7)
        btst    d6,$12(a6,d7)
        btst    d7,$1234.w
        btst    d0,$12345678
        btst    d1,$1234(pc)
        btst    d2,$12(pc,a1)
        btst    d3,$12(pc,d2)

        btst    #1,d2
        btst    #31,d3
        btst    #2,(a2)
        btst    #3,(a3)+
        btst    #4,-(a4)
        btst    #5,$1234(a5)
        btst    #6,$12(a6,a7)
        btst    #7,$12(a6,d7)
        btst    #8,$1234.w
        btst    #9,$12345678
        btst    #10,$1234(pc)
        btst    #11,$12(pc,a1)
        btst    #12,$12(pc,d2)

        bclr    d0,d2
        bclr    d1,(a2)
        bclr    d2,(a3)+
        bclr    d3,-(a4)
        bclr    d4,$1234(a5)
        bclr    d5,$12(a6,a7)
        bclr    d6,$12(a6,d7)
        bclr    d7,$1234.w
        bclr    d0,$12345678

        bclr    #1,d2
        bclr    #31,d3
        bclr    #2,(a2)
        bclr    #3,(a3)+
        bclr    #4,-(a4)
        bclr    #5,$1234(a5)
        bclr    #6,$12(a6,a7)
        bclr    #7,$12(a6,d7)
        bclr    #8,$1234.w
        bclr    #9,$12345678

        bchg    d0,d2
        bchg    d1,(a2)
        bchg    d2,(a3)+
        bchg    d3,-(a4)
        bchg    d4,$1234(a5)
        bchg    d5,$12(a6,a7)
        bchg    d6,$12(a6,d7)
        bchg    d7,$1234.w
        bchg    d0,$12345678

        bchg    #1,d2
        bchg    #31,d3
        bchg    #2,(a2)
        bchg    #3,(a3)+
        bchg    #4,-(a4)
        bchg    #5,$1234(a5)
        bchg    #6,$12(a6,a7)
        bchg    #7,$12(a6,d7)
        bchg    #8,$1234.w
        bchg    #9,$12345678

        bset    d0,d2
        bset    d1,(a2)
        bset    d2,(a3)+
        bset    d3,-(a4)
        bset    d4,$1234(a5)
        bset    d5,$12(a6,a7)
        bset    d6,$12(a6,d7)
        bset    d7,$1234.w
        bset    d0,$12345678

        bset    #1,d2
        bset    #31,d3
        bset    #2,(a2)
        bset    #3,(a3)+
        bset    #4,-(a4)
        bset    #5,$1234(a5)
        bset    #6,$12(a6,a7)
        bset    #7,$12(a6,d7)
        bset    #8,$1234.w
        bset    #9,$12345678

        tst.b   d1
        tst.b   (a2)
        tst.b   (a3)+
        tst.b   -(a4)
        tst.b   $1234(a5)
        tst.b   $12(a6,a7)
        tst.b   $12(a6,d7)
        tst.b   $1234.w
        tst.b   $12345678

        tst.w   d1
        tst.w   (a2)
        tst.w   (a3)+
        tst.w   -(a4)
        tst.w   $1234(a5)
        tst.w   $12(a6,a7)
        tst.w   $12(a6,d7)
        tst.w   $1234.w
        tst.w   $12345678

        tst.l   d1
        tst.l   (a2)
        tst.l   (a3)+
        tst.l   -(a4)
        tst.l   $1234(a5)
        tst.l   $12(a6,a7)
        tst.l   $12(a6,d7)
        tst.l   $1234.w
        tst.l   $12345678

        negx.b  d1
        negx.b  (a2)
        negx.b  (a3)+
        negx.b  -(a4)
        negx.b  $1234(a5)
        negx.b  $12(a6,a7)
        negx.b  $12(a6,d7)
        negx.b  $1234.w
        negx.b  $12345678

        negx.w  d1
        negx.w  (a2)
        negx.w  (a3)+
        negx.w  -(a4)
        negx.w  $1234(a5)
        negx.w  $12(a6,a7)
        negx.w  $12(a6,d7)
        negx.w  $1234.w
        negx.w  $12345678

        negx.l  d1
        negx.l  (a2)
        negx.l  (a3)+
        negx.l  -(a4)
        negx.l  $1234(a5)
        negx.l  $12(a6,a7)
        negx.l  $12(a6,d7)
        negx.l  $1234.w
        negx.l  $12345678

        clr.b   d1
        clr.b   (a2)
        clr.b   (a3)+
        clr.b   -(a4)
        clr.b   $1234(a5)
        clr.b   $12(a6,a7)
        clr.b   $12(a6,d7)
        clr.b   $1234.w
        clr.b   $12345678

        clr.w   d1
        clr.w   (a2)
        clr.w   (a3)+
        clr.w   -(a4)
        clr.w   $1234(a5)
        clr.w   $12(a6,a7)
        clr.w   $12(a6,d7)
        clr.w   $1234.w
        clr.w   $12345678

        clr.l   d1
        clr.l   (a2)
        clr.l   (a3)+
        clr.l   -(a4)
        clr.l   $1234(a5)
        clr.l   $12(a6,a7)
        clr.l   $12(a6,d7)
        clr.l   $1234.w
        clr.l   $12345678

        neg.b   d1
        neg.b   (a2)
        neg.b   (a3)+
        neg.b   -(a4)
        neg.b   $1234(a5)
        neg.b   $12(a6,a7)
        neg.b   $12(a6,d7)
        neg.b   $1234.w
        neg.b   $12345678

        neg.w   d1
        neg.w   (a2)
        neg.w   (a3)+
        neg.w   -(a4)
        neg.w   $1234(a5)
        neg.w   $12(a6,a7)
        neg.w   $12(a6,d7)
        neg.w   $1234.w
        neg.w   $12345678

        neg.l   d1
        neg.l   (a2)
        neg.l   (a3)+
        neg.l   -(a4)
        neg.l   $1234(a5)
        neg.l   $12(a6,a7)
        neg.l   $12(a6,d7)
        neg.l   $1234.w
        neg.l   $12345678

        not.b   d1
        not.b   (a2)
        not.b   (a3)+
        not.b   -(a4)
        not.b   $1234(a5)
        not.b   $12(a6,a7)
        not.b   $12(a6,d7)
        not.b   $1234.w
        not.b   $12345678

        not.w   d1
        not.w   (a2)
        not.w   (a3)+
        not.w   -(a4)
        not.w   $1234(a5)
        not.w   $12(a6,a7)
        not.w   $12(a6,d7)
        not.w   $1234.w
        not.w   $12345678

        not.l   d1
        not.l   (a2)
        not.l   (a3)+
        not.l   -(a4)
        not.l   $1234(a5)
        not.l   $12(a6,a7)
        not.l   $12(a6,d7)
        not.l   $1234.w
        not.l   $12345678

        move    sr,d1
        move    sr,(a2)
        move    sr,(a3)+
        move    sr,-(a4)
        move    sr,$1234(a5)
        move    sr,$12(a6,a7)
        move    sr,$12(a6,d7)
        move    sr,$1234.w
        move    sr,$12345678

        move    d1,ccr
        move    (a2),ccr
        move    (a3)+,ccr
        move    -(a4),ccr
        move    $1234(a5),ccr
        move    $12(a6,a7),ccr
        move    $12(a6,d7),ccr
        move    $1234.w,ccr
        move    $12345678,ccr
        move    #$1234,ccr
        move    ($1234,pc),ccr
        move    $12(pc,a1),ccr
        move    $12(pc,d2),ccr

        move    d1,sr
        move    (a2),sr
        move    (a3)+,sr
        move    -(a4),sr
        move    $1234(a5),sr
        move    $12(a6,a7),sr
        move    $12(a6,d7),sr
        move    $1234.w,sr
        move    $12345678,sr
        move    #$1234,sr
        move    ($1234,pc),sr
        move    $12(pc,a1),sr
        move    $12(pc,d2),sr

        nbcd    d1
        nbcd    (a2)
        nbcd    (a3)+
        nbcd    -(a4)
        nbcd    $1234(a5)
        nbcd    $12(a6,a7)
        nbcd    $12(a6,d7)
        nbcd    $1234.w
        nbcd    $12345678

        pea     (a2)
        pea     $1234(a5)
        pea     $12(a6,a7)
        pea     $12(a6,d7)
        pea     $1234.w
        pea     $12345678
        pea     ($1234,pc)
        pea     $12(pc,a1)
        pea     $12(pc,d2)

        tas     d1
        tas     (a2)
        tas     (a3)+
        tas     -(a4)
        tas     $1234(a5)
        tas     $12(a6,a7)
        tas     $12(a6,d7)
        tas     $1234.w
        tas     $12345678
