AS = vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

default: compare

all: testprog.bin pep8

output.bin: output.s
	$(AS) $(ASFLAGS) -L output.lst -o output.bin output.s

output.s: testprog.bin
	./disasm68k.py -n testprog.bin >output.s

pep8:
	pycodestyle --max-line-length=150 disasm68k.py

testprog.bin: testprog.s
	$(AS) $(ASFLAGS) -L testprog.lst -o testprog.bin testprog.s

compare: output.bin testprog.bin
	hexdump -C testprog.bin >testprog.hex
	hexdump -C output.bin >output.hex
	diff -y --suppress-common-lines testprog.hex output.hex

clean:
	$(RM) *.bin *.lst *.hex output.s
