/*

  Example of compiling C code for 68000. Doesn't require any C library
  or other run-time code except libgcc. Relies on the Motorola TUTOR
  monitor program.

*/


// Forward references so we can put main() first at a known start
// address.
int factorial(const int n);
void tutor();
void outch(const char c);
void printString(const char *s);
void printNumber(unsigned int n);


// Main program.
int main()
{
    asm("move.l #0x1000,%sp"); // Set up initial stack pointer

    // Uncomment to try some floating point math. Makes executable
    // much larger.
    //float f;
    //f = (1.0 / 3.0) * 1000.0;
    //printNumber(f);

    printString("Start\r\n");
    printString("n  n^2  n^4  n!\r\n");
    
    for (int i = 1; i < 12; i++) {
        printNumber(i);
        outch(' ');
        printNumber(i*i);
        outch(' ');
        printNumber(i*i*i);
        outch(' ');
        printNumber(factorial(i));
        printString("\r\n");
    }

    printString("Done\r\n");
    tutor();
    return 0;
}


// Calculate factorial of a number.
int factorial(int n) {
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
void printString(const char *s) {
    while (*s != 0) {
        outch(*s);
        s++;
    }
}

// Quick and dirty routine to print decimal number up to 10 digits
// long. Suppresses leading zeros.
void printNumber(unsigned int n) {
    unsigned int d;
    short digitPrinted = 0;
    unsigned int mult = 1000000000;

    while (mult > 1) {
        d = n / mult;
        if (d == 0) {
            if (digitPrinted) {
                outch(d + '0');
            }
        } else {
            outch(d + '0');
            digitPrinted = 1;
        }
        n = n - d * mult;
        mult = mult / 10;
    }
    outch(n + '0');
}
