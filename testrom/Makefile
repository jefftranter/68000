all:	testprog.run testprog.bin

testprog.o: testprog.s
	m68k-elf-as -m68000 -a=testprog.lst -o testprog.o testprog.s

testprog.run: testprog.o
	m68k-elf-objcopy -I coff-m68k -O srec testprog.o temp
	srec_cat temp -fill 0x00 0x2000 0x2100 --crop 0x2000 0x2100 -o testprog.run
	$(RM) temp

testprog.bin: testprog.o
	m68k-elf-objcopy -I coff-m68k -O binary testprog.o testprog.bin

clean:
	$(RM) testprog.lst testprog.o testprog.run testprog.bin temp
