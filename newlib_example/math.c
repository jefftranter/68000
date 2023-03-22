/*
 * Floating point math demo. Does some integer and float math. Note
 * that the version of printf() does not support float so we have to
 * do some conversions to integer for printing.
 *
*/ 

#include <math.h>
#include <stdio.h>

int main()
{
    int i, j, k;
    double e, f;

    printf("i\ti^2\tsqrt(i)\t\tsin(i)\n");

    for (i = 0; i < 100; i++) {
        e = sqrt(i);
        f = sin(i);
        j = e * 1000;
        k = f * 1000;
        printf("%d\t%d\t%d/1000\t%d/1000\n", i, i*i, j, k);
    }
}
