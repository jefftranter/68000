* Example of interrupt-driven I/O.
* Reads characters from console (serial port) and stores in a buffer.
* Main program runs busy wait loop.
* Returns to Tutor monitor when carriage return character is received.

TUTOR   EQU     228                     TRAP 14 function to return to monitor
AV5     EQU     $00000074               Interrupt vector for console UART (IRQ5 autovector)
ACIA1   EQU     $00010040               Console ACIA base address
CR      EQU     $0D                     Carriage return

* Main Program

        ORG     $2000                   Locate in RAM

START   CLR.B   POS                     Initialize buffer position to zero
        CLR.B   EXIT                    Initialize exit flag to false

        LEA.L   HANDLER,A0              Get address of interrupt handler
        MOVE.L  A0,AV5                  Write to interrupt vector

        LEA.L   ACIA1,A0                A0 points to console ACIA
        MOVE.B  #$95,(A0)               Set up ACIA1 (RX IRQ, RTS low, 8N1, clock divide by 16)

        AND #%1111100011111111,SR       Set ISR bits to all zeroes to enable all interrupts

* Perform endless busy loop until exit flag is set

LOOP    NOP
        TST.B   EXIT
        BEQ     LOOP
*                                       Disable interrupts from UART
        LEA.L   ACIA1,A0                A0 points to console ACIA
        MOVE.B  #$15,(A0)               Set up ACIA1 constants (no IRQ, RTS low, 8N1, clock divide by 16)

        MOVE.B  #TUTOR,D7               Go to TUTOR function
        TRAP    #14                     Call TRAP14 handler

* Interrupt handler

HANDLER MOVEM.L  A0/A1/D0/D1,-(A7)      Save working registers
        LEA.L    ACIA1,A0               A0 points to console ACIA
        MOVE.B   (A0),D0                Read ACIA status
        BTST     #0,D0                  Test RDRF bit
        BEQ.S    RETURN                 Branch if ACIA RX not ready
        LEA.L    BUFFER,A1              A1 points to start of buffer
        CLR.L    D1                     Clear all of D1
        MOVE.B   POS,D1                 D1 contains buffer position
        MOVE.B   2(A0),D0               Read character received
        MOVE.B   D0,(A1,D1)             Write to buffer
        ADDQ.B   #1,POS                 Increment buffer position
        CMP.B    #CR,D0                 Is it CR?
        BNE      RETURN                 Branch of not
        MOVE.B   #1,EXIT                Set exit flag

RETURN  MOVEM.L  (A7)+,A0/A1/D0/D1      Restore working registers
        RTE                             Return from exception

* Variables
        ORG     $3000

EXIT    DS.B    1                       Flag set when program should exit
POS     DS.B    1                       Position in buffer of next character
BUFFER  DS.B    80                      Input buffer
