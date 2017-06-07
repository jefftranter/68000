hello.run:	hello.c
	m68k-elf-gcc -Wall -m68000 hello.c -o hello.run -T /usr/local/m68k-elf/lib/m68000/ts2.ld -Xlinker -Map=hello.map

clean:
	$(RM) hello.run a.out hello.map

distclean: clean

upload: hello.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 hello.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 804\r\n" >/dev/ttyUSB0
