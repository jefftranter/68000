This is a Kicad project for the Teesside TS2 single board computer
from the book "Microprocessor Systems Design - 68000 Hardware,
Software, and Interfacing", third edition, by Alan Clements.

This is a modified version that simplifies the design by removing
circuitry that is not needed for operation as a single board computer.
Specifically, removed was:

- backplane interface and associated buffering

- interrupt priority encoding and acknowledge circuitry (included but optional)

- line drivers and receivers for serial ports (FTDI USB to serial
  adaptors are used instead) and support for host/terminal transparent
  mode. This also removes the need for +12V/-12V power supplies.

See more details on my blog at http://jefftranter.blogspot.ca/
