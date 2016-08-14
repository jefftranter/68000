all:	minimon.run monitor.run

minimon.o: minimon.s
	m68k-elf-as --mri -m68000 -a=minimon.lst -o minimon.o minimon.s

minimon.run: minimon.o
	m68k-elf-objcopy -I coff-m68k -O srec minimon.o minimon.run

monitor.o: monitor.s
	m68k-elf-as --mri -m68000 -a=monitor.lst -o monitor.o monitor.s

monitor.run: monitor.o
	m68k-elf-objcopy -I coff-m68k -O srec monitor.o monitor.run

clean:
	$(RM) minimon.lst minimon.o minimon.run monitor.lst monitor.o monitor.run
