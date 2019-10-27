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

import csv
import re
import sys

# Open CSV file of opcodes and read into table

with open('opcodetable.csv', newline='') as csvfile:
    table = list(csv.DictReader(csvfile))

# Do validity check on table entries and calculate bitmask and value
# for each opcode so we can quicky test opcode for matches in the
# table.

for row in table:

    # Validity check: Mnemonic is not empty.
    if row["Mnemonic"] == "":
        print("Empty mnemonic entry in opcode table:", row)
        sys.exit(1)

    # Validity check: B W and L are empty or the corresponding letter
    if not row["B"] in ("B", ""):
        print("Bad B entry in opcode table:", row)
        sys.exit(1)
    if not row["W"] in ("W", ""):
        print("Bad W entry in opcode table:", row)
        sys.exit(1)
    if not row["L"] in ("L", ""):
        print("Bad L entry in opcode table:", row)
        sys.exit(1)

    # Pattern  has length 16 and each character is 0, 1, or X.
    if not re.match(r"^[01X]...............$", row["Pattern"]):
        print("Bad pattern entry in opcode table:", row)
        sys.exit(1)

    # Validity check: DataSize is B, W, L, A, or empty.
    if not row["DataSize"] in ("B", "W", "L", "A", ""):
        print("Bad DataSize entry in opcode table:", row)
        sys.exit(1)

    # Validity check: DataType is is I, N, D, M or empty.
    if not row["DataType"] in ("I", "N", "D", "M", ""):
        print("Bad DataType entry in opcode table:", row)
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
    value = int(value, 2)
    mask = int(mask, 2)
    row["Value"] = value
    row["Mask"] = mask

    
filename = "testprog1.bin"

try:
    f = open(filename, "rb")
except FileNotFoundError:
    print(("error: input file '{}' not found.".format(filename)), file=sys.stderr)
    sys.exit(1)

while True:
    b1 = f.read(1)  # Get binary byte from file
    b2 = f.read(1)  # Get binary byte from file

    if len(b1) == 0:  # handle EOF
        break

    # Get op code
    opcode = ord(b1) * 256 + ord(b2)

    print("{0:04X}".format(opcode))

    for row in table:
        value = row["Value"]
        mask = row["Mask"]
        mnemonic = row["Mnemonic"]

        if (opcode & mask) == value:
            print("Found match for", mnemonic)
            break
