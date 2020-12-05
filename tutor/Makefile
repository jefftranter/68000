all:	tutor13.run tutor13.bin tutor13.hex tutor13_even.bin tutor13_odd.bin

rom-odd:
ifeq ($(CONNECTED), "[No programmer found]")
	@echo "No minipro device detected, please connect one"; exit 1
else
	minipro --write=tutor13_odd.bin --device=28C64B
endif

rom-even:
ifeq ($(CONNECTED), "[No programmer found]")
	@echo "No minipro device detected, please connect one"; exit 1
else
	minipro --write=tutor13_even.bin --device=28C64B
endif

tutor13.o: tutor13.s
	m68k-elf-as -m68000 -alms -a=tutor13.lst -o tutor13.o tutor13.s

tutor13.run: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O srec tutor13.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -Output_Block_Size 16 -o tutor13.run
	srec_cat tutor13.run -split 2 0 -offset 0x4000 -o tutor13_even.run
	srec_cat tutor13.run -split 2 1 -offset 0x4000 -o tutor13_odd.run
	$(RM) temp

tutor13.bin: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O binary tutor13.o tutor13.bin

tutor13.hex: tutor13.run
	srec_cat tutor13.run -Motorola -output tutor13.hex -Intel

tutor13_even.bin: tutor13_even.run
	srec_cat tutor13_even.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_even.bin -Binary

tutor13_odd.bin: tutor13_odd.run
	srec_cat tutor13_odd.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_odd.bin -Binary

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin tutor13.hex
	$(RM) tutor13_even.run tutor13_odd.run
	$(RM) tutor13_even.bin tutor13_odd.bin
