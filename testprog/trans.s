; Standalone program to provide "transparent mode" between the two
; serial ports. Any input from one port is echoed to the other port.
; Does not use any TUTOR ROM routines.

        ORG	$2000            * Located in RAM

ACIA_1   =      $00010040        * Console ACIA base address
ACIA_2   =      $00010041        * Auxiliary ACIA base address

        BRA      START           * So can start at $2000

* Write character in D0 to main (console) serial port

COUT1   MOVEM.L  A0/D1,-(A7)    * Save working registers
        LEA.L    ACIA_1,A0      * A0 points to console ACIA
TXNOTREADY1
        MOVE.B   (A0),D1        * Read ACIA status
        BTST     #1,D1          * Test TDRE bit
        BEQ.S    TXNOTREADY1    * Until ACIA Tx ready
        MOVE.B   D0,2(A0)       * Write character to send
        MOVEM.L  (A7)+,A0/D1    * Restore working registers
        RTS

* Write character in D0 to second (auxiliary) serial port

COUT2   MOVEM.L  A0/D1,-(A7)    * Save working registers
        LEA.L    ACIA_2,A0      * A0 points to console ACIA
TXNOTREADY2
        MOVE.B   (A0),D1        * Read ACIA status
        BTST     #1,D1          * Test TDRE bit
        BEQ.S    TXNOTREADY2    * Until ACIA Tx ready
        MOVE.B   D0,2(A0)       * Write character to send
        MOVEM.L  (A7)+,A0/D1    * Restore working registers
        RTS

START                           * Set up ACIA parameters
        LEA.L    ACIA_1,A0      * A0 points to console ACIA
        MOVE.B   #$15,(A0)      * Set up ACIA1 constants (no IRQ,
                                * RTS* low, 8 bit, no parity, 1 stop)
        LEA.L    ACIA_2,A0      * A0 points to aux. ACIA
        MOVE.B   #$15,(A0)      * Set up ACIA2 constants (no IRQ,
                                * RTS* low, 8 bit, no parity, 1 stop)
LOOP
        LEA.L    ACIA_1,A0      * A0 points to console ACIA
        MOVE.B   (A0),D1        * Read ACIA status
        BTST     #0,D1          * Test RDRF bit
        BEQ.S    NOCHAR1        * Branch if no input character
        MOVE.B   2(A0),D0       * Read character received
        JSR      COUT2          * Echo to port 2
NOCHAR1
        LEA.L    ACIA_2,A0      * A0 points to aux ACIA
        MOVE.B   (A0),D1        * Read ACIA status
        BTST     #0,D1          * Test RDRF bit
        BEQ.S    NOCHAR2        * Branch if no input character
        MOVE.B   2(A0),D0       * Read character received

        JSR      COUT1          * Echo to port 1
NOCHAR2
        BRA      LOOP           * Go back and repeat
