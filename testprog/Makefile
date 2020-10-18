%.run : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	testprog1.run testprog2.run testprog3.run testprog4.run testprog5.run exceptions.run

clean:
	$(RM) *.run *.lst

upload:
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 testprog5.run >/dev/ttyUSB0
