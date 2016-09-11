# Simple test ROM for bringing up TS2 68000 board

	.cpu	68000
        .org	0x00008000

# Initial Supervisor Stack Pointer

        dc.l    0x00000800

# Reset vector
        dc.l    0x00008008

RESET:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        bra     RESET

# Read RAM

        move.b    0x00000000,%d0
        move.b    0x00000001,%d0
        move.b    0x00004000,%d0
        move.b    0x00004001,%d0

# Write to RAM

        move.b    #0,%d0
        move.b    %d0,0x00000000
        move.b    %d0,0x00000001
        move.b    %d0,0x00004000
        move.b    %d0,0x00004001

# Read Peripherals

        move.b    0x00010000,%d0
        move.b    0x00010040,%d0
        move.b    0x00010080,%d0
        move.b    0x000100c0,%d0
        move.b    0x00010100,%d0
        move.b    0x00010140,%d0
        move.b    0x00010180,%d0
        move.b    0x000101c0,%d0

# Write to Peripherals

        move.b    #0,%d0
        move.b    %d0,0x00010000
        move.b    %d0,0x00010040
        move.b    %d0,0x00010080
        move.b    %d0,0x000100c0
        move.b    %d0,0x00010100
        move.b    %d0,0x00010140
        move.b    %d0,0x00010180
        move.b    %d0,0x000101c0

# Send a character out the first serial port

ACIA_1   =        0x00010040        | Console ACIA control
ACIA_2   =        ACIA_1+1          | Auxilary ACIA control

SETACIA:                            | Setup ACIA parameters
         LEA.L    ACIA_1,%A0        | A0 points to console ACIA
         MOVE.B   #0x03,(%A0)       | Reset ACIA1
         MOVE.B   #0x03,1(%A0)      | Reset ACIA2
         MOVE.B   #0x15,(%A0)       | Set up ACIA1 constants (no IRQ,
         MOVE.B   #0x15,1(%A0)      | RTS* low, 8 bit, no parity, 1 stop)
         RTS                        | Return
*

        bra     RESET

        .end

