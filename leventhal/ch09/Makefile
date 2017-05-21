%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	pgm_9_1a.run pgm_9_1b.run pgm_9_2a.run

clean:
	$(RM) *.run *.lst
