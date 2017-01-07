all:	testprog1.run testprog1.bin testprog2.run testprog2.bin

testprog1.o: testprog1.s
	m68k-elf-as -m68000 -a=testprog1.lst -o testprog1.o testprog1.s

testprog1.run: testprog1.o
	m68k-elf-objcopy -I coff-m68k -O srec testprog1.o temp
	srec_cat temp -fill 0x00 0x2000 0x2100 --crop 0x2000 0x2100 -o testprog1.run
	$(RM) temp

testprog1.bin: testprog1.o
	m68k-elf-objcopy -I coff-m68k -O binary testprog1.o testprog1.bin

testprog2.o: testprog2.s
	m68k-elf-as -m68000 -a=testprog2.lst -o testprog2.o testprog2.s

testprog2.run: testprog2.o
	m68k-elf-objcopy -I coff-m68k -O srec testprog2.o temp
	srec_cat temp -fill 0x00 0x2000 0x2100 --crop 0x2000 0x2100 -o testprog2.run
	$(RM) temp

testprog2.bin: testprog2.o
	m68k-elf-objcopy -I coff-m68k -O binary testprog2.o testprog2.bin

upload:
	ascii-xfr -s -l 100 testprog2.run | sed  's/S5/S9/' >/dev/ttyUSB0

clean:
	$(RM) testprog1.lst testprog1.o testprog1.run testprog1.bin temp
	$(RM) testprog2.lst testprog2.o testprog2.run testprog2.bin temp
