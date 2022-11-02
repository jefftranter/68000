#include <stdio.h>
#include <unistd.h>

int main(void)
{
    FILE *fp;
    int i;
    char buffer[80];

    printf("Test program - write\n");
    fgets(buffer, 16, stdin);
    
    fp = fopen("testfile", "w");

    i = fprintf(fp, "%s\n", "This is a test.\n");
    printf("fprintf() returned %d\n", i);
    fgets(buffer, 16, stdin);

    i = fclose(fp);
    printf("fclose() returned %d\n", i);
    fgets(buffer, 16, stdin);

    printf("Test program - read\n");
    fgets(buffer, 16, stdin);

    fp = fopen("testfile", "r");
    fgets(buffer, 16, stdin);

    fgets(buffer, 70, fp);
    printf("buffer: '%s'\n", buffer);
    fgets(buffer, 16, stdin);

    i = fclose(fp);
    printf("fclose() returned %d\n", i);
    fgets(buffer, 16, stdin);

    return 0;
}
