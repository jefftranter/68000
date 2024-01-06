all: squareroot.run demo.run

squareroot.run: squareroot.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L squareroot.lst -o squareroot.run squareroot.asm

demo.run: demo.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L demo.lst -o demo.run demo.asm

upload: demo.run
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 demo.run >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 10B0\r\n" >/dev/ttyUSB0

clean:
	$(RM) squareroot.run squareroot.lst
	$(RM) demo.run demo.lst
