default: ram

# Build when running out of RAM
ram:	TBI68K.asm
	vasmm68k_mot -quiet -m68000 -opt-allbra -ldots -Fsrec -s19 -L TBI68K.lst -o TBI68K.run TBI68K.asm

# Build when running out of ROM
rom: TBI68K.asm
	vasmm68k_mot -quiet -m68000 -opt-allbra -ldots -Fsrec -s19 -L TBI68K.lst -o TBI68K.run TBI68K.asm
	srec_cat TBI68K.run -fill 0x00 0xC000 0x10000 --crop 0xC000 0x10000 -o temp.run
	srec_cat temp.run -split 2 0 -offset 0x6000 -o TBI68K_even.run
	srec_cat temp.run -split 2 1 -offset 0x6000 -o TBI68K_odd.run
	srec_cat TBI68K_even.run -Motorola --crop 0xC000 0xE000 --offset -0xC000 -output TBI68K_even.bin -Binary
	srec_cat TBI68K_odd.run  -Motorola --crop 0xC000 0xE000 --offset -0xC000 -output TBI68K_odd.bin -Binary
	$(RM) temp.run

# Program even byte ROM using Minipro programmer
even:
	minipro -p AT28HC64 -w TBI68K_even.bin
	minipro -p AT28HC64 -m TBI68K_even.bin

# Program odd byte ROM using Minipro programmer
odd:
	minipro -p AT28HC64 -w TBI68K_odd.bin
	minipro -p AT28HC64 -m TBI68K_odd.bin

clean:
	$(RM) TBI68K.run TBI68K_even.run TBI68K_odd.run TBI68K_even.bin TBI68K_odd.bin TBI68K.lst
