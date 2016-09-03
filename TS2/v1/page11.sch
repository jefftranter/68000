EESchema Schematic File Version 2
LIBS:ts2-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:ts2-cache
EELAYER 25 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 12 12
Title "TS2 68000 Single Board Computer"
Date "2016-09-01"
Rev "1.0"
Comp ""
Comment1 "Fake connections to suppress ERC errors"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1100 950  2    60   Output ~ 0
IRQ1*
Text GLabel 1100 1150 2    60   Output ~ 0
IRQ2*
Text GLabel 1100 1350 2    60   Output ~ 0
IRQ3*
Text GLabel 1100 1550 2    60   Output ~ 0
IRQ4*
Text GLabel 1100 1750 2    60   Output ~ 0
IRQ5*
Text GLabel 1100 1950 2    60   Output ~ 0
IRQ6*
Text GLabel 1100 2150 2    60   Output ~ 0
IRQ7*
Text GLabel 1950 950  2    60   Output ~ 0
IACK1*
Text GLabel 1950 1150 2    60   Output ~ 0
IACK2*
Text GLabel 1950 1350 2    60   Output ~ 0
IACK3*
Text GLabel 1950 1550 2    60   Output ~ 0
IACK4*
Text GLabel 1950 1750 2    60   Output ~ 0
IACK5*
Text GLabel 1950 1950 2    60   Output ~ 0
IACK6*
Text GLabel 1950 2150 2    60   Output ~ 0
IACK7*
Text GLabel 2700 950  2    60   Output ~ 0
CS_PERI1*
Text GLabel 2700 1150 2    60   Output ~ 0
CS_PERI2*
Text GLabel 2700 1350 2    60   Output ~ 0
CS_PERI3*
Text GLabel 3500 950  2    60   Output ~ 0
BUS_VPA*
Text GLabel 3500 1150 2    60   Output ~ 0
BUS_DTACK*
Text GLabel 3500 1350 2    60   Output ~ 0
BUS_BR*
Text GLabel 3500 1550 2    60   Output ~ 0
BUS_BGACK*
Text GLabel 3500 1750 2    60   Output ~ 0
BUS_BG*
Text GLabel 3500 1950 2    60   Output ~ 0
BUS_RESET*
Text GLabel 3500 2150 2    60   Output ~ 0
BUS_HALT*
Text GLabel 3500 2350 2    60   Output ~ 0
BUS_E
Text GLabel 3500 2550 2    60   Output ~ 0
BUS_CLK
Text GLabel 3500 2750 2    60   Output ~ 0
BUS_LDS*
Text GLabel 3500 2950 2    60   Output ~ 0
BUS_UDS*
Text GLabel 4400 950  2    60   Output ~ 0
BUS_A01
Text GLabel 4400 1150 2    60   Output ~ 0
BUS_A02
Text GLabel 5150 950  2    60   Output ~ 0
BUS_D00
Text GLabel 5150 1150 2    60   Output ~ 0
BUS_D01
Text GLabel 3500 3150 2    60   Output ~ 0
BUS_AS*
Text GLabel 3500 3350 2    60   Output ~ 0
BUS_R/W*
Text GLabel 5150 1350 2    60   Output ~ 0
BUS_D02
Text GLabel 5150 1550 2    60   Output ~ 0
BUS_D03
Text GLabel 5150 1750 2    60   Output ~ 0
BUS_D04
Text GLabel 5150 1950 2    60   Output ~ 0
BUS_D05
Text GLabel 5150 2150 2    60   Output ~ 0
BUS_D06
Text GLabel 5150 2350 2    60   Output ~ 0
BUS_D07
Text GLabel 4400 1350 2    60   Output ~ 0
BUS_A03
Text GLabel 4400 1550 2    60   Output ~ 0
BUS_A04
Text GLabel 4400 1750 2    60   Output ~ 0
BUS_A05
Text GLabel 4400 1950 2    60   Output ~ 0
BUS_A06
Text GLabel 4400 2150 2    60   Output ~ 0
BUS_A07
Text GLabel 4400 2350 2    60   Output ~ 0
BUS_A08
Text GLabel 4400 2550 2    60   Output ~ 0
BUS_A09
Text GLabel 5150 2550 2    60   Output ~ 0
BUS_D08
Text GLabel 5150 2750 2    60   Output ~ 0
BUS_D09
Text GLabel 5150 2950 2    60   Output ~ 0
BUS_D10
Text GLabel 5150 3150 2    60   Output ~ 0
BUS_D11
Text GLabel 5150 3350 2    60   Output ~ 0
BUS_D12
Text GLabel 5150 3550 2    60   Output ~ 0
BUS_D13
Text GLabel 5150 3750 2    60   Output ~ 0
BUS_D14
Text GLabel 5150 3950 2    60   Output ~ 0
BUS_D15
Text GLabel 4400 2950 2    60   Output ~ 0
BUS_A11
Text GLabel 4400 3150 2    60   Output ~ 0
BUS_A12
Text GLabel 4400 3350 2    60   Output ~ 0
BUS_A13
Text GLabel 4400 3550 2    60   Output ~ 0
BUS_A14
Text GLabel 4400 3750 2    60   Output ~ 0
BUS_A15
Text GLabel 4400 3950 2    60   Output ~ 0
BUS_A16
Text GLabel 4400 4150 2    60   Output ~ 0
BUS_A17
Text GLabel 4400 4350 2    60   Output ~ 0
BUS_A18
Text GLabel 4400 4550 2    60   Output ~ 0
BUS_A19
Text GLabel 4400 2750 2    60   Output ~ 0
BUS_A10
Text GLabel 4400 4750 2    60   Output ~ 0
BUS_A20
Text GLabel 4400 4950 2    60   Output ~ 0
BUS_A21
Text GLabel 4400 5150 2    60   Output ~ 0
BUS_A22
Text GLabel 4400 5350 2    60   Output ~ 0
BUS_A23
Text GLabel 5900 950  2    60   Output ~ 0
HOST_TXD
Text GLabel 5900 1150 2    60   Input ~ 0
HOST_RXD
Text GLabel 5900 1350 2    60   Output ~ 0
HOST_DTR
Text GLabel 5900 1550 2    60   Output ~ 0
HOST_CTS
Text GLabel 5900 1750 2    60   Output ~ 0
TERM_TXD
Text GLabel 5900 1950 2    60   Input ~ 0
TERM_RXD
Text GLabel 5900 2150 2    60   Output ~ 0
TERM_DTR
NoConn ~ 1950 2150
NoConn ~ 1950 1950
NoConn ~ 1950 1750
NoConn ~ 1950 1550
NoConn ~ 1950 1350
NoConn ~ 1950 1150
NoConn ~ 1950 950 
NoConn ~ 2700 1150
NoConn ~ 2700 1350
NoConn ~ 5900 950 
NoConn ~ 5900 1150
NoConn ~ 5900 1350
NoConn ~ 5900 1550
NoConn ~ 5900 1750
NoConn ~ 5900 1950
NoConn ~ 5900 2150
$Comp
L +12VA #PWR0120
U 1 1 57C964E5
P 6700 1750
F 0 "#PWR0120" H 6700 1600 50  0001 C CNN
F 1 "+12VA" H 6700 1890 50  0000 C CNN
F 2 "" H 6700 1750 50  0000 C CNN
F 3 "" H 6700 1750 50  0000 C CNN
	1    6700 1750
	1    0    0    -1  
$EndComp
NoConn ~ 5150 950 
NoConn ~ 5150 1150
NoConn ~ 5150 1350
NoConn ~ 5150 1550
NoConn ~ 5150 1750
NoConn ~ 5150 1950
NoConn ~ 5150 2150
NoConn ~ 5150 2350
NoConn ~ 5150 2550
NoConn ~ 5150 2750
NoConn ~ 5150 2950
NoConn ~ 5150 3150
NoConn ~ 5150 3350
NoConn ~ 5150 3550
NoConn ~ 5150 3750
NoConn ~ 5150 3950
NoConn ~ 3500 2750
NoConn ~ 3500 2950
NoConn ~ 3500 2350
NoConn ~ 3500 2550
NoConn ~ 3500 3350
$Comp
L GND #PWR0121
U 1 1 57C98A1E
P 6700 1300
F 0 "#PWR0121" H 6700 1050 50  0001 C CNN
F 1 "GND" H 6700 1150 50  0000 C CNN
F 2 "" H 6700 1300 50  0000 C CNN
F 3 "" H 6700 1300 50  0000 C CNN
	1    6700 1300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR0122
U 1 1 57C98E87
P 6700 1000
F 0 "#PWR0122" H 6700 850 50  0001 C CNN
F 1 "VCC" H 6700 1150 50  0000 C CNN
F 2 "" H 6700 1000 50  0000 C CNN
F 3 "" H 6700 1000 50  0000 C CNN
	1    6700 1000
	1    0    0    -1  
$EndComp
$Comp
L Battery BT1
U 1 1 57C9929D
P 6700 1150
F 0 "BT1" H 6800 1200 50  0000 L CNN
F 1 "Battery" H 6800 1100 50  0000 L CNN
F 2 "" V 6700 1190 50  0000 C CNN
F 3 "" V 6700 1190 50  0000 C CNN
	1    6700 1150
	1    0    0    -1  
$EndComp
$Comp
L Battery BT2
U 1 1 57C9935A
P 6700 1900
F 0 "BT2" H 6800 1950 50  0000 L CNN
F 1 "Battery" H 6800 1850 50  0000 L CNN
F 2 "" V 6700 1940 50  0000 C CNN
F 3 "" V 6700 1940 50  0000 C CNN
	1    6700 1900
	1    0    0    -1  
$EndComp
$Comp
L -12VA #PWR0123
U 1 1 57C993A0
P 6700 2500
F 0 "#PWR0123" H 6700 2350 50  0001 C CNN
F 1 "-12VA" H 6700 2640 50  0000 C CNN
F 2 "" H 6700 2500 50  0000 C CNN
F 3 "" H 6700 2500 50  0000 C CNN
	1    6700 2500
	1    0    0    -1  
$EndComp
NoConn ~ 4400 950 
NoConn ~ 4400 1150
NoConn ~ 4400 1350
NoConn ~ 4400 1550
NoConn ~ 4400 1750
NoConn ~ 4400 1950
NoConn ~ 4400 2150
NoConn ~ 4400 2350
NoConn ~ 4400 2550
NoConn ~ 4400 2750
NoConn ~ 4400 2950
NoConn ~ 4400 3150
NoConn ~ 4400 3350
NoConn ~ 4400 3550
NoConn ~ 4400 3750
NoConn ~ 4400 3950
NoConn ~ 4400 4150
NoConn ~ 4400 4350
NoConn ~ 4400 4550
NoConn ~ 4400 4750
NoConn ~ 4400 4950
NoConn ~ 4400 5150
NoConn ~ 4400 5350
NoConn ~ 3500 3150
$Comp
L GND #PWR0124
U 1 1 57C9AE8B
P 6700 2050
F 0 "#PWR0124" H 6700 1800 50  0001 C CNN
F 1 "GND" H 6700 1900 50  0000 C CNN
F 2 "" H 6700 2050 50  0000 C CNN
F 3 "" H 6700 2050 50  0000 C CNN
	1    6700 2050
	1    0    0    -1  
$EndComp
$Comp
L CP1 C110
U 1 1 57C9C51D
P 6700 3400
F 0 "C110" H 6725 3500 50  0000 L CNN
F 1 "100uF" H 6725 3300 50  0000 L CNN
F 2 "" H 6700 3400 50  0000 C CNN
F 3 "" H 6700 3400 50  0000 C CNN
	1    6700 3400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR0125
U 1 1 57C9C575
P 6700 3550
F 0 "#PWR0125" H 6700 3300 50  0001 C CNN
F 1 "GND" H 6700 3400 50  0000 C CNN
F 2 "" H 6700 3550 50  0000 C CNN
F 3 "" H 6700 3550 50  0000 C CNN
	1    6700 3550
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR0126
U 1 1 57C9C591
P 6700 3250
F 0 "#PWR0126" H 6700 3100 50  0001 C CNN
F 1 "VCC" H 6700 3400 50  0000 C CNN
F 2 "" H 6700 3250 50  0000 C CNN
F 3 "" H 6700 3250 50  0000 C CNN
	1    6700 3250
	1    0    0    -1  
$EndComp
Text GLabel 6700 2500 3    60   Output ~ 0
FOO
Text GLabel 6950 2500 3    60   Output ~ 0
FOO
Wire Wire Line
	6950 2500 7150 2500
Wire Wire Line
	7150 2500 7150 2600
$Comp
L GND #PWR0127
U 1 1 57C9ED5F
P 7150 2600
F 0 "#PWR0127" H 7150 2350 50  0001 C CNN
F 1 "GND" H 7150 2450 50  0000 C CNN
F 2 "" H 7150 2600 50  0000 C CNN
F 3 "" H 7150 2600 50  0000 C CNN
	1    7150 2600
	1    0    0    -1  
$EndComp
$EndSCHEMATC
