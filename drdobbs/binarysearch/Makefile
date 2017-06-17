binarysearch.run: binarysearch.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L binarysearch.lst -o binarysearch.run binarysearch.asm

clean:
	$(RM) binarysearch.run binarysearch.lst
