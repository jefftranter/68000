%.run : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	testprog1.run testprog2.run testprog3.run exceptions.run

clean:
	$(RM) *.run *.lst

upload:
	ascii-xfr -s -l 100 testprog1.run >/dev/ttyUSB0
