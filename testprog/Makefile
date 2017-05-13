all:	testprog1.run testprog2.run testprog3.run

testprog1.run: testprog1.s
	vasmm68k_mot -m68000 -Fsrec -s19 -L testprog1.lst -o testprog1.run testprog1.s

testprog2.run: testprog2.s
	vasmm68k_mot -m68000 -Fsrec -s19 -L testprog2.lst -o testprog2.run testprog2.s

testprog3.run: testprog3.s
	vasmm68k_mot -m68000 -Fsrec -s19 -L testprog3.lst -o testprog3.run testprog3.s

upload1:
	ascii-xfr -s -l 100 testprog1.run >/dev/ttyUSB0

upload2:
	ascii-xfr -s -l 100 testprog2.run >/dev/ttyUSB0

upload3:
	ascii-xfr -s -l 100 testprog3.run >/dev/ttyUSB0

clean:
	$(RM) testprog1.lst testprog1.run
	$(RM) testprog2.lst testprog2.run
	$(RM) testprog3.lst testprog3.run
