# 68000 Disassembler
This is a disassembler for the Motorola 68000 microprocessor, written in Python. The input data must be in binary 
format. If you want to read S record or other formats, you will need to convert the file to binary.

Thanks to GoldenCrystal for the helpful table of 68000 opcodes at http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf

## Usage
Install the dependencies using
```bash
make install
```

Now, you can disassemble a binary file, for example the sample file in this directory using
```bash
make testprog.bin  # This will create testprog.s
```

### Testing
Test the toolchain using
```bash
make test
```
