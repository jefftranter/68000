all:	minimon.run monitor.run minimon.bin monitor.bin monitor.hex minimon.hex

minimon.o: minimon.s
	m68k-elf-as -m68000 -a=minimon.lst -o minimon.o minimon.s

minimon.run: minimon.o
	m68k-elf-objcopy -I elf32-m68k -O srec minimon.o minimon.run

minimon.bin: minimon.o
	m68k-elf-objcopy -I elf32-m68k -O binary minimon.o minimon.bin

minimon.hex: minimon.run
	srec_cat minimon.run -Motorola -output minimon.hex -Intel

monitor.o: monitor.s
	m68k-elf-as -m68000 -a=monitor.lst -o monitor.o monitor.s

monitor.run: monitor.o
	m68k-elf-objcopy -I elf32-m68k -O srec monitor.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -o monitor.run
	srec_cat monitor.run -split 2 0 -offset 0x4000 -o monitor_even.run
	srec_cat monitor.run -split 2 1 -offset 0x4000 -o monitor_odd.run
	$(RM) temp

monitor.bin: monitor.o
	m68k-elf-objcopy -I elf32-m68k -O binary monitor.o monitor.bin

monitor.hex: monitor.run
	srec_cat monitor.run -Motorola -output monitor.hex -Intel

clean:

distclean:
	$(RM) minimon.lst minimon.o minimon.run minimon.bin
	$(RM) monitor.lst monitor.o monitor.run monitor.bin
	$(RM) monitor_even.run monitor_odd.run monitor.hex minimon.hex
