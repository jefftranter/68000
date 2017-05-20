%.run : %.asm
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fsrec -s19

all:	pgm_7_1.run pgm_7_2.run pgm_7_3.run pgm_7_4a.run

clean:
	$(RM) *.run *.lst
