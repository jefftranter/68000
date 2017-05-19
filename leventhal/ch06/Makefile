%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -m68000 -no-opt -Fsrec -s19

all:	pgm_6_1a.run pgm_6_1b.run pgm_6_1c.run pgm_6_2.run pgm_6_3.run pgm_6_4.run pgm_6_5a.run pgm_6_5b.run

clean:
	$(RM) *.run *.lst
