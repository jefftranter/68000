AS = vasm/vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

%.bin: %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

all: testprog.bin pep8

install:
	echo "Installing Python dependencies"
	pip3 install --user pipenv; ~/.local/bin/pipenv --three install --dev
	echo "Installing VASM dependencies"
	wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
	tar xvzf vasm.tar.gz
	cd vasm && make CPU=m68k SYNTAX=mot && cd ..
	echo "All dependencies successfully installed"

pep8:
	~/.local/bin/pipenv run pycodestyle --max-line-length=121 disasm68k.py

test: vasm/vasmm68k_mot testprog.s disasm68k.py
	echo "Compiling S-record to binary"
	$(AS) $(ASFLAGS) -L $*.lst -o testprog.bin testprog.s
	echo "Disassembling binary back to S-record"
	~/.local/bin/pipenv run python disasm68k.py -n testprog.bin >output.s

output.s: testprog.bin
	~/.local/bin/pipenv run python disasm68k.py -n testprog.bin >output.s

compare: output.bin output.s
	hexdump -C testprog.bin >testprog.hex
	hexdump -C output.bin >output.hex
	diff -y --suppress-common-lines testprog.hex output.hex

clean:
	$(RM) *.bin *.lst *.hex output.s
