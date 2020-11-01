basic68k.hex: basic68k.run
	srec_cat basic68k.run -Motorola -output basic68k.hex -Intel

basic68k.run: basic68k.inc basic68k.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L basic68k.lst -o basic68k.run basic68k.asm
	# Use lines below when building for ROM
	srec_cat basic68k.run -fill 0x00 0xc000 0xffff --crop 0xc000 0xffff -Output_Block_Size 16 -o temp
	mv temp basic68k.run
	srec_cat basic68k.run -split 2 0 -offset 0x6000 -o basic68k_even.run
	srec_cat basic68k.run -split 2 1 -offset 0x6000 -o basic68k_odd.run
	# Use lines below when building for RAM
	#srec_cat basic68k.run -fill 0x00 0x800 0x3fff --crop 0x0800 0x3fff -Output_Block_Size 16 -o temp
	#mv temp basic68k.run

upload: basic68k.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 50 basic68k.run | sed  's/S5/S9/' > /dev/ttyUSB0
	/bin/echo -e "GO 800\r\n" >/dev/ttyUSB0

clean:
	$(RM) basic68k.run basic68k_even.run basic68k_odd.run basic68k.lst basic68k.hex
