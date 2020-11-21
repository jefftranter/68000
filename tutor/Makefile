all:	tutor13.run tutor13.bin tutor13.hex tutor13_even.bin tutor13_odd.bin

gcc-install:
	wget https://github.com/kentosama/m68k-elf-gcc/archive/master.zip -O m68k-elf-gcc.zip
	unzip m68k-elf-gcc.zip

minipro-install:
	@echo $(pkg-config --version) || (echo "pkg-config is not installed; install with sudo apt-get install pkg-config"; exit 1)
	@echo $(dpkg -l | grep libusb-1.0) || (echo "libusb-1.0 is not installed; install using sudo apt-get install libusb-1.0"; exit 1)
	wget https://gitlab.com/DavidGriffith/minipro/-/archive/0.5/minipro-0.5.tar.gz
	tar xvzf minipro-0.5.tar.gz
	cd minipro-0.5 && make && ./minipro --version
	sudo cp minipro-0.5/udev/*.rules /etc/udev/rules.d/
	sudo udevadm trigger
	sudo usermod -a -G plugdev ${USER}
	@echo "You need to log out and in again for the rules to take effect. Or: you can run the make recipes for burning the ROMs as root with sudo."

rom-odd: minipro-0.5/minipro tutor13.bin
	od -w2 -t u1 -v tutor13.bin | awk ' { printf("%c", strtonum($2)) } ' > tutor13_odd.bin

rom-even: minipro-0.5/minipro tutor13.bin
	od -w2 -t u1 -v tutor13.bin | awk ' { printf("%c", strtonum($3)) } ' > tutor13_even.bin

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

tutor13_even.bin: tutor13_even.run
	srec_cat tutor13_even.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_even.bin -Binary

tutor13_odd.bin: tutor13_odd.run
	srec_cat tutor13_odd.run -Motorola --crop 0x8000 0xa000 --offset -0x8000 -output tutor13_odd.bin -Binary

clean:
	$(RM) tutor13.lst tutor13.o tutor13.run tutor13.bin tutor13.hex
	$(RM) tutor13_even.run tutor13_odd.run
	$(RM) tutor13_even.bin tutor13_odd.bin
