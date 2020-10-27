#include <stdio.h>
#include <stdlib.h>

#define MAX_32BIT_INT_LEN 13 // Enough to store max length 32 bit signed integer newline char and null terminator

char c_checkValidity(int x, int y);
extern void assFunc(int x, int y);

int main(int argc, char** argv)
{
   int x, y;
   char * input = (char *)calloc(MAX_32BIT_INT_LEN, sizeof(char));

   fgets(input, MAX_32BIT_INT_LEN, stdin); //Get user numeric choice input
   sscanf(input, "%d", &x); // Assign user input to x
   fgets(input, MAX_32BIT_INT_LEN, stdin); //Get user numeric choice input
   sscanf(input, "%d", &y); // Assign user input to y

   assFunc(x, y); // call assFunc

   free(input);

  return 0;
}

char c_checkValidity(int x, int y)
{
   return x >= 0 && y > 0 && y <= (1 << 15); // 1 << 15 equals 2^15 (2^0 shifted 15 places left)
}
