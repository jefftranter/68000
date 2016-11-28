This is the 68000 monitor for the Teesside TS2 single board computer
from the book "Microprocessor Systems Design - 68000 Hardware,
Software, and Interfacing", third edition, by Alan Clements.

This is based on the version on the included CD-ROM with changes to
assemble under the GNU assembler.

The original versions can be found on the "original" folder.

Minimon is a version designed to run under the simulator. Monitor is
the version that runs on the the TS2 hardware.

I have not tested it, other than getting it to assemble and confirming
that the assembled output matches the original.

<pre>
Teesside TS2 Monitor (TSBUG2) Commands
======================================

JUMP <address>     Begin at <address>.

MEMORY <address>   Examines contents of <address> and allows them to be changed.

LOAD <string>      Loads S1/S2 records from the host. <string> is sent to host.

DUMP <string>      Sends S1 records to the host and is preceeded by <string>.

TRAN               Enters the transparent mode. Exited by ESC, E.

NOBR <address>     Removes the breakpoint at <address> from the BP table. If no address is given all BPs are removed.

DISP               Displays the contents of the pseudo registers in TSK_T.

GO <address>       Starts program execution at <address> and loads regs from TSK_T.

BRGT               Puts a breakpoint in the BP table, but not in the code.

PLAN               Puts the breakpoints in the code.

KILL               Removes breakpoints from the code.

GB <address>       Sets breakpoints and then calls GO.

REG <reg> <value>  Loads <value> into <reg> in TASK_T. Used to preset registers before a GO or GB.
</pre>
