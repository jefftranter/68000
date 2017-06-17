all: squareroot.run demo.run

squareroot.run: squareroot.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L squareroot.lst -o squareroot.run squareroot.asm

demo.run: demo.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L demo.lst -o demo.run demo.asm

clean:
	$(RM) squareroot.run squareroot.lst
	$(RM) demo.run demo.lst
