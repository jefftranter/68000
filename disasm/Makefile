%.bin : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

all:	testprog1.bin

clean:
	$(RM) *.bin *.lst
