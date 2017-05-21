%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	pgm_8_1a.run pgm_8_1b.run pgm_8_2a.run pgm_8_2b.run

clean:
	$(RM) *.run *.lst
