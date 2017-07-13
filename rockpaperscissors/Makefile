%.run : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -esc -Fsrec -s19

all:	rps.run

clean:
	$(RM) *.run *.lst

upload:	rps.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 rps.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 1000\r\n" >/dev/ttyUSB0
