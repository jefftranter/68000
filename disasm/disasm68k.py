#! /usr/bin/env python3
#
# Motorola 68000 Disassembler
# Copyright (c) 2019 by Jeff Tranter <tranter@pobox.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Disassembly format:
# AAAAAAAA  XX XX XX XX XX XX XX XX XX XX  MMMM.s  operands
# 00001000  4E 71                          NOP
# 00001002  60 FC                          BRA.s   $12345678
# 00001004  67 FA                          BEQ.s   $12345678
# 00001006  60 00 FF F8                    BRA.w   $12345678
# 0000107E  00 79 00 FF 00 00 12 34        ORI.w   #$FF,$1234
# 00001086  00 B9 00 00 00 FF 12 34 56 78  ORI.l   #$ff,$12345678
# 0000109E  4E F9 00 00 10 00              JMP     $DEADBEEF
#
# With --nolist option:
# MMMM.s  operands
# NOP
# BRA.s   $12345678
# BEQ.s   $12345678
# BRA.w   $12345678
# ORI.w   #$FF,$1234
# ORI.l   #$ff,$12345678
# JMP     $DEADBEEF

# To Do:
#
# - Implement all 68000 instructions and addressing modes
# - Stress test
# - Implement -n option
# - Test that output can be assembled
# - Move CSV file into table into code, remove unused fields

import argparse
import csv
import re
import sys

# Data/Tables

conditions = ["T", "F", "HI", "LS", "CC", "CS", "NE", "EQ", "VC", "VS", "PL", "MI", "GE", "LT", "GT", "LE"]

# Functions


# Print a disassembled line of output
def printInstruction(address, length, mnemonic, data, operand):
    if length == 2:
        line = "{0:08X}  {1:02X} {2:02X}        {3:8s}  {4:s}".format(address, data[0], data[1], mnemonic, operand)
    elif length == 4:
        line = "{0:08X}  {1:02X} {2:02X} {3:02X} {4:02X}  {5:8s}  {6:s}".format(address,
                                                                                data[0],
                                                                                data[1],
                                                                                data[2],
                                                                                data[3],
                                                                                mnemonic,
                                                                                operand)
    else:
        print("Error: Invalid length passed to printInstruction().")
        sys.exit(1)

    print(line)


# Initialize variables
address = 0            # Start address if instruction
length = 0             # Length of instruction in bytes
mnemonic = ""          # Mnemonic string
sourceAddressMode = 0  # Addressing mode for source operand
destAddressMode = 0    # Addressing mode for destination operand
data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  # Instruction bytes

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to disassemble")
parser.add_argument("-n", "--nolist", help="Don't list instruction bytes (make output suitable for assembler)", action="store_true")
parser.add_argument("-a", "--address", help="Specify decimal starting address (defaults to 0)", default=0, type=int)
args = parser.parse_args()
address = args.address

# Address must be even
if address % 2:
    print("Error: Start address must be even.")
    sys.exit(1)

# Open CSV file of opcodes and read into table
with open("opcodetable.csv", newline='') as csvfile:
    table = list(csv.DictReader(csvfile))

    # Do validity check on table entries and calculate bitmask and value
    # for each opcode so we can quicky test opcode for matches in the
    # table.

    for row in table:

        # Validity check: Mnemonic is not empty.
        if row["Mnemonic"] == "":
            print("Error: Empty mnemonic entry in opcode table:", row)
            sys.exit(1)

        # Validity check: B W and L are empty or the corresponding letter
        if not row["B"] in ("B", ""):
            print("Error: Bad B entry in opcode table:", row)
            sys.exit(1)
        if not row["W"] in ("W", ""):
            print("Error: Bad W entry in opcode table:", row)
            sys.exit(1)
        if not row["L"] in ("L", ""):
            print("Error: Bad L entry in opcode table:", row)
            sys.exit(1)

        # Pattern  has length 16 and each character is 0, 1, or X.
        if not re.match(r"^[01X]...............$", row["Pattern"]):
            print("Error: Bad pattern entry in opcode table:", row)
            sys.exit(1)

        # Validity check: DataSize is B, W, L, A, or empty.
        if not row["DataSize"] in ("B", "W", "L", "A", ""):
            print("Error: Bad DataSize entry in opcode table:", row)
            sys.exit(1)

        # Validity check: DataType is is I, N, D, M or empty.
        if not row["DataType"] in ("I", "N", "D", "M", ""):
            print("Error: Bad DataType entry in opcode table:", row)
            sys.exit(1)

        # Convert bit pattern to 16-bit value and bitmask, e.g.
        # pattern: 1101XXX110001XXX
        #   value: 1101000110001000
        #    mask: 1111000111111000
        # Opcode matches pattern if opcode AND mask equals value

        pattern = row["Pattern"]
        value = ""
        mask = ""

        for pos in range(16):
            if pattern[pos] in ("0", "1"):
                value += pattern[pos]
                mask += "1"
            else:
                value += "0"
                mask += "0"

        # Convert value and mask to numbers and store in table.
        row["Value"] = int(value, 2)
        row["Mask"] = int(mask, 2)

# Open input file
filename = args.filename
try:
    f = open(filename, "rb")
except FileNotFoundError:
    print(("Error: input file '{}' not found.".format(filename)), file=sys.stderr)
    sys.exit(1)

# Loop over file input
while True:

    # Get 16-bit instruction
    c1 = f.read(1)  # Get binary bytes from file
    if len(c1) == 0:  # handle EOF
        break
    c2 = f.read(1)
    if len(c2) == 0:
        break

    data[0] = ord(c1)  # Convert to numbers
    data[1] = ord(c2)

    # Get op code
    opcode = data[0]*256 + data[1]

    # Find matching mnemonic in table
    for row in table:
        value = row["Value"]
        mask = row["Mask"]
        mnemonic = row["Mnemonic"]

        if (opcode & mask) == value:
            break

    # Should now have the mnemonic
    if mnemonic == "":
        print("Error: Mnemonic not found in opcode table.")
        sys.exit(1)

    # Handle instruction types - one word implicit with no operands:
    # ILLEGAL, RESET, NOP, RTE, RTS, TRAPV, RTR, UNIMPLEMENTED, INVALID
    if mnemonic in ("ILLEGAL", "RESET", "NOP", "RTE", "RTS", "TRAPV", "RTR", "UNIMPLEMENTED", "INVALID"):
        length = 2
        printInstruction(address, length, mnemonic, data, "")

    # Handle instruction types - one word implicit with operands
    # TRAP
    elif mnemonic == "TRAP":
        length = 2
        operand = "#${0:02X}".format(data[1] & 0x0f)
        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types: ORI to CCR
    elif mnemonic in ("ORI to CCR", "EORI to CCR"):
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        if data[2] != 0:
            print("Warning: MSB of operand should be zero, but is {0:02X}".format(data[2]))
        operand = "#${0:02X},CCR".format(data[3])
        if mnemonic == "ORI to CCR":
            printInstruction(address, length, "ORI", data, operand)
        else:
            printInstruction(address, length, "EORI", data, operand)

    # Handle instruction types: ORI to SR
    elif mnemonic in ("ORI to SR", "EORI to SR"):
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        operand = "#${0:04X},SR".format(data[2]*256 + data[3])
        if mnemonic == "ORI to SR":
            printInstruction(address, length, "ORI", data, operand)
        else:
            printInstruction(address, length, "EORI", data, operand)

    # Handle instruction types: ANDI to CCR
    elif mnemonic == "ANDI to CCR":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        if data[2] != 0:
            print("Warning: MSB of operand should be zero, but is {0:02X}".format(data[2]))
        operand = "#${0:02X},CCR".format(data[3])
        printInstruction(address, length, "ANDI", data, operand)

    # Handle instruction types: ANDI to SR
    elif mnemonic == "ANDI to SR":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        operand = "#${0:04X},SR".format(data[2]*256 + data[3])
        printInstruction(address, length, "ANDI", data, operand)

    # Handle instruction types: STOP
    elif mnemonic == "STOP":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        operand = "#${0:04X}".format(data[2]*256 + data[3])
        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types - BRA, BSR, Bcc
    elif mnemonic in ("BRA", "BSR", "BCC"):
        if (data[1]) != 0:  # Byte offset
            length = 2
            disp = data[1]
            if disp < 128:  # Positive offset
                dest = address + disp + 2
            else:  # Negative offset
                dest = address - (disp ^ 0xff) + 1
        else:  # Word offset
            length = 4
            data[2] = ord(f.read(1))
            data[3] = ord(f.read(1))
            disp = data[2] * 256 + data[3]
            if disp < 32768:  # Positive offset
                dest = address + disp + 2
            else:  # Negative offset
                dest = address - (disp ^ 0xffff) + 1
        operand = "${0:08X}".format(dest)

        if mnemonic == "BCC":
            cond = data[0] & 0x0f
            mnemonic = "B" + conditions[cond]

        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types - UNLK
    elif mnemonic == "UNLK":
        length = 2
        operand = "A{0:d}".format(data[1] & 0x07)
        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types - LINK
    elif mnemonic == "LINK":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        operand = "A{0:d},#${1:02X}".format(data[1] & 0x07, data[2] * 256 + data[3])
        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types - SWAP
    elif mnemonic == "SWAP":
        length = 2
        operand = "D{0:d}".format(data[1] & 0x07)
        printInstruction(address, length, mnemonic, data, operand)

    # Handle instruction types - EXT
    elif mnemonic == "EXT":
        length = 2
        operand = "D{0:d}".format(data[1] & 0x07)
        if data[1] & 0x40:
            printInstruction(address, length, "EXT.l", data, operand)
        else:
            printInstruction(address, length, "EXT.w", data, operand)

    # Handle instruction types - MOVE USP
    elif mnemonic == "MOVE USP":
        length = 2
        if data[1] & 0x08:
            operand = "USP,A{0:d}".format(data[1] & 0x07)
        else:
            operand = "A{0:d},USP".format(data[1] & 0x07)
        printInstruction(address, length, "MOVE", data, operand)

    elif mnemonic == "DBCC":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        disp = data[2] * 256 + data[3]
        if disp < 32768:  # Positive offset
            dest = address + disp + 2
        else:  # Negative offset
            dest = address - (disp ^ 0xffff) + 1
        operand = "D{0:d},${1:08X}".format(data[1] & 0x07, dest)

        cond = data[0] & 0x0f
        mnemonic = "DB" + conditions[cond]

        printInstruction(address, length, mnemonic, data, operand)

    elif mnemonic == "MOVEP":
        length = 4
        data[2] = ord(f.read(1))
        data[3] = ord(f.read(1))
        disp = data[2] * 256 + data[3]
        op = (data[1] & 0xc0) >> 6
        if op == 0:
            mnemonic = "MOVEP.w"
            operand = "(${0:04X},A{1:d}),D{2:d}".format(disp, data[1] & 0x07, (data[0] & 0x0e) >> 1)
        elif op == 1:
            mnemonic = "MOVEP.l"
            operand = "(${0:04X},A{1:d}),D{2:d}".format(disp, data[1] & 0x07, (data[0] & 0x0e) >> 1)
        elif op == 2:
            mnemonic = "MOVEP.w"
            operand = "D{0:d},(${1:04X},A{2:d})".format((data[0] & 0x0e) >> 1, disp, data[1] & 0x07)
        elif op == 3:
            mnemonic = "MOVEP.l"
            operand = "D{0:d},(${1:04X},A{2:d})".format((data[0] & 0x0e) >> 1, disp, data[1] & 0x07)
        printInstruction(address, length, mnemonic, data, operand)

    elif mnemonic == "MOVEQ":
        length = 2
        operand = "#${0:02X},D{1:d}".format(data[1], (data[0] & 0x0e) >> 1)
        printInstruction(address, length, mnemonic, data, operand)

    elif mnemonic == "SBCD":
        length = 2
        if data[1] & 0x08:
            operand = "-(A{0:d}),-(A{1:d})".format(data[1] & 0x7, (data[0] & 0x0e) >> 1)
        else:
            operand = "D{0:d},D{1:d}".format(data[1] & 0x7, (data[0] & 0x0e) >> 1)
        printInstruction(address, length, mnemonic, data, operand)

    else:
        print("Error: unsupported instruction", mnemonic)

    # Do next instruction
    address += length
    length = 0
    opcode = 0
    mnemonic = ""
