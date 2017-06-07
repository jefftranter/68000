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

    printf("Hello, world!\r\n");

    for (i = 1; i <= 100; i++) {
#ifdef FP
        printf("%d %d %d\r\n", i, i*i, (int) sqrt(i * i));
#else
        printf("%d %d %d\r\n", i, i*i, i*i*i);
#endif
    }

    printf("Press <Enter> to exit... ");
    getchar();

    return 0;
}
