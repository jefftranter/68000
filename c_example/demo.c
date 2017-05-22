/*

  Example of compiling C code for 68000. Doesn't require any C library
  or other run-time code.

*/


short factorial(short n) {
    if (n <= 0) {
        return 1;
    } else {
       return(n * factorial(n - 1));
    }
}

int main()
{
    short i = 1;
    short j = 2;
    char  c = 'A';
    long  l = 1234;

    for (i = 1; i < 8; i++) {
        j = factorial(i);
    }
    return j;
}
