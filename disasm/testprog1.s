        org	$1000

start:
        nop
        dc.w    $F123
        dc.w    $A234
        illegal
        trap    #0
        trap    #15
        bra.s   start
        beq.s   start
        bra.w   start
        beq.w   start
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

        ori     #$0f,ccr
        ori     #$aa,sr
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
