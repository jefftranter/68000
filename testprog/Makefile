all:	testprog1.run testprog2.run

testprog1.run: testprog1.s
	vasmm68k_mot -m68000 -Fsrec -s19 -L testprog1.lst -o testprog1.run testprog1.s

testprog2.run: testprog2.s
	vasmm68k_mot -m68000 -Fsrec -s19 -L testprog2.lst -o testprog2.run testprog2.s

upload:
	ascii-xfr -s -l 100 testprog2.run >/dev/ttyUSB0

clean:
	$(RM) testprog1.lst testprog1.run
	$(RM) testprog2.lst testprog2.run
