all:	tutor13.run tutor13.bin

tutor13.o: tutor13.s
	m68k-elf-as -m68000 -alms -a=tutor13.lst -o tutor13.o tutor13.s

tutor13.run: tutor13.o
	m68k-elf-objcopy -I coff-m68k -O srec tutor13.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -Output_Block_Size 16 -o tutor13.run
#	srec_cat tutor13.run -split 2 0 -offset 0x4000 -o tutor13_even.run
#	srec_cat tutor13.run -split 2 1 -offset 0x4000 -o tutor13_odd.run
	$(RM) temp

tutor13.bin: tutor13.o
	m68k-elf-objcopy -I coff-m68k -O binary tutor13.o tutor13.bin

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin
	$(RM) tutor13_even.run tutor13_odd.run
