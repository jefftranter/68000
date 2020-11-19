all:
	wget http://www.easy68k.com/paulrsm/mecb/mecb.htm

gcc-install:
	wget https://github.com/kentosama/m68k-elf-gcc/archive/master.zip -O m68k-elf-gcc.zip
	unzip m68k-elf-gcc.zip

minipro:
	wget https://gitlab.com/DavidGriffith/minipro/-/archive/0.5/minipro-0.5.tar.gz
	tar xvzf minipro-0.5.tar.gz
	cd minipro-0.5 && make
	minipro-05/minipro --list

minipro-install: minipro-0.5/udev
	sudo cp minipro-0.5/udev/*.rules /etc/udev/rules.d/
	sudo udevadm trigger
	sudo usermod -a -G plugdev ${USER}
	echo "You need to log out and in again for the rules to take effect"

rom: minipro-0.5/minipro


tutor13.o: tutor13.s
	m68k-elf-as -m68000 -alms -a=tutor13.lst -o tutor13.o tutor13.s

tutor13.run: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O srec tutor13.o temp
	srec_cat temp -fill 0x00 0x8000 0xc000 --crop 0x8000 0xc000 -Output_Block_Size 16 -o tutor13.run
	srec_cat tutor13.run -split 2 0 -offset 0x4000 -o tutor13_even.run
	srec_cat tutor13.run -split 2 1 -offset 0x4000 -o tutor13_odd.run
	$(RM) temp

tutor13.bin: tutor13.o
	m68k-elf-objcopy -I elf32-m68k -O binary tutor13.o tutor13.bin

tutor13.hex: tutor13.run
	srec_cat tutor13.run -Motorola -output tutor13.hex -Intel

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin tutor13.hex
	$(RM) tutor13_even.run tutor13_odd.run
