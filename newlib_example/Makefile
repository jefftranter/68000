hello.run:	hello.c
	m68k-elf-gcc hello.c -o hello.run -T ts2.ld -Xlinker -Map=output.map

clean:
	$(RM) hello.run a.out output.map

distclean: clean
