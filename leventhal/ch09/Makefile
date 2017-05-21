%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	pgm_9_1a.run pgm_9_1b.run pgm_9_2a.run pgm_9_2b.run pgm_9_2c.run pgm_9_3.run pgm_9_4a.run pgm_9_4b.run pgm_9_5a.run pgm_9_5b.run

clean:
	$(RM) *.run *.lst
