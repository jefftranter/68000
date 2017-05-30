all:	demo.run

demo.run: demo.c
	m68k-elf-gcc -Wall -m68000 -c demo.c
	m68k-elf-ld --defsym=_start=main -Ttext=0x2000 -Tdata=0x3000 -Tbss=0x4000 --section-start=.rodata=0x5000 demo.o `m68k-elf-gcc -print-libgcc-file-name`
	m68k-elf-objcopy -I coff-m68k -O srec a.out demo.run

demo.s: demo.c
	m68k-elf-gcc -Wall -nostdlib -nodefaultlibs -m68000 -S demo.c
clean:
	$(RM) a.out demo.o demo.run demo.s

upload: demo.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 demo.run >/dev/ttyUSB0
