%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	pgm_8_1a.run

clean:
	$(RM) *.run *.lst
