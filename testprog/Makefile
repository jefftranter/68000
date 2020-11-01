%.run : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	testprog1.run testprog2.run testprog3.run testprog4.run exceptions.run trans.run

clean:
	$(RM) *.run *.lst

upload:
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 trans.run | sed  's/S5/S9/' >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 2000\r\n" >/dev/ttyUSB0
