PROG1.HEX: PROG1.A68 PROG1.LNK
	dosbox -c "MOUNT C ${PWD}" -c "C:" -c "A68K PROG1 -SXE" -c "QLINK PROG1 -SX" -c "QSYM PROG1" -c "EXIT"

upload: PROG1.HEX
	/bin/echo -e "LO1\r\n" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 100 PROG1.HEX >/dev/ttyUSB0
	sleep 1
	/bin/echo -e "GO 900\r\n" >/dev/ttyUSB0

clean:
	$(RM) PROG1.LTX PROG1.PRN PROG1.HEX PROG1.SYM PROG1.LST PROG1.RPT
