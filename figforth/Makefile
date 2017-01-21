f68k.run: f68k.asm
	vasmm68k_mot -m68000 -Fsrec -s19 -L f68k.lst -o f68k.run f68k.asm
	srec_cat f68k.run -fill 0x00 0x1c00 0x370f --crop 0x1c00 0x370f -Output_Block_Size 16 -o temp
	mv temp f68k.run

clean:
	$(RM) f68k.run f68k.lst
