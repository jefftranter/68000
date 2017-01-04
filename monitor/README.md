Teesside TS2 Monitor (TSBUG2) Commands
======================================

For TSBUG 2 Version 23.07.86

<address> is a hexadecimal number, e.g. FF0A
Arguments in square brackets are optional.


JUMP <address>     Begin execution at <address>.

MEMORY <address>   Examines contents of <address> and allows it to be
                   changed. Typing "-" goes to previous address, space
                   allows entering word-size data to write to current
                   address, <Return> exits, and any other key goes to
                   next address.

LOAD [<string>]    Loads S1/S2 records from the host. <string> is sent to
                   host.

DUMP <start address> <end address> [<string]
                   Sends S1 records to the host, preceeded by a string.

TRAN               Enters the transparent mode. Exited by ESC E.

NOBR <address>     Removes the breakpoint at <address> from the breakpoint
                   table. If no address is given all breakpoints are removed.

DISP               Displays the contents of the pseudo registers.

GO <address>       Starts program execution at <address> and loads regs
                   from pseudo registers.

BRGT <address>     Puts a breakpoint in the breakpoint table, but not in
                   the code.

PLAN               Puts the breakpoints in the code.

KILL               Removes breakpoints from the code.

GB [<address>]     Sets breakpoints and then calls GO. IF <address> is
                   omitted, uses PC value in pseudo registers.

REG <reg> <value>  Loads <value> into <reg> in pseudo registers. Used to
                   preset registers before a GO or GB.
