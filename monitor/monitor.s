*        TSBUG2 - 68000 monitor - version of 23 July 1986
*                                   Symbol equates
         .org     0x00000000
BS       =        0x08              | Back_space
CR       =        0x0D              | Carriage_return
LF       =        0x0A              | Line_feed
SPACE    =        0x20              | Space
WAIT     =        'W'               | Wait character (to suspend output)
ESC      =        0x1B              | ASCII escape character (used by TM)
CTRL_A   =        0x01              | Control_A forces return to monitor
*                                   | Device addresses
STACK    =        0x00000800        | Stack_pointer
ACIA_1   =        0x00010040        | Console ACIA control
ACIA_2   =        ACIA_1+1          | Auxilary ACIA control
X_BASE   =        0x08              | Start of exception vector table
TRAP_14  =        0x4E4E            | Code for TRAP #14
MAXCHR   =        64                | Length of input line buffer
*
DATA     =        0x00000C00        | Data origin
LNBUFF   =        0x00000000        | Input line buffer (MAXCHR bytes)
BUFFEND  =        LNBUFF+MAXCHR-1   | End of line buffer
BUFFPT   =        0x00000040        | Pointer to line buffer (4 bytes)
PARAMTR  =        0x00000044        | Last parameter from line buffer (4 bytes)
ECHO     =        0x00000048        | When clear this enable input echo (1 byte)
U_CASE   =        0x00000049        | Flag for upper case conversion (1 byte)
UTAB     =        0x0000004A        | Pointer to user command table (4 bytes)
CN_IVEC  =        0x0000004E        | Pointer to console input DCB (4 bytes)
CN_OVEC  =        0x00000052        | Pointer to console output DCB (4 bytes)
TSK_T    =        0x00000056        | Frame for D0-D7, A0-A6, USP, SSP, SW, PC (37*2 bytes)
BP_TAB   =        0x000000A0        | Breakpoint table (24*2 bytes)
FIRST    =        0x000000D0        | DCB area (512*2 bytes)
BUFFER   =        0x000002D0        | 256 bytes for I/O buffer (256*2 bytes)
*
*************************************************************************
*
*  This is the main program which assembles a command in the line
*  buffer, removes leading/embedded spaces and interprets it by matching
*  it with a command in the user table or the built-in table COMTAB
*  All variables are specified with respect to A6
*
         .org     0x00008000        | Monitor origin
         .long    STACK             | Reset stack pointer
         RESET = 0x00008008
         .long    RESET             | Reset vector
RESET:                              | Cold entry point for monitor
         LEA      DATA,%A6          | A6 points to data area
         CLR.L    UTAB(%A6)         | Reset pointer to user extension table
         CLR.B    ECHO(%A6)         | Set automatic character echo
         CLR.B    U_CASE(%A6)       | Clear case conversion flag (UC<-LC)
         BSR.S    SETACIA           | Setup ACIAs
         BSR      X_SET             | Setup exception table
         BSR      SET_DCB           | Setup DCB table in RAM
         LEA.L    BANNER(%PC),%A4   | Point to banner
         BSR.S    HEADING           | and print heading
         MOVE.L   #0x0000C000,%A0   | A0 points to extension ROM
         MOVE.L   (%A0),%D0         | Read first longword in extension ROM
         CMP.L    #0x524F4D32,%D0   | If extension begins with 'ROM2' then
         BNE.S    NO_EXT            | call the subroutine at EXT_ROM+8
         JSR      8(%A0)            | else continue
NO_EXT:  NOP                        | Two NOPs to allow for a future
         NOP                        | call to an initialization routine
WARM:    CLR.L    %D7               | Warm entry point - clear error flag
         BSR.S    NEWLINE           | Print a newline
         BSR.S    GETLINE           | Get a command line
         BSR      TIDY              | Tidy up input buffer contents
         BSR      EXECUTE           | Interpret command
         BRA.S    WARM              | Repeat indefinitely
*
*************************************************************************
*
*  Some initialization and basic routines
*
SETACIA:                            | Setup ACIA parameters
         LEA.L    ACIA_1,%A0        | A0 points to console ACIA
         MOVE.B   #0x03,(%A0)       | Reset ACIA1
         MOVE.B   #0x03,1(%A0)      | Reset ACIA2
         MOVE.B   #0x15,(%A0)       | Set up ACIA1 constants (no IRQ,
         MOVE.B   #0x15,1(%A0)      | RTS* low, 8 bit, no parity, 1 stop)
         RTS                        | Return
*
NEWLINE:                            | Move cursor to start of newline
         MOVEM.L  %A4,-(%A7)        | Save A4
         LEA.L    CRLF(%PC),%A4     | Point to CR/LF string
         BSR.S    PSTRING           | Print it
         MOVEM.L  (%A7)+,%A4        | Restore A4
         RTS                        | Return
*
PSTRING:                            | Display the string pointed at by A4
         MOVE.L   %D0,-(%A7)        | Save D0
PS1:     MOVE.B   (%A4)+,%D0        | Get character to be printed
         BEQ.S    PS2               | If null then return
         BSR      PUTCHAR           | Else print it
         BRA.S    PS1               | Continue
PS2:     MOVE.L   (%A7)+,%D0        | Restore D0 and exit
         RTS
*
HEADING: BSR.S    NEWLINE           | Same as PSTRING but with newline
         BSR.S    PSTRING
         BRA.S    NEWLINE
*
*************************************************************************
*
*  GETLINE  inputs a string of characters into a line buffer
*           A3 points to next free entry in line buffer
*           A2 points to end of buffer
*           A1 points to start of buffer
*           D0 holds character to be stored
*
GETLINE: LEA.L    LNBUFF.W(%A6),%A1 | A1 points to start of line buffer
         LEA.L    (%A1),%A3         | A3 points to start (initially)
         LEA.L    MAXCHR.W(%A1),%A2 | A2 points to end of buffer
GETLN2:  BSR      GETCHAR           | Get a character
         CMP.B    #CTRL_A,%D0       | If control_A then reject this line
         BEQ.S    GETLN5            | and get another line
         CMP.B    #BS,%D0           | If back_space then move back pointer
         BNE.S    GETLN3            | Else skip past wind-back routine
         CMP.L    %A1,%A3           | First check for empty buffer
         BEQ.S    GETLN2            | If buffer empty then continue
         LEA      -1(%A3),%A3       | Else decrement buffer pointer
         BRA.S    GETLN2            | and continue with next character
GETLN3:  MOVE.B   %D0,(%A3)+        | Store character and update pointer
         CMP.B    #CR,%D0           | Test for command terminator
         BNE.S    GETLN4            | If not CR then skip past exit
         BRA.S    NEWLINE           | Else new line before next operation
GETLN4:  CMP.L    %A2,%A3           | Test for buffer overflow
         BNE.S    GETLN2            | If buffer not full then continue
GETLN5:  BSR.S    NEWLINE           | Else move to next line and
         BRA.S    GETLINE           | repeat this routine
*
*************************************************************************
*
*  TIDY cleans up the line buffer by removing leading spaces and multiple
*       spaces between parameters. At the end of TIDY, BUFFPT points to
*       the first parameter following the command.
*       A0 = pointer to line buffer. A1 = pointer to cleaned up buffer
*
TIDY:    LEA.L    LNBUFF.L(%A6),%A0 | A0 points to line buffer
         LEA.L    (%A0),%A1         | A1 points to start of line buffer
TIDY1:   MOVE.B   (%A0)+,%D0        | Read character from line buffer
         CMP.B    #SPACE,%D0        | Repeat until the first non-space
         BEQ.S    TIDY1             | character is found
         LEA.L    -1(%A0),%A0       | Move pointer back to first char
TIDY2:   MOVE.B   (%A0)+,%D0        | Move the string left to remove
         MOVE.B   %D0,(%A1)+        | any leading spaces
         CMP.B    #SPACE,%D0        | Test for embedded space
         BNE.S    TIDY4             | If not space then test for EOL
TIDY3:   CMP.B    #SPACE,(%A0)+     | If space skip multiple embedded
         BEQ.s    TIDY3             | spaces
         LEA.L    -1(%A0),%A0       | Move back pointer
TIDY4:   CMP.B    #CR,%D0           | Test for end_of_line (EOL)
         BNE.s    TIDY2             | If not EOL then read next char
         LEA.L    LNBUFF.w(%A6),%A0 | Restore buffer pointer
TIDY5:   CMP.B    #CR,(%A0)         | Test for EOL
         BEQ.S    TIDY6             | If EOL then exit
         CMP.B    #SPACE,(%A0)+     | Test for delimiter
         BNE.S    TIDY5             | Repeat until delimiter or EOL
TIDY6:   MOVE.L   %A0,BUFFPT(%A6)   | Update buffer pointer
         RTS
*
*************************************************************************
*
*  EXECUTE matches the first command in the line buffer with the
*  commands in a command table. An external table pointed at by
*  UTAB is searched first and then the in-built table, COMTAB.
*
EXECUTE: TST.L    UTAB(%A6)         | Test pointer to user table
         BEQ.S    EXEC1             | If clear then try built-in table
         MOVE.L   UTAB(%A6),%A3     | Else pick up pointer to user table
         BSR.S    SEARCH            | Look for command in user table
         BCC.S    EXEC1             | If not found then try internal table
         MOVE.L   (%A3),%A3         | Else get absolute address of command
         JMP      (%A3)             | from user table and execute it
*
EXEC1:   LEA.L    COMTAB(%PC),%A3   | Try built-in command table
         BSR.S    SEARCH            | Look for command in built-in table
         BCS.S    EXEC2             | If found then execute command
         LEA.L    ERMES2(%PC),%A4   | Else print "invalid command"
         BRA.W    PSTRING           | and return
EXEC2:   MOVE.L   (%A3),%A3         | Get the relative command address
         LEA.L    COMTAB(%PC),%A4   | pointed at by A3 and add it to
         ADD.L    %A4,%A3           | the PC to generate the actual
         JMP      (%A3)             | command address. Then execute it.
*
SEARCH:                             | Match the command in the line buffer
         CLR.L    %D0               | with command table pointed at by A3
         MOVE.B   (%A3),%D0         | Get the first character in the
         BEQ.S    SRCH7             | current entry. If zero then exit
         LEA.L    6(%A3,%D0.W),%A4  | Else calculate address of next entry
         MOVE.B   1(%A3),%D1        | Get number of characters to match
         LEA.L    LNBUFF.L(%A6),%A5 | A5 points to command in line buffer
         MOVE.B   2(%A3),%D2        | Get first character in this entry
         CMP.B    (%A5)+,%D2        | from the table and match with buffer
         BEQ.S    SRCH3             | If match then try rest of string
SRCH2:   MOVE.L   %A4,%A3           | Else get address of next entry
         BRA.S    SEARCH            | and try the next entry in the table
SRCH3:   SUB.B    #1,%D1            | One less character to match
         BEQ.S    SRCH6             | If match counter zero then all done
         LEA.L    3(%A3),%A3        | Else point to next character in table
SRCH4:   MOVE.B   (%A3)+,%D2        | Now match a pair of characters
         CMP.B    (%A5)+,%D2
         BNE.S    SRCH2             | If no match then try next entry
         SUB.B    #1,%D1            | Else decrement match counter and
         BNE.S    SRCH4             | repeat until no chars left to match
SRCH6:   LEA.L    -4(%A4),%A3       | Calculate address of command entry
         OR.B     #1,%CCR           | point. Mark carry flag as success
         RTS                        | and return
SRCH7:   AND.B    #0xFE,%CCR        | Fail - clear carry to indicate
         RTS                        | command not found and return
*
*************************************************************************
*
*  Basic input routines
*  HEX    =  Get one   hexadecimal character  into D0
*  BYTE   =  Get two   hexadecimal characters into D0
*  WORD   =  Get four  hexadecimal characters into D0
*  LONGWD =  Get eight hexadecimal characters into D0
*  PARAM  =  Get a longword from the line buffer into D0
*  Bit 0 of D7 is set to indicate a hexadecimal input error
*
HEX:     BSR      GETCHAR           | Get a character from input device
         SUB.B    #0x30,%D0         | Convert to binary
         BMI.S    NOT_HEX           | If less than $30 then exit with error
         CMP.B    #0x09,%D0         | Else test for number (0 to 9)
         BLE.S    HEX_OK            | If number then exit - success
         SUB.B    #0x07,%D0         | Else convert letter to hex
         CMP.B    #0x0F,%D0         | If character in range "A" to "F"
         BLE.S    HEX_OK            | then exit successfully
NOT_HEX: OR.B     #1,%D7            | Else set error flag
HEX_OK:  RTS                        | and return
*
BYTE:    MOVE.L   %D1,-(%A7)        | Save D1
         BSR.S    HEX               | Get first hex character
         ASL.B    #4,%D0            | Move it to MS nybble position
         MOVE.B   %D0,%D1           | Save MS nybble in D1
         BSR.S    HEX               | Get second hex character
         ADD.B    %D1,%D0           | Merge MS and LS nybbles
         MOVE.L   (%A7)+,%D1        | Restore D1
         RTS
*
WORD:    BSR.S    BYTE              | Get upper order byte
         ASL.W    #8,%D0            | Move it to MS position
         BRA.S    BYTE              | Get LS byte and return
*
LONGWD:  BSR.S    WORD              | Get upper order word
         SWAP     %D0               | Move it to MS position
         BRA.S    WORD              | Get lower order word and return
*
*  PARAM reads a parameter from the line buffer and puts it in both
*  PARAMTR(A6) and D0. Bit 1 of D7 is set on error.
*
PARAM:   MOVE.L   %D1,-(%A7)        | Save D1
         CLR.L    %D1               | Clear input accumulator
         MOVE.L   BUFFPT(%A6),%A0   | A0 points to parameter in buffer
PARAM1:  MOVE.B   (%A0)+,%D0        | Read character from line buffer
         CMP.B    #SPACE,%D0        | Test for delimiter
         BEQ.S    PARAM4            | The permitted delimiter is a
         CMP.B    #CR,%D0           | space or a carriage return
         BEQ.S    PARAM4            | Exit on either space or C/R
         ASL.L    #4,%D1            | Shift accumulated result 4 bits left
         SUB.B    #0x30,%D0         | Convert new character to hex
         BMI.S    PARAM5            | If less than $30 then not-hex
         CMP.B    #0x09,%D0         | If less than 10
         BLE.S    PARAM3            | then continue
         SUB.B    #0x07,%D0         | Else assume $A - $F
         CMP.B    #0x0F,%D0         | If more than $F
         BGT.S    PARAM5            | then exit to error on not-hex
PARAM3:  ADD.B    %D0,%D1           | Add latest nybble to total in D1
         BRA.S    PARAM1            | Repeat until delimiter found
PARAM4:  MOVE.L   %A0,BUFFPT(%A6)   | Save pointer in memory
         MOVE.L   %D1,PARAMTR(%A6)  | Save parameter in memory
         MOVE.L   %D1,%D0           | Put parameter in D0 for return
         BRA.S    PARAM6            | Return without error
PARAM5:  OR.B     #2,%D7            | Set error flag before return
PARAM6:  MOVE.L   (%A7)+,%D1        | Restore working register
         RTS                        | Return with error
*
*************************************************************************
*
*  Output routines
*  OUT1X   = print one   hexadecimal character
*  OUT2X   = print two   hexadecimal characters
*  OUT4X   = print four  hexadecimal characters
*  OUT8X   = print eight hexadecimal characters
*  In each case, the data to be printed is in D0
*
OUT1X:   MOVE.W   %D0,-(%A7)        | Save D0
         AND.B    #0x0F,%D0         | Mask off MS nybble
         ADD.B    #0x30,%D0         | Convert to ASCII
         CMP.B    #0x39,%D0         | ASCII = HEX + $30
         BLS.S    OUT1X1            | If ASCII <= $39 then print and exit
         ADD.B    #0x07,%D0         | Else ASCII := HEX + 7
OUT1X1:  BSR      PUTCHAR           | Print the character
         MOVE.W   (%A7)+,%D0        | Restore D0
         RTS
*
OUT2X:   ROR.B    #4,%D0            | Get MS nybble in LS position
         BSR.S    OUT1X             | Print MS nybble
         ROL.B    #4,%D0            | Restore LS nybble
         BRA.S    OUT1X             | Print LS nybble and return
*
OUT4X:   ROR.W    #8,%D0            | Get MS byte in LS position
         BSR.S    OUT2X             | Print MS byte
         ROL.W    #8,%D0            | Restore LS byte
         BRA.S    OUT2X             | Print LS byte and return
*
OUT8X:   SWAP     %D0               | Get MS word in LS position
         BSR.S    OUT4X             | Print MS word
         SWAP     %D0               | Restore LS word
         BRA.S    OUT4X             | Print LS word and return
*
*************************************************************************
*
* JUMP causes execution to begin at the address in the line buffer
*
JUMP:    BSR.S   PARAM              | Get address from buffer
         TST.B   %D7                | Test for input error
         BNE.S   JUMP1              | If error flag not zero then exit
         TST.L   %D0                | Else test for missing address
         BEQ.S   JUMP1              | field. If no address then exit
         MOVE.L  %D0,%A0            | Put jump address in A0 and call the
         JMP     (%A0)              | subroutine. User to supply RTS!!
JUMP1:   LEA.L   ERMES1(%PC),%A4    | Here for error - display error
         BRA     PSTRING            | message and return
*
*************************************************************************
*
*  Display the contents of a memory location and modify it
*
MEMORY:  BSR      PARAM             | Get start address from line buffer
         TST.B    %D7               | Test for input error
         BNE.S    MEM3              | If error then exit
         MOVE.L   %D0,%A3           | A3 points to location to be opened
MEM1:    BSR      NEWLINE
         BSR.S    ADR_DAT           | Print current address and contents
         BSR.S    PSPACE            |  update pointer, A3, and O/P space
         BSR      GETCHAR           | Input char to decide next action
         CMP.B    #CR,%D0           | If carriage return then exit
         BEQ.S    MEM3              | Exit
         CMP.B    #'-',%D0          | If "-" then move back
         BNE.S    MEM2              | Else skip wind-back procedure
         LEA.L    -4(%A3),%A3       | Move pointer back 2+2
         BRA.S    MEM1              | Repeat until carriage return
MEM2:    CMP.B    #SPACE,%D0        | Test for space (= new entry)
         BNE.S    MEM1              | If not space then repeat
         BSR      WORD              | Else get new word to store
         TST.B    %D7               | Test for input error
         BNE.S    MEM3              | If error then exit
         MOVE.W   %D0,-2(%A3)       | Store new word
         BRA.S    MEM1              | Repeat until carriage return
MEM3:    RTS
*
ADR_DAT: MOVE.L   %D0,-(%A7)        | Print the contents of A3 and the
         MOVE.L   %A3,%D0           | word pointed at by A3.
         BSR.S    OUT8X             |  and print current address
         BSR.S    PSPACE            | Insert delimiter
         MOVE.W   (%A3),%D0         | Get data at this address in D0
         BSR.S    OUT4X             |  and print it
         LEA.L    2(%A3),%A3        | Point to next address to display
         MOVE.L   (%A7)+,%D0        | Restore D0
         RTS
*
PSPACE:  MOVE.B   %D0,-(%A7)        | Print a single space
         MOVE.B   #SPACE,%D0
         BSR      PUTCHAR
         MOVE.B   (%A7)+,%D0
         RTS
*
*************************************************************************
*
*  LOAD  Loads data formatted in hexadecimal "S" format from Port 2
*        NOTE - I/O is automatically redirected to the aux port for
*        loader functions. S1 or S2 records accepted
*
LOAD:    MOVE.L   CN_OVEC(%A6),-(%A7) | Save current output device name
         MOVE.L   CN_IVEC(%A6),-(%A7) | Save current input device name
         DCB4 = 0x00008c22            | Works around GNU assembler issue
         MOVE.L   #DCB4,CN_OVEC(%A6)  | Set up aux ACIA as output
         DCB3 = 0x00008c10            | Works around GNU assembler issue
         MOVE.L   #DCB3,CN_IVEC(%A6)  | Set up aux ACIA as input
         ADD.B    #1,ECHO(%A6)        | Turn off character echo
         BSR      NEWLINE             | Send newline to host
         BSR      DELAY               | Wait for host to "settle"
         BSR      DELAY
         MOVE.L   BUFFPT(%A6),%A4     | Any string in the line buffer is
LOAD1:   MOVE.B   (%A4)+,%D0          | transmitted to the host computer
         BSR      PUTCHAR             | before the loading begins
         CMP.B    #CR,%D0             | Read from the buffer until EOL
         BNE.S    LOAD1
         BSR      NEWLINE             | Send newline before loading
LOAD2:   BSR      GETCHAR             | Records from the host must begin
         CMP.B    #'S',%D0            | with S1/S2 (data) or S9/S8 (term)
         BNE.S    LOAD2               | Repeat GETCHAR until char = "S"
         BSR      GETCHAR             | Get character after "S"
         CMP.B    #'9',%D0            | Test for the two terminators S9/S8
         BEQ.S    LOAD3               | If S9 record then exit else test
         CMP.B    #'8',%D0            | for S8 terminator. Fall through to
         BNE.S    LOAD6               | exit on S8 else continue search
LOAD3:                                | Exit point from LOAD
         MOVE.L   (%A7)+,CN_IVEC(%A6) | Clean up by restoring input device
         MOVE.L   (%A7)+,CN_OVEC(%A6) | and output device name
         CLR.B    ECHO(%A6)           | Restore input character echo
         BTST.B   #0,%D7              | Test for input errors
         BEQ.S    LOAD4               | If no I/P error then look at checksum
         LEA.L    ERMES1(%PC),%A4     | Else point to error message
         BSR      PSTRING             | Print it
LOAD4:   BTST.B   #3,%D7              | Test for checksum error
         BEQ.S    LOAD5               | If clear then exit
         LEA.L    ERMES3(%PC),%A4     | Else point to error message
         BSR      PSTRING             | Print it and return
LOAD5:   RTS
*
LOAD6:   CMP.B    #'1',%D0            | Test for S1 record
         BEQ.S    LOAD6A              | If S1 record then read it
         CMP.B    #'2',%D0            | Else test for S2 record
         BNE.S    LOAD2               | Repeat until valid header found
         CLR.B    %D3                 | Read the S2 byte count and address,
         BSR.S    LOAD8               | clear the checksum
         SUB.B    #4,%D0              | Calculate size of data field
         MOVE.B   %D0,%D2             | D2 contains data bytes to read
         CLR.L    %D0                 | Clear address accumulator
         BSR.S    LOAD8               | Read most sig byte of address
         ASL.L    #8,%D0              | Move it one byte left
         BSR.S    LOAD8               | Read the middle byte of address
         ASL.L    #8,%D0              | Move it one byte left
         BSR.S    LOAD8               | Read least sig byte of address
         MOVE.L   %D0,%A2             | A2 points to destination of record
         BRA.S    LOAD7               | Skip past S1 header loader
LOAD6A:  CLR.B    %D3                 | S1 record found - clear checksum
         BSR.S    LOAD8               | Get byte and update checksum
         SUB.B    #3,%D0              | Subtract 3 from record length
         MOVE.B   %D0,%D2             | Save byte count in D2
         CLR.L    %D0                 | Clear address accumulator
         BSR.S    LOAD8               | Get MS byte of load address
         ASL.L    #8,%D0              | Move it to MS position
         BSR.S    LOAD8               | Get LS byte in D2
         MOVE.L   %D0,%A2             | A2 points to destination of data
LOAD7:   BSR.S    LOAD8               | Get byte of data for loading
         MOVE.B   %D0,(%A2)+          | Store it
         SUB.B    #1,%D2              | Decrement byte counter
         BNE.S    LOAD7               | Repeat until count = 0
         BSR.S    LOAD8               | Read checksum
         ADD.B    #1,%D3              | Add 1 to total checksum
         BEQ      LOAD2               | If zero then start next record
         OR.B     #0b00001000,%D7     | Else set checksum error bit,
         BRA.S    LOAD3               | restore I/O devices and return
*
LOAD8:   BSR     BYTE                 | Get a byte
         ADD.B   %D0,%D3              | Update checksum
         RTS                          |  and return
*
*************************************************************************
*
*  DUMP   Transmit S1 formatted records to host computer
*         A3 = Starting address of data block
*         A2 = End address of data block
*         D1 = Checksum, D2 = current record length
*
DUMP:    BSR      RANGE               | Get start and end address
         TST.B    %D7                 | Test for input error
         BEQ.S    DUMP1               | If no error then continue
         LEA.L    ERMES1(%PC),%A4     | Else point to error message,
         BRA      PSTRING             | print it and return
DUMP1:   CMP.L    %A3,%D0             | Compare start and end addresses
         BPL.S    DUMP2               | If positive then start < end
         LEA.L    ERMES7(%PC),%A4     | Else print error message
         BRA      PSTRING             | and return
DUMP2:   MOVE.L   CN_OVEC(%A6),-(%A7) | Save name of current output device
         MOVE.L   #DCB4,CN_OVEC(%A6)  | Set up Port 2 as output device
         BSR      NEWLINE             | Send newline to host and wait
         BSR.S    DELAY
         MOVE.L   BUFFPT(%A6),%A4     | Before dumping, send any string
DUMP3:   MOVE.B   (%A4)+,%D0          | in the input buffer to the host
         BSR      PUTCHAR             | Repeat
         CMP.B    #CR,%D0             | Transmit char from buffer to host
         BNE.S    DUMP3               | Until char = C/R
         BSR      NEWLINE
         BSR.S    DELAY               | Allow time for host to settle
         ADDQ.L   #1,%A2              | A2 contains length of record + 1
DUMP4:   MOVE.L   %A2,%D2             | D2 points to end address
         SUB.L    %A3,%D2             | D2 contains bytes left to print
         CMP.L    #17,%D2             | If this is not a full record of 16
         BCS.S    DUMP5               | then load D2 with record size
         MOVEQ    #16,%D2             | Else preset byte count to 16
DUMP5:   LEA.L    HEADER(%PC),%A4     | Point to record header
         BSR      PSTRING             | Print header
         CLR.B    %D1                 | Clear checksum
         MOVE.B   %D2,%D0             | Move record length to output register
         ADD.B    #3,%D0              | Length includes address + count
         BSR.S    DUMP7               | Print number of bytes in record
         MOVE.L   %A3,%D0             | Get start address to be printed
         ROL.W    #8,%D0              | Get MS byte in LS position
         BSR.S    DUMP7               | Print MS byte of address
         ROR.W    #8,%D0              | Restore LS byte
         BSR.S    DUMP7               | Print LS byte of address
DUMP6:   MOVE.B   (%A3)+,%D0          | Get data byte to be printed
         BSR.S    DUMP7               | Print it
         SUB.B    #1,%D2              | Decrement byte count
         BNE.S    DUMP6               | Repeat until all this record printed
         NOT.B    %D1                 | Complement checksum
         MOVE.B   %D1,%D0             | Move to output register
         BSR.S    DUMP7               | Print checksum
         BSR      NEWLINE
         CMP.L    %A2,%A3             | Have all records been printed?
         BNE.S    DUMP4               | Repeat until all done
         LEA.L    TAIL(%PC),%A4       | Point to message tail (S9 record)
         BSR      PSTRING             | Print it
         MOVE.L   (%A7)+,CN_OVEC(%A6) | Restore name of output device
         RTS                          | and return
*
DUMP7:   ADD.B    %D0,%D1             | Update checksum, transmit byte
         BRA      OUT2X               | to host and return
*
RANGE:                                | Get the range of addresses to be
         CLR.B    %D7                 | transmitted from the buffer
         BSR      PARAM               | Get starting address
         MOVE.L   %D0,%A3             | Set up start address in A3
         BSR      PARAM               | Get end address
         MOVE.L   %D0,%A2             | Set up end address in A2
         RTS
*
DELAY:                                | Provide a time delay for the host
         MOVEM.L   %D0/%A4,-(%A7)     | to settle. Save working registers
         MOVE.L    #0x4000,%D0        | Set up delay constant
DELAY1:  SUB.L     #1,%D0             | Count down         (8 clk cycles)
         BNE.S     DELAY1             | Repeat until zero  (10 clk cycles)
         MOVEM.L   (%A7)+,%D0/%A4     | Restore working registers
         RTS
*
*************************************************************************
*
*  TM  Enter transparant mode (All communication to go from terminal to
*  the host processor until escape sequence entered). End sequence
*  = ESC, E. A newline is sent to the host to "clear it down".
*
TM:      MOVE.B    #0x55,ACIA_1        | Force RTS* high to re-route data
         ADD.B     #1,ECHO(%A6)        | Turn off character echo
TM1:     BSR       GETCHAR             | Get character
         CMP.B     #ESC,%D0            | Test for end of TM mode
         BNE.S     TM1                 | Repeat until first escape character
         BSR       GETCHAR             | Get second character
         CMP.B     #'E',%D0            | If second char = E then exit TM
         BNE.S     TM1                 | Else continue
         MOVE.L    CN_OVEC(%A6),-(%A7) |  Save output port device name
         MOVE.L    #DCB4,CN_OVEC(%A6)  |  Get name of host port (aux port)
         BSR       NEWLINE             | Send newline to host to clear it
         MOVE.L    (%A7)+,CN_OVEC(%A6) | Restore output device port name
         CLR.B     ECHO(%A6)           | Restore echo mode
         MOVE.B    #0x15,ACIA_1        | Restore normal ACIA mode (RTS* low)
         RTS
*
*************************************************************************
*
*  This routine sets up the system DCBs in RAM using the information
*  stored in ROM at address DCB_LST. This is called at initialization.
*  CN_IVEC contains the name "DCB1" and IO_VEC the name "DCB2"
*
SET_DCB: MOVEM.L %A0-%A3/%D0-%D3,-(%A7) | Save all working registers
         LEA.L   FIRST(%A6),%A0    | Pointer to first DCB destination in RAM
         LEA.L   DCB_LST(%PC),%A1  | A1 points to DCB info block in ROM
         MOVE.W  #5,%D0            | 6 DCBs to set up
ST_DCB1: MOVE.W  #15,%D1           | 16 bytes to move per DCB header
ST_DCB2: MOVE.B  (%A1)+,(%A0)+     | Move the 16 bytes of a DCB header
         DBRA    %D1,ST_DCB2       | from ROM to RAM
         MOVE.W  (%A1)+,%D3        | Get size of parameter block (bytes)
         MOVE.W  %D3,(%A0)         | Store size in DCB in RAM
         LEA.L   2(%A0,%D3.W),%A0  | A0 points to tail of DCB in RAM
         LEA.L   4(%A0),%A3        | A3 contains address of next DCB in RAM
         MOVE.L  %A3,(%A0)         | Store pointer to next DCB in this DCB
         LEA.L   (%A3),%A0         | A0 now points at next DCB in RAM
         DBRA    %D0,ST_DCB1       | Repeat until all DCBs set up
         LEA.L   -4(%A3),%A3       | Adjust A3 to point to last DCB pointer
         CLR.L   (%A3)             | and force last pointer to zero
         DCB1 = 0x00008bec         | Works around GNU assembler issue
         MOVE.L  #DCB1,CN_IVEC(%A6) | Set up vector to console input DCB
         DCB2 = 0x00008bfe         | Works around GNU assembler issue
         MOVE.L  #DCB2,CN_OVEC(%A6) | Set up vector to console output DCB
         MOVEM.L (%A7)+,%A0-%A3/%D0-%D3 | Restore registers
         RTS
*
*************************************************************************
*
*  IO_REQ handles all input/output transactions. A0 points to DCB on
*  entry. IO_REQ calls the device driver whose address is in the DCB.
*
IO_REQ:  MOVEM.L %A0-%A1,-(%A7)   | Save working registers
         LEA.L   8(%A0),%A1       | A1 points to device handler field in DCB
         MOVE.L  (%A1),%A1        | A1 contains device handler address
         JSR     (%A1)            | Call device handler
         MOVEM.L (%A7)+,%A0-%A1   | Restore working registers
         RTS
*
*************************************************************************
*
*  CON_IN handles input from the console device
*  This is the device driver used by DCB1. Exit with input in D0
*
CON_IN:  MOVEM.L %D1/%A1,-(%A7)   | Save working registers
         LEA.L   12(%A0),%A1      | Get pointer to ACIA from DCB
         MOVE.L  (%A1),%A1        | Get address of ACIA in A1
         CLR.B   19(%A0)          | Clear logical error in DCB
CON_I1:  MOVE.B  (%A1),%D1        | Read ACIA status
         BTST.B  #0,%D1           | Test RDRF
         BEQ.S   CON_I1           | Repeat until RDRF true
         MOVE.B  %D1,18(%A0)      | Store physical status in DCB
         AND.B   #0b011110100,%D1 | Mask to input error bits
         BEQ.S   CON_I2           | If no error then skip update
         MOVE.B  #1,19(%A0)       | Else update logical error
CON_I2:  MOVE.B  2(%A1),%D0       | Read input from ACIA
         MOVEM.L (%A7)+,%A1/%D1   | Restore working registers
         RTS
*
*************************************************************************
*
*   This is the device driver used by DCB2. Output in D0
*   The output can be halted or suspended
*
CON_OUT: MOVEM.L %A1/%D1-%D2,-(%A7) | Save working registers
         LEA.L   12(%A0),%A1        | Get pointer to ACIA from DCB
         MOVE.L  (%A1),%A1          | Get address of ACIA in A1
         CLR.B   19(%A0)            | Clear logical error in DCB
CON_OT1: MOVE.B  (%A1),%D1          | Read ACIA status
         BTST.B  #0,%D1             | Test RDRF bit (any input?)
         BEQ.S   CON_OT3            | If no input then test output status
         MOVE.B  2(%A1),%D2         | Else read the input
         AND.B   #0b01011111,%D2    | Strip parity and bit 5
         CMP.B   #WAIT,%D2          | and test for a wait condition
         BNE.S   CON_OT3            | If not wait then ignore and test O/P
CON_OT2: MOVE.B  (%A1),%D2          | Else read ACIA status register
         BTST.B  #0,%D2             | and poll ACIA until next char received
         BEQ.S   CON_OT2
CON_OT3: BTST.B  #1,%D1             | Repeat
         BEQ.S   CON_OT1            |  until ACIA Tx ready
         MOVE.B  %D1,18(%A0)        | Store status in DCB physical error
         MOVE.B  %D0,2(%A1)         | Transmit output
         MOVEM.L (%A7)+,%A1/%D1-%D2 | Restore working registers
         RTS
*
*************************************************************************
*
*  AUX_IN and AUX_OUT are simplified versions of CON_IN and
*  CON_OUT for use with the port to the host processor
*
AUX_IN:  LEA.L   12(%A0),%A1     | Get pointer to aux ACIA from DCB
         MOVE.L  (%A1),%A1       | Get address of aux ACIA
AUX_IN1: BTST.B  #0,(%A1)        | Test for data ready
         BEQ.S   AUX_IN1         | Repeat until ready
         MOVE.B  2(%A1),%D0      | Read input
         RTS
*
AUX_OUT: LEA.L   12(%A0),%A1     | Get pointer to aux ACIA from DCB
         MOVE.L  (%A1),%A1       | Get address of aux ACIA
AUX_OT1: BTST.B  #1,(%A1)        | Test for ready to transmit
         BEQ.S   AUX_OT1         | Repeat until transmitter ready
         MOVE.B  %D0,2(%A1)      | Transmit data
         RTS
*
*************************************************************************
*
*  GETCHAR gets a character from the console device
*  This is the main input routine and uses the device whose name
*  is stored in CN_IVEC. Changing this name redirects input.
*
GETCHAR: MOVE.L  %A0,-(%A7)       | Save working register
         MOVE.L  CN_IVEC(%A6),%A0 | A0 points to name of console DCB
         BSR.S   IO_OPEN          | Open console (get DCB address in A0)
         BTST.B  #3,%D7           | D7(3) set if open error
         BNE.S   GETCH3           | If error then exit now
         BSR     IO_REQ           | Else execute I/O transaction
         AND.B   #0x7F,%D0        | Strip msb of input
         TST.B   U_CASE(%A6)      | Test for upper -> lower case conversion
         BNE.S   GETCH2           | If flag not zero do not convert case
         BTST.B  #6,%D0           | Test input for lower case
         BEQ.S   GETCH2           | If upper case then skip conversion
         AND.B   #0b11011111,%D0  | Else clear bit 5 for upper case conv
GETCH2:  TST.B   ECHO(%A6)        | Do we need to echo the input?
         BNE.S   GETCH3           | If ECHO not zero then no echo
         BSR.S   PUTCHAR          | Else echo the input
GETCH3:  MOVE.L  (%A7)+,%A0       | Restore working register
         RTS                      | and return
*
*************************************************************************
*
*  PUTCHAR sends a character to the console device
*  The name of the output device is in CN_OVEC.
*
PUTCHAR: MOVE.L  %A0,-(%A7)       | Save working register
         MOVE.L  CN_OVEC(%A6),%A0 | A0 points to name of console output
         BSR.S   IO_OPEN          | Open console (Get address of DCB)
         BSR     IO_REQ           | Perform output with DCB pointed at by A0
         MOVE.L  (%A7)+,%A0       | Restore working register
         RTS
*
*************************************************************************
*
*  BUFF_IN and BUFF_OUT are two rudimentary input and output routines
*  which input data from and output data to a buffer in RAM. These are
*  used by DCB5 and DCB6, respectively.
*
BUFF_IN: LEA.L   12(%A0),%A1       | A1 points to I/P buffer
         MOVE.L  (%A1),%A2         | A2 gets I/P pointer from buffer
         MOVE.B  -(%A2),%D0        | Read char from buffer and adjust A2
         MOVE.L  %A2,(%A1)         | Restore pointer in buffer
         RTS
*
BUFF_OT: LEA.L   12(%A0),%A1       | A1 points to O/P buffer
         MOVE.L  4(%A1),%A2        | A2 gets O/P pointer from buffer
         MOVE.B  %D0,(%A2)+        | Store char in buffer and adjust A2
         MOVE.L  %A2,(%A1)         | Restore pointer in buffer
         RTS
*
*************************************************************************
*
*  Open - opens a DCB for input or output. IO_OPEN converts the
*  name pointed at by A0 into the address of the DCB pointed at
*  by A0. Bit 3 of D7 is set to zero if DCB not found
*
IO_OPEN: MOVEM.L  %A1-%A3/%D0-%D4,-(%A7) | Save working registers
         LEA.L    FIRST(%A6),%A1   | A1 points to first DCB in chain in RAM
OPEN1:   LEA.L    (%A1),%A2        | A2 = temp copy of pointer to DCB
         LEA.L    (%A0),%A3        | A3 = temp copy of pointer to DCB name
         MOVE.W   #7,%D0           | Up to 8 chars of DCB name to match
OPEN2:   MOVE.B   (%A2)+,%D4       | Compare DCB name with string
         CMP.B    (%A3)+,%D4
         BNE.S    OPEN3            | If no match try next DCB
         DBRA     %D0,OPEN2        | Else repeat until all chars matched
         LEA.L    (%A1),%A0        | Success - move this DCB address to A0
         BRA.S    OPEN4            | and return
OPEN3:                             | Fail - calculate address of next DCB
         MOVE.W   16(%A1),%D1      | Get parameter block size of DCB
         LEA.L    18(%A1,%D1.W),%A1 | A1 points to pointer to next DCB
         MOVE.L   (%A1),%A1        | A1 now points to next DCB
         CMP.L    #0,%A1           | Test for end of DCB chain
         BNE.S    OPEN1            | If not end of chain then try next DCB
         OR.B     #8,%D7           | Else set error flag and return
OPEN4:   MOVEM.L  (%A7)+,%A1-%A3/%D0-%D4 | Restore working registers
         RTS
*
*************************************************************************
*
*  Exception vector table initialization routine
*  All vectors not setup are loaded with uninitialized routine vector
*
X_SET:  LEA.L   X_BASE,%A0         | Point to base of exception table
        MOVE.W  #253,%D0           | Number of vectors -  3
        X_UN = 0x000089e4          | Works around GNU assembler issue
X_SET1: MOVE.L  #X_UN,(%A0)+       | Store uninitialized exception vector
        DBRA    %D0,X_SET1         | Repeat until all entries preset
        SUB.L   %A0,%A0            | Clear A0 (points to vector table)
        BUS_ER = 0x000087b4        | Works around GNU assembler issue
        MOVE.L  #BUS_ER,8(%A0)     | Setup bus error vector
        ADD_ER = 0x000087c2        | Works around GNU assembler issue
        MOVE.L  #ADD_ER,12(%A0)    | Setup address error vector
        IL_ER = 0x0000879e         | Works around GNU assembler issue
        MOVE.L  #IL_ER,16(%A0)     | Setup illegal instruction error vect
        TRACE = 0x00008898         | Works around GNU assembler issue
        MOVE.L  #TRACE,36(%A0)     | Setup trace exception vector
        TRAP_0 = 0x00008652        | Works around GNU assembler issue
        MOVE.L  #TRAP_0,128(%A0)   | Setup TRAP #0 exception vector
        BRKPT = 0x000087d0         | Works around GNU assembler issue
        MOVE.L  #BRKPT,184(%A0)    | Setup TRAP #14 vector = breakpoint
        AWARM = 0x00008040         | Works around GNU assembler issue
        MOVE.L  #AWARM,188(%A0)    | Setup TRAP #15 exception vector
        MOVE.W  #7,%D0             | Now clear the breakpoint table
        LEA.L   BP_TAB(%A6),%A0    | Point to table
X_SET2: CLR.L   (%A0)+             | Clear an address entry
        CLR.W   (%A0)+             | Clear the corresponding data
        DBRA    %D0,X_SET2         | Repeat until all 8 cleared
        RTS
*
*************************************************************************
*
TRAP_0:                           | User links to  TS2BUG via TRAP #0
        CMP.B   #0,%D1            | D1 = 0 = Get character
        BNE.S   TRAP1
        BSR     GETCHAR
        RTE
TRAP1:  CMP.B   #1,%D1            | D1 = 1 = Print character
        BNE.S   TRAP2
        BSR     PUTCHAR
        RTE
TRAP2:  CMP.B   #2,%D1            | D1 = 2 = Newline
        BNE.S   TRAP3
        BSR     NEWLINE
        RTE
TRAP3:  CMP.B   #3,%D1            | D1 = 3 = Get parameter from buffer
        BNE.S   TRAP4
        BSR     PARAM
        RTE
TRAP4:  CMP.B   #4,%D1            | D1 = 4 = Print string pointed at by A4
        BNE.S   TRAP5
        BSR     PSTRING
        RTE
TRAP5:  CMP.B   #5,%D1            | D1 = 5 = Get a hex character
        BNE.S   TRAP6
        BSR     HEX
        RTE
TRAP6:  CMP.B   #6,%D1            | D1 = 6 = Get a hex byte
        BNE.S   TRAP7
        BSR     BYTE
        RTE
TRAP7:  CMP.B   #7,%D1            | D1 = 7 = Get a word
        BNE.S   TRAP8
        BSR     WORD
        RTE
TRAP8:  CMP.B   #8,%D1            | D1 = 8 = Get a longword
        BNE.S   TRAP9
        BSR     LONGWD
        RTE
TRAP9:  CMP.B   #9,%D1            | D1 = 9 = Output hex byte
        BNE.S   TRAP10
        BSR     OUT2X
        RTE
TRAP10: CMP.B   #10,%D1           | D1 = 10 = Output hex word
        BNE.S   TRAP11
        BSR     OUT4X
        RTE
TRAP11: CMP.B   #11,%D1           | D1 = 11 = Output hex longword
        BNE.S   TRAP12
        BSR     OUT8X
        RTE
TRAP12: CMP.B   #12,%D1           | D1 = 12 = Print a space
        BNE.S   TRAP13
        BSR     PSPACE
        RTE
TRAP13: CMP.B   #13,%D1           | D1 = 13 = Get a line of text into
        BNE.S   TRAP14            | the line buffer
        BSR     GETLINE
        RTE
TRAP14: CMP.B   #14,%D1           | D1 = 14 = Tidy up the line in the
        BNE.S   TRAP15            | line buffer by removing leading
        BSR     TIDY              | leading and multiple embeded spaces
        RTE
TRAP15: CMP.B   #15,%D1           | D1 = 15 = Execute the command in
        BNE.S   TRAP16            | the line buffer
        BSR     EXECUTE
        RTE
TRAP16: CMP.B   #16,%D1           | D1 = 16 = Call RESTORE to transfer
        BNE.S   TRAP17            | the registers in TSK_T to the 68000
        BSR     RESTORE           | and therefore execute a program
        RTE
TRAP17: RTE
*
*************************************************************************
*
*  Display exception frame (D0 - D7, A0 - A6, USP, SSP, SR, PC)
*  EX_DIS prints registers saved after a breakpoint or exception
*  The registers are saved in TSK_T
*
EX_DIS: LEA.L   TSK_T(%A6),%A5    | A5 points to display frame
        LEA.L   MES3(%PC),%A4     | Point to heading
        BSR     HEADING           | and print it
        MOVE.W  #7,%D6            | 8 pairs of registers to display
        CLR.B   %D5               | D5 is the line counter
EX_D1:  MOVE.B  %D5,%D0           | Put current register number in D0
        BSR     OUT1X             | and print it
        BSR     PSPACE            | and a space
        ADD.B   #1,%D5            | Update counter for next pair
        MOVE.L  (%A5),%D0         | Get data register to be displayed
        BSR     OUT8X             | from the frame and print it
        LEA.L   MES4(%PC),%A4     | Print string of spaces
        BSR.W   PSTRING           | between data and address registers
        MOVE.L  32(%A5),%D0       | Get address register to be displayed
        BSR     OUT8X             | which is 32 bytes on from data reg
        BSR     NEWLINE
        LEA.L   4(%A5),%A5        | Point to next pair (ie Di, Ai)
        DBRA    %D6,EX_D1         | Repeat until all displayed
        LEA.L   32(%A5),%A5       | Adjust pointer by 8 longwords
        BSR     NEWLINE           | to point to SSP
        LEA.L   MES2A(%PC),%A4    | Point to "SS ="
        BSR     PSTRING           | Print it
        MOVE.L  (%A5)+,%D0        | Get SSP from frame
        BSR     OUT8X             | and display it
        BSR     NEWLINE
        LEA.L   MES1(%PC),%A4     | Point to 'SR ='
        BSR     PSTRING           | Print it
        MOVE.W  (%A5)+,%D0        | Get status register
        BSR     OUT4X             | Display status
        BSR     NEWLINE
        LEA.L   MES2(%PC),%A4     | Point to 'PC ='
        BSR     PSTRING           | Print it
        MOVE.L  (%A5)+,%D0        | Get PC
        BSR     OUT8X             | Display PC
        BRA     NEWLINE           | Newline and return
*
*************************************************************************
*
*  Exception handling routines
*
IL_ER:                            | Illegal instruction exception
        MOVE.L  %A4,-(%A7)        | Save A4
        LEA.L   MES10(%PC),%A4    | Point to heading
        BSR     HEADING           | Print it
        MOVE.L  (%A7)+,%A4        | Restore A4
        BSR.S   GROUP2            | Save registers in display frame
        BSR     EX_DIS            | Display registers saved in frame
        BRA     WARM              | Abort from illegal instruction
*
BUS_ER:                           | Bus error (group 1) exception
        MOVE.L  %A4,-(%A7)        | Save A4
        LEA.L   MES8(%PC),%A4     | Point to heading
        BSR     HEADING           | Print it
        MOVE.L  (%A7)+,%A4        | Restore A4
        BRA.S   GROUP1            | Deal with group 1 exception
*
ADD_ER:                           | Address error (group 1) exception
        MOVE.L  %A4,-(%A7)        | Save A4
        LEA.L   MES9(%PC),%A4     | Point to heading
        BSR     HEADING           | Print it
        MOVE.L  (%A7)+,%A4        | Restore A4
        BRA.S   GROUP1            | Deal with group 1 exception
*
BRKPT:                            |   Deal with breakpoint
        MOVEM.L %D0-%D7/%A0-%A6,-(%A7) |   Save all registers
        BSR     BR_CLR            |   Clear breakpoints in code
        MOVEM.L (%A7)+,%D0-%D7/%A0-%A6 |   Restore registers
        BSR.S   GROUP2            | Treat as group 2 exception
        LEA.L   MES11(%PC),%A4    | Point to heading
        BSR     HEADING           | Print it
        BSR     EX_DIS            | Display saved registers
        BRA     WARM              | Return to monitor
*
*       GROUP1 is called by address and bus error exceptions
*       These are "turned into group 2" exceptions (eg TRAP)
*       by modifying the stack frame saved by a group 1 exception
*
GROUP1: MOVEM.L %D0/%A0,-(%A7)    | Save working registers
        MOVE.L  18(%A7),%A0       | Get PC from group 1 stack frame
        MOVE.W  14(%A7),%D0       | Get instruction from stack frame
        CMP.W   -(%A0),%D0        | Now backtrack to find the "correct PC"
        BEQ.S   GROUP1A           | by matching the op-code on the stack
        CMP.W   -(%A0),%D0        | with the code in the region of the
        BEQ.S   GROUP1A           | PC on the stack
        CMP.W   -(%A0),%D0
        BEQ.S   GROUP1A
        CMP.W   -(%A0),%D0
        BEQ.S   GROUP1A
        SUBQ.L  #2,%A0
GROUP1A:MOVE.L  %A0,18(%A7)       |  Restore modified PC to stack frame
        MOVEM.L (%A7)+,%D0/%A0    |  Restore working registers
        LEA.L   8(%A7),%A7        |  Adjust stack pointer to group 1 type
        BSR.S   GROUP2            |  Now treat as group 1 exception
        BSR     EX_DIS            |  Display contents of exception frame
        BRA     WARM              |  Exit to monitor - no RTE from group 2
*
GROUP2:                           | Deal with group 2 exceptions
        MOVEM.L %A0-%A7/%D0-%D7,-(%A7) | Save all registers on the stack
        MOVE.W  #14,%D0           | Transfer D0 - D7, A0 - A6 from
        LEA.L   TSK_T(%A6),%A0    | the stack to the display frame
GROUP2A:MOVE.L  (%A7)+,(%A0)+     | Move a register from stack to frame
        DBRA    %D0,GROUP2A       | and repeat until D0-D7/A0-A6 moved
        MOVE.L  %USP,%A2          | Get the user stack pointer and put it
        MOVE.L  %A2,(%A0)+        | in the A7 position in the frame
        MOVE.L  (%A7)+,%D0        | Now transfer the SSP to the frame,
        SUB.L   #10,%D0           | remembering to account for the
        MOVE.L  %D0,(%A0)+        | data pushed on the stack to this point
        MOVE.L  (%A7)+,%A1        | Copy TOS (return address) to A1
        MOVE.W  (%A7)+,(%A0)+     | Move SR to display frame
        MOVE.L  (%A7)+,%D0        | Get PC in D0
        SUBQ.L  #2,%D0            | Move back to current instruction
        MOVE.L  %D0,(%A0)+        | Put adjusted PC in display frame
        JMP     (%A1)             | Return from subroutine
*
*************************************************************************
*
*  GO executes a program either from a supplied address or
*  by using the data in the display frame
GO:      BSR     PARAM               | Get entry address (if any)
         TST.B   %D7                 | Test for error in input
         BEQ.S   GO1                 | If D7 zero then OK
         LEA.L   ERMES1(%PC),%A4     | Else point to error message,
         BRA     PSTRING             | print it and return
GO1:     TST.L   %D0                 | If no address entered then get
         BEQ.S   GO2                 | address from display frame
         MOVE.L  %D0,TSK_T+70(%A6)   | Else save address in display frame
         MOVE.W  #0x2700,TSK_T+68(%A6) | Store dummy status in frame
GO2:     BRA.S   RESTORE             | Restore volatile environment and go
*
GB:      BSR     BR_SET              | Same as go but presets breakpoints
         BRA.S   GO                  | Execute program
*
*        RESTORE moves the volatile environment from the display
*        frame and transfers it to the 68000's registers. This
*        re-runs a program suspended after an exception
*
RESTORE: LEA.L   TSK_T(%A6),%A3      | A3 points to display frame
         LEA.L   74(%A3),%A3         | A3 now points to end of frame + 4
         LEA.L   4(%A7),%A7          | Remove return address from stack
         MOVE.W  #36,%D0             | Counter for 37 words to be moved
REST1:   MOVE.W  -(%A3),-(%A7)       | Move word from display frame to stack
         DBRA    %D0,REST1           | Repeat until entire frame moved
         MOVEM.L (%A7)+,%D0-%D7      | Restore old data registers from stack
         MOVEM.L (%A7)+,%A0-%A6      | Restore old address registers
         LEA.L   8(%A7),%A7          | Except SSP/USP - so adjust stack
         RTE                         | Return from exception to run program
*
TRACE:                               | TRACE exception (rudimentary version)
         MOVE.L  MES12(%PC),%A4      | Point to heading
         BSR     HEADING             | Print it
         BSR     GROUP1              | Save volatile environment
         BSR     EX_DIS              | Display it
         BRA     WARM                | Return to monitor
*
*************************************************************************
*  Breakpoint routines: BR_GET gets the address of a breakpoint and
*  puts it in the breakpoint table. It does not plant it in the code.
*  BR_SET plants all breakpoints in the code. NOBR removes one or all
*  breakpoints from the table. KILL removes breakpoints from the code.
*
BR_GET:  BSR     PARAM               | Get breakpoint address in table
         TST.B   %D7                 | Test for input error
         BEQ.S   BR_GET1             | If no error then continue
         LEA.L   ERMES1(%PC),%A4     | Else display error
         BRA     PSTRING             | and return
BR_GET1: LEA.L   BP_TAB(%A6),%A3     | A6 points to breakpoint table
         MOVE.L  %D0,%A5             | Save new BP address in A5
         MOVE.L  %D0,%D6             | and in D6 because D0 gets corrupted
         MOVE.W  #7,%D5              | Eight entries to test
BR_GET2: MOVE.L  (%A3)+,%D0          | Read entry from breakpoint table
         BNE.S   BR_GET3             | If not zero display existing BP
         TST.L   %D6                 | Only store a non-zero breakpoint
         BEQ.S   BR_GET4
         MOVE.L  %A5,-4(%A3)         | Store new breakpoint in table
         MOVE.W  (%A5),(%A3)         | Save code at BP address in table
         CLR.L   %D6                 | Clear D6 to avoid repetition
BR_GET3: BSR     OUT8X               | Display this breakpoint
         BSR     NEWLINE
BR_GET4: LEA.L   2(%A3),%A3          | Step past stored op-code
         DBRA    %D5,BR_GET2         | Repeat until all entries tested
         RTS                         | Return
*
BR_SET:                              | Plant any breakpoints in user code
         LEA.L   BP_TAB(%A6),%A0     | A0 points to BP table
         LEA.L   TSK_T+70(%A6),%A2   | A2 points to PC in display frame
         MOVE.L  (%A2),%A2           | Now A2 contains value of PC
         MOVE.W  #7,%D0              | Up to eight entries to plant
BR_SET1: MOVE.L  (%A0)+,%D1          | Read breakpoint address from table
         BEQ.S   BR_SET2             | If zero then skip planting
         CMP.L   %A2,%D1             | Don't want to plant BP at current PC
         BEQ.S   BR_SET2             | location, so skip planting if same
         MOVE.L  %D1,%A1             | Transfer BP address to address reg
         MOVE.W  #TRAP_14,(%A1)      | Plant op-code for TRAP #14 in code
BR_SET2: LEA.L   2(%A0),%A0          | Skip past op-code field in table
         DBRA    %D0,BR_SET1         | Repeat until all entries tested
         RTS
*
NOBR:                                | Clear one or all breakpoints
         BSR     PARAM               | Get BP address (if any)
         TST.B   %D7                 | Test for input error
         BEQ.S   NOBR1               | If no error then skip abort
         LEA.L   ERMES1(%PC),%A4     | Point to error message
         BRA     PSTRING             | Display it and return
NOBR1:   TST.L   %D0                 | Test for null address (clear all)
         BEQ.S   NOBR4               | If no address then clear all entries
         MOVE.L  %D0,%A1             | Else just clear breakpoint in A1
         LEA.L   BP_TAB(%A6),%A0     | A0 points to BP table
         MOVE.W  #7,%D0              | Up to eight entries to test
NOBR2:   MOVE.L  (%A0)+,%D1          | Get entry and
         LEA.L   2(%A0),%A0          | skip past op-code field
         CMP.L   %A1,%D1             | Is this the one?
         BEQ.S   NOBR3               | If so go and clear entry
         DBRA    %D0,NOBR2           | Repeat until all tested
         RTS
NOBR3:   CLR.L   -6(%A0)             | Clear address in BP table
         RTS
NOBR4:   LEA.L   BP_TAB(%A6),%A0     | Clear all 8 entries in BP table
         MOVE.W  #7,%D0              | Eight entries to clear
NOBR5:   CLR.L   (%A0)+              | Clear breakpoint address
         CLR.W   (%A0)+              | Clear op-code field
         DBRA    %D0,NOBR5           | Repeat until all done
         RTS
*
BR_CLR:                              | Remove breakpoints from code
         LEA.L   BP_TAB(%A6),%A0     | A0 points to breakpoint table
         MOVE.W  #7,%D0              | Up to eight entries to clear
BR_CLR1: MOVE.L  (%A0)+,%D1          | Get address of BP in D1
         MOVE.L  %D1,%A1             | and put copy in A1
         TST.L   %D1                 | Test this breakpoint
         BEQ.S   BR_CLR2             | If zero then skip BP clearing
         MOVE.W  (%A0),(%A1)         | Else restore op-code
BR_CLR2: LEA.L   2(%A0),%A0          | Skip past op-code field
         DBRA    %D0,BR_CLR1         | Repeat until all tested
         RTS
*
*  REG_MOD modifies a register in the display frame. The command
*  format is REG <reg> <value>. E.g. REG D3 1200
*
REG_MOD: CLR.L   %D1                 | D1 to hold name of register
         LEA.L   BUFFPT(%A6),%A0     | A0 contains address of buffer pointer
         MOVE.L  (%A0),%A0           | A0 now points to next char in buffer
         MOVE.B  (%A0)+,%D1          | Put first char of name in D1
         ROL.W   #8,%D1              | Move char one place left
         MOVE.B  (%A0)+,%D1          | Get second char in D1
         LEA.L   1(%A0),%A0          | Move pointer past space in buffer
         MOVE.L  %A0,BUFFPT(%A6)     | Update buffer pointer
         CLR.L   %D2                 | D2 is the character pair counter
         LEA.L   REGNAME(%PC),%A0    | A0 points to string of character pairs
         LEA.L   (%A0),%A1           | A1 also points to string
REG_MD1: CMP.W   (%A0)+,%D1          | Compare a char pair with input
         BEQ.S   REG_MD2             | If match then exit loop
         ADD.L   #1,%D2              | Else increment match counter
         CMP.L   #19,%D2             | Test for end of loop
         BNE.S   REG_MD1             | Continue until all pairs matched
         LEA.L   ERMES1(%PC),%A4     | If here then error
         BRA     PSTRING             | Display error and return
REG_MD2: LEA.L   TSK_T(%A6),%A1      | A1 points to display frame
         ASL.L   #2,%D2              | Multiply offset by 4 (4 bytes/entry)
         CMP.L   #72,%D2             | Test for address of PC
         BNE.S   REG_MD3             | If not PC then all is OK
         SUB.L   #2,%D2              | else dec PC pointer as Sr is a word
REG_MD3: LEA.L   (%A1,%D2.W),%A2     | Calculate address of entry in disptable
         MOVE.L  (%A2),%D0           | Get old contents
         BSR     OUT8X               | Display them
         BSR     NEWLINE
         BSR     PARAM               | Get new data
         TST.B   %D7                 | Test for input error
         BEQ.S   REG_MD4             | If no error then go and store data
         LEA.L   ERMES1(%PC),%A4     | Else point to error message
         BRA     PSTRING             | print it and return
REG_MD4: CMP.L   #68,%D2             | If this address is the SR then
         BEQ.S   REG_MD5             | we have only a word to store
         MOVE.L  %D0,(%A2)           | Else store new data in display frame
         RTS
REG_MD5: MOVE.W  %D0,(%A2)           | Store SR (one word)
         RTS
*
*************************************************************************
*
X_UN:                             | Uninitialized exception vector routine
        LEA.L   ERMES6(%PC),%A4   | Point to error message
        BSR     PSTRING           | Display it
        BSR     EX_DIS            | Display registers
        BRA     WARM              | Abort
*
*************************************************************************
*
*  All strings and other fixed parameters here
*
BANNER:  .asciz   "TSBUG 2 Version 23.07.86\0"
CRLF:    .byte    CR,LF,'?',0
HEADER:  .byte    CR,LF,'S','1',0,0
TAIL:    .asciz   "S9  \0"
MES1:    .asciz   " SR  =  "
MES2:    .asciz   " PC  =  "
MES2A:   .asciz   " SS  =  "
MES3:    .asciz   "  Data reg       Address reg\0"
MES4:    .asciz   "        \0"
MES8:    .asciz   "Bus error   \0"
MES9:    .asciz   "Address error   \0"
MES10:   .asciz   "Illegal instruction \0"
MES11:   .asciz   "Breakpoint  \0"
MES12:   .asciz   "Trace   "
REGNAME: .ascii   "D0D1D2D3D4D5D6D7"
         .ascii   "A0A1A2A3A4A5A6A7"
         .ascii   "SSSR"
         .asciz   "PC  "
ERMES1:  .asciz   "Non-valid hexadecimal input  "
ERMES2:  .asciz   "Invalid command  "
ERMES3:  .asciz   "Loading error"
ERMES4:  .asciz   "Table full  \0"
ERMES5:  .asciz   "Breakpoint not active   \0"
ERMES6:  .asciz   "Uninitialized exception \0"
ERMES7:  .asciz   " Range error"
*
*  COMTAB is the built-in command table. All entries are made up of
*         a string length + number of characters to match + the string
*         plus the address of the command relative to COMTAB
*
COMTAB:  DC.B     4,4              | JUMP <address> causes execution to
         .ascii   "JUMP"           | begin at <address>
         DC.L     JUMP-COMTAB
         DC.B     8,3              | MEMORY <address> examines contents of
         .ascii   "MEMORY  "       | <address> and allows them to be changed
         DC.L     MEMORY-COMTAB
         DC.B     4,2              | LOAD <string> loads S1/S2 records
         .ascii   "LOAD"           | from the host. <string> is sent to host
         DC.L     LOAD-COMTAB
         DC.B     4,2              | DUMP <string> sends S1 records to the
         .ascii   "DUMP"           | host and is preceeded by <string>.
         DC.L     DUMP-COMTAB
         DC.B     4,3              | TRAN enters the transparant mode
         .ascii   "TRAN"           | and is exited by ESC,E.
         DC.L     TM-COMTAB
         DC.B     4,2              | NOBR <address> removes the breakpoint
         .ascii   "NOBR"           | at <address> from the BP table. If
         DC.L     NOBR-COMTAB      | no address is given all BPs are removed.
         DC.B     4,2              | DISP displays the contents of the
         .ascii   "DISP"           | pseudo registers in TSK_T.
         DC.L     EX_DIS-COMTAB
         DC.B    4,2               | GO <address> starts program execution
         .ascii   "GO  "            | at <address> and loads regs from TSK_T
         DC.L    GO-COMTAB
         DC.B    4,2               | BRGT puts a breakpoint in the BP
         .ascii  "BRGT"            | table - but not in the code
         DC.L    BR_GET-COMTAB
         DC.B    4,2               | PLAN puts the breakpoints in the code
         .ascii  "PLAN"
         DC.L    BR_SET-COMTAB
         DC.B    4,4               | KILL removes breakpoints from the code
         .ascii  "KILL"
         DC.L    BR_CLR-COMTAB
         DC.B    4,2               | GB <address> sets breakpoints and
         .ascii  "GB  "            | then calls GO.
         DC.L    GB-COMTAB
         DC.B    4,3               | REG <reg> <value> loads <value>
         .ascii  "REG "            | into <reg> in TASK_T. Used to preset
         DC.L    REG_MOD-COMTAB    | registers before a GO or GB
         DC.B    0,0
*
*************************************************************************
*
*  This is a list of the information needed to setup the DCBs
*
DCB_LST:
DCB1:    .ascii  "CON_IN  "          | Device name (8 bytes)
         SCON_IN = 0x000084ca        | Works around GNU assembler issue
         DC.L    SCON_IN,ACIA_1      | Address of driver routine, device
         DC.W    2                   | Number of words in parameter field
DCB2:    .ascii  "CON_OUT "
         SCON_OUT = 0x000084fa       | Works around GNU assembler issue
         DC.L    SCON_OUT,ACIA_1
         DC.W    2
DCB3:    .ascii  "AUX_IN  "
         SAUX_IN = 0x0000853a        | Works around GNU assembler issue
         DC.L    SAUX_IN,ACIA_2
         DC.W    2
DCB4:    .ascii  "AUX_OUT "
         SAUX_OUT = 0x0000854c       | Works around GNU assembler issue
         DC.L    SAUX_OUT,ACIA_2
         DC.W    2
DCB5:    .ascii  "BUFF_IN "
         SBUFF_IN = 0x000085a0       | Works around GNU assembler issue
         DC.L    SBUFF_IN,BUFFER
         DC.W    2
DCB6:    .ascii  "BUFF_OUT"
         SBUFF_OT = 0x000085ac       | Works around GNU assembler issue
         DC.L    SBUFF_OT,BUFFER
         DC.W    2
*
*************************************************************************
*
*  DCB structure
*
*              -----------------------
*       0 ->   | DCB  name           |
*              |---------------------|
*       8 ->   | Device driver       |
*              |---------------------|
*      12 ->   | Device address      |
*              |---------------------|
*      16 ->   |Size of param block  |
*              |---------------------| ---
*      18 ->   |      Status         |   |
*              | logical  | physical |   | S
*              |---------------------|   |
*              .                     .   .
*              |---------------------| ---
*    18+S ->   | Pointer to next DCB |
*
         .end

+++
