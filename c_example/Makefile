all:	demo.run

demo.run: demo.o
	m68k-elf-objcopy -I coff-m68k -O srec demo.o demo.run

demo.o: demo.s
	m68k-elf-as -o demo.o -a=demo.lst demo.s

demo.s:	demo.c
	#m68k-elf-gcc -g -m68000 -S demo.c
	m68k-elf-gcc -m68000 -S demo.c

clean:
	$(RM) demo.o demo.run demo.s demo.lst

upload: demo.run
	ascii-xfr -s -l 100 demo.run >/dev/ttyUSB0
