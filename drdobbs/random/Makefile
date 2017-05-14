all: random.run demo.run

random.run: random.asm
	vasmm68k_mot -m68000 -Fsrec -s19 -L random.lst -o random.run random.asm

demo.run: demo.asm
	vasmm68k_mot -m68000 -Fsrec -s19 -L demo.lst -o demo.run demo.asm

clean:
	$(RM) random.run random.lst
	$(RM) demo.run demo.lst
