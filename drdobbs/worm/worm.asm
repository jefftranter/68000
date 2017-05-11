****   The Worm Memory Test   ******************************************
* Author: Jan W. Steinman, 2002 Parkside Ct.,  West Linn, OR 97068.
*
* The Worm memory test has three parts.  Init sets up the registers for the
* Worm.  The Display Manager interacts with the Worm each pass and periodically
* Displays the Worm's progress.  The Worm itself Worms itself through memory,
* from high to low, checking memory against a copy of itself.  The Droppings
* form a pattern through memory when the test is complete.
*
* This version runs on the Tektronix 4404 under Uniflex.  System dependent code
* is mostly segregated to the Init, Display, Disable and Enable routines.  Two
* instructions in the Worm routine are system dependent, for enabling and
* disabling interrupts.
*
* Register usage:
*	D0	scratch register.
*	D1	scratch register.
*	D2	scratch register.
*	D3	scratch register.
*	D4	
*	D5	address mask for determining if time to show progress.
*	D6	base of memory area under test.
*	D7	length of Worm in long words.
*	A0	scratch register.
*	A1	scratch register.
*	A2	scratch register.
*	A3	pointer to Display manager for position independent access.
*	A4	pointer to permanent Worm image for comparison.
*	A5	pointer to crawling Worm image.
*	A6	
*	A7	stack pointer.
*
* These included files contain system definitions and interrupt (signal)
* numbers for the Uniflex operating system.  Don't bother to list these.
*
*        OPT     lis           
*        DEFINE                (This makes all labels global for debug.)

write    EQU     $1000    External write function (placeholder)

* Stub for system call macro.

         macro SYS
         nop
         endm
*
* Set D_MASK with the bits that are zero at each progress report.
*
D_MASK   EQU     $00003FC    Report each boundary passed.
REL_SIZ  EQU     4           Relocation is four b per.
MEM_SIZ  EQU     $2000*REL_SIZ Test a 32K chunk.
DISABLE  EQU     2           Trap number for Disable routine.
ENABLE   EQU     3           Trap number for Enable routine.
CR       EQU     $0D         Carriage return.
LF       EQU     $0A          Line feed.
*
* Uniflex will not allow intersection math, so put all the code in the DATA
* section, and don't use TEXT or BSS at all!
*
         DATA                  Assemble into writable data section.
MemBeg   EQU     *             

****	hexadecimalize	******************************************************
* hexadecimalize converts a long word to eight ASCII hexadecimal characters.
* This routine is machine and OS independent.  It uses a simple table look-up
* to generate the hexadecimal string.
*
*	Entry:	d0 -- Long word to be converted to hex.
*		a0 -- Pointer to buffer where hex characters will go.
*
*	Exit:	d2 -- -1.  (Just in case someone cares!)
*		d0 -- unchanged.
*		-8(a0) -- points to eight ASCII characters.
*
*	Uses:	d3 -- nybble mask: constant $0F.
*		d2 -- nybble counter.
*		d1 -- current nybble to convert is LSN.
*
CharTab  DC.B    '0123456789ABCDEF' Where hex characters are.
hexadecimalize
         move.l  #7,d2         Bytes to make - 1.
         move.l  #$0F,d3       Nybble mask.
HexLoop  rol.l   #4,d0         Shift the next nybble into the LSN, <--------+
         move.l   d0,d1		make a copy for masking,                   |
         and.l    d3,d1		mask out all but least significant nybble, |
*				index into char table and store result.    |
         move.b   CharTab(pc,d1),(a0)+               |
         dbra     d2,HexLoop   Repeat until done, and when done, -----------+
         rts			hit the road, Jack. -->

****	Manager	*************************************************************
* Manager checks the Worm's progress, and periodically reports to the Display.
* This routine is also entered if an error is encountered.
*
*	Entry:	d0 -- W_LONGS complement of pass count if error, else -1.
*		a1 -- test address pass/fail value.
*
*	Exit:	via direct jump to Worm at (A5).
*
*	Uses:	d3, d2, d1, d0, a7, a1, a0
*
*	Stack:	one level, plus needs of Display.
*
ErrMsg   DC.B    CR,'Worm reports memory error at ' 
ErrAddrMsg
         DC.B    '00000000 on pass ' 
ErrCountMsg
         DC.B    '00000000.',CR 
E_SIZ    EQU     *-ErrMsg      
DoneMsg  DC.B    CR,'Worm tested memory from ' 
DoneBegAddrMsg
         DC.B    '00000000 through ' 
DoneEndAddrMsg
         DC.B    '00000000 successfully.',CR 
D_SIZ    EQU     *-DoneMsg     
ProgMsg  DC.B    '00000000',CR 
P_SIZ    EQU     *-ProgMsg     
         EVEN                  (Stay on legal instruction boundary.)
Manager  tst.w    d0           Was loop exited by error, or countdown?
         bpl.s   GetErrMsg	Error, go report it. -----------------------+
         cmp.l    a5,d6		Countdown, so are we done yet?              |
         beq.s   GetDoneMsg	  Yes.  Go finish up. --------------------+ |
         move.l   a5,d0		  No, put the new source where we can     | |
         and.l    d5,d0		    look at the bottom bits: on boundary? | |
         beq.s   Report		      Yes, set up for progress report. ---|+|
         jmp      (a5)		      No.  Keep on Crawlin'... -->        |||
*			      Finish up.  Get the pointer to start addr,  |||
GetDoneMsg lea    DoneBegAddrMsg(pc),a0 <----------------------------------+||
         move.l   a1,d0		and the value to plug in,                  ||
         bsr     hexadecimalize	which gets converted, likewise, get        ||
         lea      DoneEndAddrMsg(pc),a0              ||
         move.l  #MEM_SIZ,d0	the end address and its value,             ||
         bsr     hexadecimalize	also converted to hexAscii.                ||
         lea      DoneMsg(pc),a0 Get pointer to complete done message,      ||
         move.l  #D_SIZ,d3	length of the done message,                ||
         pea      Exit(pc)	push a return pointer,                     ||
         bra.s   Display		and go display the message. --------------+||
*			      Make an error report.  Get message ptr,     |||
GetErrMsg lea     ErrCountMsg(pc),a0 <-------------------------------------||+
         sub.b   #W_LONGS-1,d0	convert worm count to a pass count,       ||
         bsr     hexadecimalize	make it hex for Display. <-->             ||
*			      Get addr of ASCII error addr,               ||
         lea      ErrAddrMsg(pc),a0                 ||
         move.l  #-4,d0		get bad long addr to display,             ||
         add.l    a1,d0		less four to account for postincrement,   ||

         bsr     hexadecimalize	make it hex for Display. <-->             ||
         lea      ErrMsg(pc),a0 Get pointer to whole err msg,              ||
         move.l  #E_SIZ,d3	the size for the write,                   ||
         pea      Exit(pc)	push a return pointer,                    ||
         bra.s   Display		and Display the message. -----------------+|
*       Progress report.  Get message ptr,          ||
Report   lea      ProgMsg(pc),a0 <-----------------------------------------|+
         move.l   a5,d0		load the checked address,                 |
         bsr     hexadecimalize	make it hex for Display. <-->             |
         sub.l   #8,a0         Regain pointer to the message,              |
         move.l  #P_SIZ,d3	get the size for the write,               |
         pea      (a5)		push a return ptr to the new Worm,        |
*				and drop through into Display.            v

****	Display	**************************************************************
* Display is an implementation-dependent scheme for reporting the Worm's
* progress.  Upon entry, A0 contains a pointer to a string to Display, and D3
* contains the length of the string to Display.
*
*	Entry:	d3 -- number of bytes to display.
*		a0 -- address of a string to display.
*
*	Uses:	d0 -- file descriptor of stdout.
*		a1 -- scratch register for pointing to SysCall param block.
*
*	Stack:	as needed by system call.
*
********   B E G I N   S Y S T E M - D E P E N D E N T   C O D E   ********
Display  move.l   d3,-(a7)     Load the byte count, <---------------------+
         move.l   a0,-(a7)	the actual string pointer,
         move.w  #write,-(a7)	and the system call index,
         move.l   a7,a0		point to the syscall parameter block,
         move.l  #1,d0		load file descriptor for stdout,
*        SYS      indx		and write the message. <-->
         add.l   #10,a7        Remove the params from the stack, and
         rts			return somewhere. -->
*
* For lack of a better place to put it, the system- dependent exit code is here.
*
Exit     SYS     term	      Terminate this program.  (System dependent.)
********   E N D   S Y S T E M - D E P E N D E N T   C O D E   ********

****	Disable, Enable	*******************************************************
* These routines provide the exclusion mechanism for the non-interruptible code
* in Worm at Crawl.  These routines must execute in supervisor state, therefore
* they are executed via the TRAP exception instruction.  Enable requires that
* D1 be preserved from the preceding Disable.
*
*	Uses:	SR -- interrupt mask is raised and lowered.
*		d2 -- scratch register for restoring original interrupt mask.
*		d1 -- scratch register storage place for old interrupt mask.
*
********   B E G I N   S Y S T E M - D E P E N D E N T   C O D E   ********
Disable  move     sr,10        Grab the status register,
         and.w   #$0300,d1	keep only the interrupt bits,
         and     #$0300,sr	and disable all interrupts
         SYS     cpint,SIGTRAP2,Disable <-->
         rtr			before entering critical code region. -->

Enable   move    sr,d2         Regain the status register,
         or.w    d1,d2		reset the previous interrupt level,
         move    d2,sr		and enable the proper interrupts
         SYS     cpint,SIGTRAP3,Enable <-->
         rtr			before exiting critical code region. -->
********   E N D   S Y S T E M - D E P E N D E N T   C O D E   ********

****	Worm	**************************************************************
* Worm is a self-modifying, self-relocating procedure which starts at some
* location in high memory and works its way down to its end address,
* periodically reporting its progress.
*
* The loop at Crawl depends strongly on the 68000 prefetch mechanism.  This
* loop will not work on a 68020 machine (which has a 64 entry cache), nor on
* most simulators (which often do not bother to simulate prefetch accurately).
* This loop will also not work with the TRACE bit set, and must be protected
* from all interrupts, including page faults in virtual memory systems.
*
* When this loop moves the DBNE long word at Crawl+4, it overlays the MOVE.L
* and the CMPM.L at Crawl.  The CMPM.L is in the prefetch queue, so it gets
* executed even though its memory image has just been clobbered.  The DBNE is
* fetched, and its execution flushes the prefetch queue as is the case with all
* branches.  Execution continues with the copy of the DBNE just moved, which
* executes again, branching to Crawl-4, the new loop location.  Note that the
* loop count gets decremented twice in this scenario, removing the need for the
* usual predecrement before entering the loop.
*
*
*	Entry:	d7 -- length of Worm in long words.
*		d6 -- base of memory area to test.
*		d5 -- address mask for display boundary.
*		a5 -- first long word address of Worm at present.
*		a4 -- first long word address of Worm's original image.
*		a3 -- display manager's address.
*
*	Exit:	d0 -- W_LONGS complement of pass count if error.
*		a5 -- entry value less relocation, i.e.: next pass entry value.
*		a1 -- address pass/fail report value.
*
*	Uses:	d0 -- decrementing Worm length.
*		a2 -- incrementing COMPARE address.
*		a1 -- incrementing TO address.
*		a0 -- incrementing FROM address.
*
*	Unused:	d4, d3, a7, a6.
*
Worm     move.w   d7,d0        Restore the Worm's length,
         move.l   a5,a0		its starting point,
         move.l   a4,a2		and its original address.
         lea      -4(a5),a1    Get the destination for this pass.
********   B E G I N   S Y S T E M - D E P E N D E N T   C O D E   ********
         trap    #DISABLE      Don't interrupt this critical passage! <-->
********   E N D   S Y S T E M - D E P E N D E N T   C O D E   ********
Crawl    move.l   (a0)+,(a1)   Move a long word piece of Worm, <-------+
         cmp.l    (a1)+,(a2)+	and check it against the original,    |
         dbne     d0,Crawl	one long word at a time. -------------+
********   B E G I N   S Y S T E M - D E P E N D E N T   C O D E   ********
         trap    #ENABLE       Allow interrupts -- critical section over. <-->
********   E N D   S Y S T E M - D E P E N D E N T   C O D E   ********
         sub.l   #REL_SIZ,a5   Update the new Worm address,
         nop			keep the whole thing on long boundary,
         jmp      (a3)		report to the Manager. -->

*
* The following pattern (which is notoriously hard on 16 bit dynamic RAM
* memories) gets left in memory and can be checked later if desired.
*
Droppings
         DC.L    $5555AAAA     Pattern to be left in RAM.
W_SIZ    EQU     *-Worm        Length of self-relocating code, in bytes
W_LONGS  EQU     W_SIZ/4		and longs.

****	Init	**************************************************************
* Init performs system-dependent initialization and sets up registers for use
* of Worm and Manager.  Init then copies the Worm into the top of test memory
* and starts the Worm crawling.
*
*	Entry:	not applicable.
*
*	Exit:	a5 -- Worm's test image address at top of memory to be tested.
*		a4 -- Worm's permanent image address.
*		a3 -- Manager routine pointer.
*		d7 -- length of Worm in long words.
*		d6 -- base of memory area to test.
*		d5 -- address mask for testing display boundary.
*
Ovrly    EQU     *             This area will be overlaid with the worm.
LogMsg   DC.B    'Worm memory tester, ' 
         DC.B    '$Header: worm.a-v 1.2 86/03/24 01:44:36 jans Exp $' 
         DC.B    CR,'Memory checked down to location:',CR 
L_SIZ    EQU     *-LogMsg      

         EVEN                  
         GLOBAL  Init          
Init    
*
* First, perform some system-dependent initialization: set up the TRAPs needed
* to protect the Worm from interrupts, protect the area to be tested from page
* faults, and write a welcome message.
*
********   B E G I N   S Y S T E M - D E P E N D E N T   C O D E   ********
         SYS     cpint,SIGTRAP2,Disable	Set up the exception handlers for the
         SYS     cpint,SIGTRAP3,Enable	  interrupt exclusion routines.
         SYS     memman,1,MemBeg,MemEnd	Protect memory image from page faults.
         move.l  #1,d0			Prepare and write a stdout
         SYS     write,LogMsg,L_SIZ	  welcome message.
********   E N D   S Y S T E M - D E P E N D E N T   C O D E   ********
*
* Next, set up registers that will be used by the Worm and Manager.
*
         move.l  #D_MASK,d5    Get the Display address boundary mask.
         lea      Ovrly(pc),a0 Load the lowest address to test
         move.l   a0,d6		into a data register for comparison,
         lea      Manager(pc),a3	get the Display Manager's address,
         lea      Worm(pc),a4	the Worm's non-crawling image address,
         move.l  #MemEnd-W_SIZ,a5  and the high-mem Worm start address.
         move.w  #W_LONGS,d7   Get the Worm's length in longs.
*
* Finally, move the Worm to the top of memory to be tested.
*
         move.l   a4,a0        Get a copy of Worm's permanent image pointer,
         move.l   a5,a1		its test image pointer,
         move.w   d7,d0		and its length in longs.
         sub.w   #1,d0         
MoveWorm move.l   (a0),(a1)    Move, and compare <-------------+
         cmp.l    (a0)+,(a1)+	a long word of the Worm       |
         dbne     d0,MoveWorm	at a time. -------------------+

         tst.w    d0           Exit loop by error, or countdown?
         bpl     Manager		Error, go Report it. -->
         jmp      (a5)		Countdown.  Start Crawling! -->
C_SIZ    EQU     *-MemBeg      (Size of non-relocating code.)

         DS.B    MEM_SIZ-C_SIZ 
MemEnd   EQU     *             
*        ENDDEF                
         END     Init          (Set transfer address to the Init.)
