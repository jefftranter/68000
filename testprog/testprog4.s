; Example of extending TUTOR trap #14 functions with custom functions.
; See the TUTOR documentation for details.

        ORG	$2000                   Locate in RAM.

; TRAP 14 functions
ADD     EQU     1                       My ADD custom trap function.
SUB     EQU     2                       My SUB custom trap function.
LINKIT  EQU     253                     Append user table to TRAP 14 table.
TUTOR   EQU     228                     Go to TUTOR; print prompt.

; Set up table entries for custom trap functions. Note that if you
; call this a second time without initializing TUTOR, it will link it
; to the previous table entry, which is this one, causing an infinite
; loop and breaking the code. A reset will reinitialize TUTOR.

        lea     NEWTBL,a0               Register A0 points to new table.
        move.b  #LINKIT,d7              Specify LINKIT function
        trap    #14                     Call trap function

; On return, A0 contains $FETTTTTT where TTTTTT points to old table.
; We need to write this to the end of the table.

        move.l  a0,ENDTBL               Write link to old table.

; Now try calling ADD.

        move.l    #$12345678,d0         First value to be added.
        move.l    #$00010002,d1         Second value to be added.
        move.b  #ADD,d7                 Specify ADD function
        trap    #14                     Call trap function

; Now try calling SUB.

        move.l    #$12345678,d0         First value to be subtracted.
        move.l    #$00010002,d1         Second value to be subtracted.
        move.b  #SUB,d7                 Specify SUB function
        trap    #14                     Call trap function

; Return to TUTOR now that we are done.

        move.b  #TUTOR,d7               Go to TUTOR function.
        trap    #14                     Call TRAP14 handler.

; Simple function to add two longword values and return result.
; Pass values to be added in D0 and D1. Returns result in D2.
; Does not change D0 or D1.

add    move.l d1,-(sp)                  Save original D1 value.
       add.l  d0,d1                     Add values
       move.l d1,d2                     Store result in D2.
       move.l (sp)+,d1                  Restore original D1 value.
       rts                              Return (note: RTS, not RTE)

; Simple function to subtract two longword values and return result.
; Pass values to be added in D0 and D1. Returns result in D2.
; Does not change D0 or D1.

sub    move.l d1,-(sp)                  Save original D1 value.
       sub.l  d0,d1                     Subtract values
       move.l d1,d2                     Store result in D2.
       move.l (sp)+,d1                  Restore original D1 value.
       rts                              Return (note: RTS, not RTE)

; Table for custom trap functions. Table entries are in the format
; $UUSSSSSS where UU is the function number and SSSSSS is the address
; of the routine.

        align 1                         Align on word boundary
NEWTBL  DC.L    ADD<<24+add             Table entry for ADD.
        DC.L    SUB<<24+sub             Table entry for SUB
ENDTBL  DS.L    1                       Link to old table will be stored here.
