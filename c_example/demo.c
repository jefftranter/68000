/*

  Example of compiling C code for 68000. Doesn't require any C library
  or other run-time code.

*/


// Forward references so we can put main() first at a known start
// address.
short factorial(short n);
void tutor();
void outch(char c);
void printString(char *s);
void printNumber(unsigned short n);


// Main program.
int main()
{
    asm("move.l #0x1000,%sp"); // Set up initial stack pointer

    short i, j;
    
    printString("Start\r\n");
    
    for (i = 1; i < 8; i++) {
        j = factorial(i);
        printNumber(i); outch(' '); printNumber(j);
        printString("\r\n");
    }

    printString("Done\r\n");
    tutor();
    return 0;
}


// Calculate factorial of a number.
short factorial(short n) {
    if (n <= 0) {
        return 1;
    } else {
       return(n * factorial(n - 1));
    }
}


// Go to the TUTOR monitor using trap 14 function. Does not return.
void tutor() {
    asm("move.b #228,%d7\n\t"
        "trap #14");
}


// Print a character using the TUTOR monitor trap function.
void outch(char c) {
    asm("movem.l %d0/%d1/%a0,-(%sp)\n\t"  // Save modified registers
        "move.b %d0,%d0\n\t"              // Put character in D0
        "move.b #248,%d7\n\t"             // OUTCH trap function code
        "trap #14\n\t"                    // Call TUTOR function
        "movem.l (%sp)+,%d0/%d1/%a0");    // Restore registers
}


// Print a string.
void printString(char *s) {
    while (*s != 0) {
        outch(*s);
        s++;
    }
}

// Quick and dirty routine to print decimal number up to 5 digits long.
void printNumber(unsigned short n) {
    unsigned short d;

    d = n / 10000;
    outch(d + '0');
    n = n - d * 10000;

    d = n / 1000;
    outch(d + '0');
    n = n - d * 1000;

    d = n / 100;
    outch(d + '0');
    n = n - d * 100;

    d = n / 10;
    outch(d + '0');
    n = n - d * 10;

    outch(n + '0');
}
