#include <stdio.h>
#include <string.h>
#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char* buf, int *powers);
extern int * calc_powers(void);

int main(int argc, char** argv)
{
  char buf[MAX_LEN];
  int * powers; // define a pointer to 2^n array

  powers = calc_powers(); // call asm function to calculate 2^n array (0 <= n <= 31)
  while(strcmp(fgets(buf, MAX_LEN, stdin), "q\n") != 0)		/* get user input string in a loop */
      convertor(buf, powers);			/* call your assembly function */

  return 0;
}
