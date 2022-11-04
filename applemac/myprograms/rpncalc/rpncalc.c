//
// This is a simple math evaluation program/calculator written in C.
//
// It works with 32-bit signed integers and supports some basic math
// and bitwise functions and input and output in hex and decimal.
//
// The stack size is programmable at build time and defaults to five.
//
// It will build and compile on Linux using gcc, for 6502-based systems
// using cc65, and for the Apple Mac using retro68.
//
// Copyright (C) 2022 Jeff Tranter <tranter@pobox.com>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//////// Constants

// Stack size (number of elements)
#define stackSize 5

//////// Global variables

// The current base for input/output. Only 10 (decimal) and 16 (hex)
// are currently supported.
int base = 16;

// Stack
// One 32-bit value for each element.
// First (stack[0]) entry is top of stack.
// Last (stack[stackSize-1]) entry is bottom of stack.
int32_t stack[stackSize];

// Buffer for line of keyboard input containing command.
char command[80];

//////// Functions

// Pop top of stack
// 0 1 2 3 4 -- 0 1 2 3 4
// A B C D E -- B C D E 0
int32_t pop()
{
    int i;
    int32_t r = stack[0]; // Value to return;

    for (i = 0; i < stackSize - 1; i++) {
        stack[i] = stack[i + 1];
    }
    stack[stackSize - 1] = 0;

    return r;
}

// Push item on stack
// 0 1 2 3 4 -- 0 1 2 3 4
// A B C D E -- X A B C D
void push(int32_t item)
{
    int i;

    for (i = stackSize - 1; i >= 0 ; i--) {
        stack[i] = stack[i - 1];
    }
    stack[0] = item;
}

// Display stack in current base.
void stackPrint()
{
    int i;

    for (i = 0; i < stackSize; i++) {
        if (base == 10) {
            printf("%d\n", stack[i]);
        } else {
            printf("%08X\n", stack[i]);
        }
    }
}

// Input a string from the console until the user enters newline.
// String does not include the newline.
void getLine()
{
    fgets(command, sizeof(command)-1, stdin); // Get line of input.
    if (command[strlen(command) - 1] == '\n') { // Remove any trailing newline.
        command[strlen(command) - 1] = '\0';
    }
}

// Help command
void commandHelp()
{
    printf("%s",
           "Valid commands:\n"
           "[number]  Put number on stack\n"
           ".         Display stack\n"
           "+         Add\n"
           "-         Subtract\n"
           "*         Multiply\n"
           "/         Divide\n"
           "%         Remainder\n"
           "!         2's complement\n"
           "~         1's complement\n"
           "&         Bitwise AND\n"
           "|         Bitwise inclusive OR\n"
           "^         Bitwise exclusive OR\n"
           "<         Shift left\n"
           ">         Shift right\n"
           "=         Compare\n"
           "DROP      Remove top of stack\n"
           "SWAP      Exchange top 2 numbers on stack\n"
           "DUP       Duplicate top of stack\n"
           "ROT       Rotate 3 numbers on stack\n"
           "h         Set base to hex\n"
           "d         Set base to decimal\n"
           "q         Quit\n"
           "?         Help\n"
           );
}

// Dot command - print stack
void commandDot()
{
    stackPrint();
}

// Plus command - add
void commandAdd()
{
    push(pop() + pop());
}

// Minus command - subtract
void commandSubtract()
{
    push(pop() - pop());
}

// Asterisk command - multiply
void commandMultiply()
{
    push(pop() * pop());
}

// Slash command - divide
void commandDivide()
{
    int32_t i, j;

    i = pop();
    j = pop();

    if (j == 0) {
        printf("Error: divide by zero\n");
    } else {
        push(i / j);
    }
}

// Percent command - remainder (modulus)
void commandModulus()
{
    int32_t i, j;

    i = pop();
    j = pop();

    if (j == 0) {
        printf("Error: divide by zero\n");
    } else {
        push(i % j);
    }
}

// ! command - two's complement
void commandTwosComplement()
{
    push(-pop());
}

// ~ command - one's complement
void commandOnesComplement()
{
    push(~pop());
}

// And command - bitwise and
void commandAnd()
{
    push(pop() & pop());
}

// Or command - bitwise or
void commandOr()
{
    push(pop() | pop());
}

// ^ command - bitwise exclusive or
void commandExclusiveOr()
{
    push(pop() ^ pop());
}

// > command - shift right
void commandShiftRight()
{
    push(pop() >> pop());
}

// < command - shift left
void commandShiftLeft()
{
    push(pop() << pop());
}

// = command - compare
void commandCompare()
{
    push(pop() == pop());
}

// DROP command - Removes the number from top of stack
void commandDrop()
{
    pop();
}

// SWAP command - Exchanges the top two numbers on the stack
void commandSwap()
{
    int32_t i, j;
    i = pop(); j = pop();
    push(i); push(j);
}

// DUP comand - Duplicates the value on the top of stack
void commandDup()
{
    int32_t i = pop();
    push(i); push(i);
}

// ROT command - Rotates the top three numbers on the top of the stack
void commandRot()
{
    int32_t i, j, k;
    i = pop(); j = pop(); k = pop();
    push(i); push(k); push(j);
}

// Main program
int main()
{
    int i;
    base = 16; // Initialize base to hex

    // Initialize stack to all zeroes
    for (i = 0; i < stackSize; i++) {
        stack[i] = 0;
    }

    // Display startup message
    printf("RPN Calculator v1.0\n");

    // Start of main command polling loop.
    while (1) {

        stackPrint(); // Print current stack

        printf("? "); // Display prompt
        fflush(NULL);

        getLine(); //  Get line of input

        if (strlen(command) == 0) {
            continue; // Ignore blank line
        }

        // Figure out what command was typed and then call appropriate routine.
        if (!strcmp(command, "?")) {
            commandHelp();
        } else if (!strcmp(command, ".")) {
            commandDot();
        } else if (!strcmp(command, "+")) {
            commandAdd();
        } else if (!strcmp(command, "-")) {
            commandSubtract();
        } else if (!strcmp(command, "*")) {
            commandMultiply();
        } else if (!strcmp(command, "/")) {
            commandDivide();
        } else if (!strcmp(command, "%")) {
            commandModulus();
        } else if (!strcmp(command, "!")) {
            commandTwosComplement();
        } else if (!strcmp(command, "~")) {
            commandOnesComplement();
        } else if (!strcmp(command, "&")) {
            commandAnd();
        } else if (!strcmp(command, "|")) {
            commandOr();
        } else if (!strcmp(command, "^")) {
            commandExclusiveOr();
        } else if (!strcmp(command, ">")) {
            commandShiftRight();
        } else if (!strcmp(command, "<")) {
            commandShiftLeft();
        } else if (!strcmp(command, "=")) {
            commandCompare();
        } else if (!strcmp(command, "h") || !strcmp(command, "H")) {
            base = 16;
            printf("Base set to hex\n");
        } else if (!strcmp(command, "d") || !strcmp(command, "D")) {
            base = 10;
            printf("Base set to decimal\n");
        } else if (!strcmp(command, "q") || !strcmp(command, "Q")) {
            exit(0); // Quit
        } else if (!strcmp(command, "drop") || !strcmp(command, "DROP")) {
                commandDrop();
        } else if (!strcmp(command, "swap") || !strcmp(command, "SWAP")) {
                commandSwap();
        } else if (!strcmp(command, "dup") || !strcmp(command, "DUP")) {
                commandDup();
        } else if (!strcmp(command, "rot") || !strcmp(command, "ROT")) {
                commandRot();
        } else if (base == 10 && strspn(command, "+-0123456789") == strlen(command)) {
            push(strtol(command, NULL, base));           
        } else if (base == 16 && strspn(command, "0123456789abcdefABCDEF") == strlen(command)) {
            push(strtol(command, NULL, base));           
        } else {
            printf("Invalid command: '%s'\n", command);
            printf("type ? for help\n");
        }
    }
}
