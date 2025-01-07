AS = vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

%.bin: %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

all: testprog.bin pep8

pep8:
	pycodestyle --max-line-length=150 disasm68k.py

test:	testprog.s disasm68k.py
	echo "Assembling program to binary"
	$(AS) $(ASFLAGS) -L $*.lst -o testprog.bin testprog.s
	echo "Disassembling binary back to S-record"
	./disasm68k.py -n testprog.bin >output.s

compare: output.bin output.s
	hexdump -C testprog.bin >testprog.hex
	hexdump -C output.bin >output.hex
	diff -y --suppress-common-lines testprog.hex output.hex

clean:
	$(RM) *.bin *.lst *.hex output.s
