# include <stdio.h>
# include <stdlib.h>
# include <assert.h>

int STRESS_STRING_SIZE = 4000;


/* Populate pcStr, which points to an array of at least iSize
   characters, with iSize-1 random ASCII characters followed by
   a '\0' character. */

static void randomString(char *pcStr, int iSize)
{
   int i;
   assert(pcStr != NULL);
   assert(iSize > 0);
   for (i = 0; i < iSize-1; i++) {
      pcStr[i] = (char)(((unsigned int)rand() % 95) + 32);
      /* Randomly add 9 and 10 ASCII CODES */
        if ((unsigned int)rand() % 96 == 0) {
            pcStr[i] = (char)9;
        } else if ((unsigned int)rand() % 97 > 72) {
            pcStr[i] = (char)10;
         }
   }
}

int main(void)
{
    int i;
    char bigStr[STRESS_STRING_SIZE];

    randomString(bigStr, STRESS_STRING_SIZE);
    printf("%s\n", bigStr);

   return 0;
}

/* very big file with only random chars
very big with chars and spaces
veyr big with words and spaces
big file with words, spaces, newlines*/


