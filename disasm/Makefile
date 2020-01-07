%.bin : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

all:	testprog.bin pep8

pep8:
	pycodestyle --max-line-length=256 disasm68k.py

output.s: testprog.bin
	./disasm68k.py -n testprog.bin >output.s

compare: output.bin output.s
	hexdump -C testprog.bin >testprog.hex
	hexdump -C output.bin >output.hex
	diff -y --suppress-common-lines testprog.hex output.hex

clean:
	$(RM) *.bin *.lst *.hex output.s
