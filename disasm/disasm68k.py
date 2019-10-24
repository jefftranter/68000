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

with open('opcodetable.csv') as csv_file:
    #csv_reader = csv.reader(csv_file, delimiter=',')
    csv_reader = csv.DictReader(csv_file)
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Column names are {", ".join(row)}')
        else:
            #print(f'Mnemonic: {row[0]} Size: {row[1]} Pattern: {row[17]}')
            print(f'Mnemonic: {row["Mnemonic"]} Size: {row["Size"]} Pattern: {row["Bit Pattern"]}')
        line_count += 1
    print(f'Processed {line_count} lines.')

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
