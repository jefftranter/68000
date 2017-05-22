* Examples of different 68000 exceptions
*
* Uncomment the appropriate lines to test.

        ORG     $2000
  
* Bus error

        MOVE.B  $20000,D0       Non-existent address

* Address error

        MOVE.W  $1001,D0        Word access at odd address.
        MOVE.L  $1001,D0        Longword access at odd address.

* Illegal instruction

        ILLEGAL

* Divide by zero

        MOVE.L  #1,D0
        DIVU.W  0,D0

* CHK instruction

        MOVE.W  #11,D0
        CHK.W   #10,D0          Trap if D0 is greater than 10 (or < 0)

* TRAPV instruction

        ORI     #$02,CCR        Set overflow bit
        TRAPV

* Privilege violation

        ANDI   #$0000,SR        Switch to user mode
        ORI    #$2700,SR        Should now fail
        MOVE   USP,A0           Should also fail

* Trace

        ORI    #$8000,SR        Set trace bit
        NOP                     Should call trace exception

* A-line emulator

        DC.W    $A000           A-line invalid instructon

* F-line emulator

        DC.W    $F000           F-line invalid instructon

* Trap 0 through 15

        TRAP    #1
        TRAP    #2
        TRAP    #15

* Exit to TUTOR monitor

        MOVE.B  #228,D7         Go to TUTOR function
        TRAP    #14             Call TRAP14 handler

* Reset instruction - does not cause an exception

        RESET

* Stop instruction - does not cause an exception

        STOP    #$2700
