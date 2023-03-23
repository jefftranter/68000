all: nqueens.run yum.run math.run demo.run

nqueens.run: nqueens.c
	m68k-elf-gcc -Wall -m68000 -O nqueens.c -o nqueens.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=nqueens.map
	srec2bin -q nqueens.run nqueens.bin

yum.run: yum.c
	m68k-elf-gcc -Wall -m68000 -g -O yum.c -o yum.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=yum.map
	srec2bin -q yum.run yum.bin

math.run: math.c
	m68k-elf-gcc -Wall -m68000 -g -O math.c -o math.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=math.map -lm
	srec2bin -q math.run math.bin

demo.run: demo.c
	m68k-elf-gcc -Wall -m68000 -g -O demo.c -o demo.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=demo.map
	srec2bin -q demo.run demo.bin

clean:
	$(RM) nqueens.run nqueens.map nqueens.bin
	$(RM) yum.run yum.map yum.bin
	$(RM) math.run math.map math.bin
	$(RM) demo.run demo.map demo.bin

distclean: clean

upload-nqueens: nqueens.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 2 nqueens.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0

upload-yum: yum.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 2 yum.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0

upload-math: math.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 2 math.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0

upload-demo: demo.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 2 demo.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0
