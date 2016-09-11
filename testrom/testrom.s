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

ACIA     =        0x00010040       | Console ACIA control
                                   | Setup ACIA parameters
        lea.l    ACIA,%a0          | A0 points to console ACIA
        move.b   #0x03,(%a0)       | Reset ACIA
        move.b   #0x15,(%a0)       | Set up ACIA constants (no IRQ, RTS* low, 8 bit, no parity, 1 stop)
        move.b   #'A',2(%a0)       | Send character A out ACIA

        bra     RESET

        .end
