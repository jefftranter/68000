all: nqueens.run yum.run

nqueens.run: nqueens.c
	m68k-elf-gcc -Wall -m68000 -O nqueens.c -o nqueens.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=nqueens.map

yum.run: yum.c
	m68k-elf-gcc -Wall -m68000 -g -O yum.c -o yum.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=yum.map

clean:
	$(RM) nqueens.run nqueens.map
	$(RM) yum.run yum.map

distclean: clean

upload1: nqueens.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 nqueens.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0

upload2: yum.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 yum.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0
