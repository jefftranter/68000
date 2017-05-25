This is an example of a C program that run on a standalone 68000-based
computer like my TS2 or the Motorola Educational Computer Board (ECB).

You will need a version of gcc built as a cross-compiler for the 68k
platform. I used gcc version 5.4.0.

Build the code using the provided make file. It gets linked at address
$2000. To load it into the Motorola ECB TUTOR monitor you can run the
command "LO1" and then send the run file to the serial port. On a
Linux desktop system using the first USB serial port, this command
works well:

% ascii-xfr -s -l 100 demo.run > /dev/ttyUSB0 

Or just do "make upload".

You can now run the program from TUTOR using GO 2000. Output should
look like the following:

TUTOR  1.3 > GO 2000

PHYSICAL ADDRESS=00002000

Start

n  n^2  n^4  n!

1 1 1 1

2 4 8 2

3 9 27 6

4 16 64 24

5 25 125 120

6 36 216 720

7 49 343 5040

Done
