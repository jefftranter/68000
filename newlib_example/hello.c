/*
 *
 * Sample C program that will run on the TS2.
 *
 */

// Define this if you want to try floating point math. You will also
// have to add -lm to the compile command line.
//#define FP

#include <stdio.h>

#ifdef FP
#include <math.h>
#endif

int main()
{
    int i;

    printf("Hello, world!\n");

    for (i = 1; i <= 10; i++) {
#ifdef FP
        printf("%d %d %d\n", i, i*i, (int) sqrt(i * i));
#else
        printf("%d %d %d\n", i, i*i, i*i*i);
#endif
    }

    printf("Press a key, X to exit...\n");
    while (1) {
        int c = getchar();
        printf("Key was %02x\n", c);
        if (c == 'X' || c == 'x')
            break;
    }

    return 0;
}
