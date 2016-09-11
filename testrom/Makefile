all:	testrom.run testrom.bin

testrom.o: testrom.s
	m68k-elf-as -m68000 -a=testrom.lst -o testrom.o testrom.s

testrom.run: testrom.o
	m68k-elf-objcopy -I coff-m68k -O srec testrom.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -o testrom.run
	srec_cat testrom.run -split 2 0 -o even.run
	srec_cat testrom.run -split 2 1 -o odd.run
	$(RM) temp

testrom.bin: testrom.o
	m68k-elf-objcopy -I coff-m68k -O binary testrom.o testrom.bin

clean:
	$(RM) testrom.lst testrom.o testrom.run testrom.bin even.run odd.run temp
