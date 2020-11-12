# 68000 single-board retro-computing project
Designs and code related to the Motorola 68000 microprocessor.

## Building the project hardware
1. [Order the board](TS2/v2.1/README.md)
2. Order the parts from the [bill of materials (BOM)](TS2/v2.1/bom.pdf)
3. Order the two FT232 USB -> serial breakout boards
4. Order the chip sockets:

| Layout    | Qty   | Width (inches)    | Notes                                 |
|:---       | ---:  | ---:              |:---                                   |
| DIP-8     | 1     | 0.3               | For the 555                           |
| DIP-14    | 17    | 0.3               | For a lot                             |
| DIP-16    | 8     | 0.3               | For even more                         |
| DIP-24    | 2     | 0.6               | Double width: for serial interface    |
| DIP-28    | 8     | 0.6               | Double width: for RAM & ROM           |
| DIP-64    | 1     | 0.9               | Triple width: for CPU.                |

The DIP-64 can be a little hard to obtain, you could cut DIP-40 sockets to same effect. However, it's inadvisable to 
directly solder the CPU directly to the board. If the heat damages the chip, there's 64 pins to de-solder.

5. Solder in the sockets. Applying some soldering flux can be of great help: the IC soldering pads are tiny, mainly to 
save space on the board.
6. Solder in the rest of the components
7. [Flash the ROM chips](http://jefftranter.blogspot.com/2016/12/building-68000-single-board-computer_7.html)
8. Fit all ICs into their sockets
9. Connect power (preferably through a lab bench power supply)
10. Connect a PC to the board through USB
11. Watch it boot
12. Have some retro-computing fun!
 