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

import sys
import csv

with open('opcodetable.csv', newline='') as csvfile:
    table = list(csv.DictReader(csvfile))

#print(table)
#print(table[3])
#print(table[3]["Mnemonic"])

for row in table:
    print(row["Mnemonic"], row["Bit Pattern"])

# Convert bit pattern to 16-bit value and bitmask, e.g.
# pattern: 1101 RRR1 1000 1rrr
#   value: 1101000110001000
#    mask: 1111000111111000
# Opcode matches pattern if opcode AND mask equals value

sys.exit(0)

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

    #print("{0:02X}".format(opcode))
    print("{0:04X}".format(opcode))
