/*--------------------------------------------------------------------*/
/* euclidglobal.c                                                     */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

/*--------------------------------------------------------------------*/

static long l1;          /* Bad style. */
static long l2;          /* Bad style. */
static long lGcd;        /* Bad style. */
static long lTemp;       /* Bad style. */
static long lAbsFirst;   /* Bad style. */
static long lAbsSecond;  /* Bad style. */
   
/*--------------------------------------------------------------------*/

/* Assign to lGcd the greatest common divisor of l1 and l2. */

static void gcd(void)
{
   lAbsFirst = labs(l1);
   lAbsSecond = labs(l2);

   while (lAbsSecond != 0)
   {
      lTemp = lAbsFirst % lAbsSecond;
      lAbsFirst = lAbsSecond;
      lAbsSecond = lTemp;
   }
   
   lGcd = lAbsFirst;
}

/*--------------------------------------------------------------------*/

/* Read two integers from stdin. Compute their greatest common divisor,
   and write it to stdout. Return 0. */

int main(void)
{
   printf("Enter an integer: ");
   scanf("%ld", &l1);  /* Should validate. */
  
   printf("Enter an integer: ");
   scanf("%ld", &l2);  /* Should validate. */
   
   gcd();
   
   printf("The gcd is %ld\n", lGcd);

   return 0;
}