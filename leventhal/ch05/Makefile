%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -m68000 -no-opt -Fsrec -s19

all:	pgm_5_1a.run pgm_5_1b.run pgm_5_2a.run pgm_5_2b.run pgm_5_3.run pgm_5_4a.run pgm_5_4b.run pgm_5_5.run

clean:
	$(RM) *.run *.lst

