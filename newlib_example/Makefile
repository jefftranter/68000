nqueens.run:	nqueens.c
	m68k-elf-gcc -Wall -m68000 -O nqueens.c -o nqueens.run -T /usr/local/m68k-elf/lib/m68000/ts2.ld -Xlinker -Map=nqueens.map

clean:
	$(RM) nqueens.run nqueens.map

distclean: clean

upload: nqueens.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 nqueens.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0
