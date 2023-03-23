all: nqueens.bin yum.bin math.bin demo.bin sieve.bin

%.bin: %.run
	srec2bin -q $< $@

%.run: %.c
	m68k-elf-gcc -Wall -m68000 -Os $< -o $@ -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=$*.map

math.run: math.c
	m68k-elf-gcc -Wall -m68000 -g -Os math.c -o math.run -T /usr/local/m68k-elf/lib/ts2.ld -Xlinker -Map=math.map -lm

clean:
	$(RM) *.run *.map *.bin

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

upload-sieve: sieve.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 2 sieve.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0
