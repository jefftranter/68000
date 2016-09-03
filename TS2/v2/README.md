This is a Kicad project for the Teesside TS2 single board computer
from the book "Microprocessor Systems Design - 68000 Hardware,
Software, and Interfacing", third edition, by Alan Clements.

This is a modified design that is slightly simplified to remove
unneeded circuitry, specifically:

- the backplane interface and associated buffering

- the serial port line drivers/receivers and circuitry to support
  transparent mode beween the two ports.

- a few unused chips (e.g. counter L3 for running at lower clock
  speeds)

I have not built or tested the circuit but am planning to do so.
