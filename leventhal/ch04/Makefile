%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -m68000 -no-opt -Fsrec -s19

all:	pgm_4_1.run pgm_4_2.run pgm_4_3a.run pgm_4_3b.run pgm_4_4.run pgm_4_5a.run pgm_4_5b.run

clean:
	$(RM) *.run *.lst
