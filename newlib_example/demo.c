#include <stdio.h>
#include <string.h>

int main()
{
    printf ("C Program Demo\n");
    printf ("--------------\n");

    printf("size of char: %ld\n", sizeof(char));
    printf("size of short: %ld\n", sizeof(short));
    printf("size of int: %ld\n", sizeof(int));
    printf("size of long: %ld\n", sizeof(long));
    printf("size of float: %ld\n", sizeof(float));
    printf("size of double: %ld\n", sizeof(double));

    printf("\nEnter some text: ");
    char buffer[80];
    fgets(buffer, sizeof(buffer)-1, stdin);
    printf("Length of entered text is %ld.\n", strlen(buffer));
    printf("\nYou entered: ");
    printf(buffer);

    return 0;
}
