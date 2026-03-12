# 68000 Disassembler
This is a disassembler for the Motorola 68000 microprocessor, written in Python. The input data must be in binary 
format. If you want to read S record or other formats, you will need to convert the file to binary.

Thanks to GoldenCrystal for the helpful table of 68000 opcodes at http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf

## Usage

You can directly run the program disasm68k.py using the Python
interpreter. It uses Python 3 and requires some Python modules.

You can disassemble a binary file, for example the sample file in this
directory, using:
```bash
make testprog.bin
./disasm68k.py testprog.bin
```

### Testing

A regression test for the disassembler output can be run using:
```bash
make compare
```
This requires the VASM 68K assembler and some other external programs.
