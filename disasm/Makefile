%.bin : %.s
	$(AS) $(ASFLAGS) -L $*.lst -o $@ $<

pep8:
	pycodestyle --max-line-length=132 disasm68k.py

AS	= vasmm68k_mot
ASFLAGS = -quiet -m68000 -no-opt -Fbin

all:	testprog1.bin pep8

clean:
	$(RM) *.bin *.lst
