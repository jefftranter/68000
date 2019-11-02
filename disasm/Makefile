%.bin : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

all:	testprog.bin pep8

pep8:
	pycodestyle --max-line-length=256 disasm68k.py

clean:
	$(RM) *.bin *.lst
