TBI68K.run: TBI68K.asm
	vasmm68k_mot -quiet -m68000 -opt-allbra -ldots -Fsrec -s19 -L TBI68K.lst -o TBI68K.run TBI68K.asm

clean:
	$(RM) TBI68K.run TBI68K.lst
