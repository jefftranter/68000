worm.run: worm.asm
	vasmm68k_mot -quiet -nowarn=1007 -m68000 -Fsrec -s19 -L worm.lst -o worm.run worm.asm

clean:
	$(RM) worm.run worm.lst
