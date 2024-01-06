%.run : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -I../drdobbs/squareroot -quiet -m68000 -no-opt -esc -Fsrec -s19

all:	calc.run

clean:
	$(RM) *.run *.lst

upload:	calc.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 calc.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 2000\r\n" >/dev/ttyUSB0
