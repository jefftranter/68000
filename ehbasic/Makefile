basic68k.run: basic68k.inc basic68k.asm
	vasmm68k_mot -m68000 -Fsrec -s19 -L basic68k.lst -o basic68k.run basic68k.asm
	srec_cat basic68k.run -fill 0x00 0x800 0x3fff --crop 0x0800 0x3fff -Output_Block_Size 16 -o temp
	mv temp basic68k.run

upload: basic68k.run
	ascii-xfr -s -l 50 basic68k.run | sed  's/S5/S9/' > /dev/ttyUSB0

clean:
	$(RM) basic68k.run basic68k.lst
