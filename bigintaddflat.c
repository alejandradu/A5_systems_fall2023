/*--------------------------------------------------------------------*/
/* bigintadd.c                                                        */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

/* Return the larger of lLength1 and lLength2. */

static long BigInt_larger(long lLength1, long lLength2)
{
    long lLarger;

    if (lLength1 <= lLength2) goto else1;
    lLarger = lLength1;
    goto endif1;
 
    else1:
    lLarger = lLength2;

    endif1:
     
    return lLarger;
}

/*--------------------------------------------------------------------*/

/* Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
   distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
   overflow occurred, and 1 (TRUE) otherwise. */

int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;

   assert(oAddend1 != NULL);
   assert(oAddend2 != NULL);
   assert(oSum != NULL);
   assert(oSum != oAddend1);
   assert(oSum != oAddend2);

   /* Determine the larger length. */
   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

   /* Clear oSum's array if necessary. */
    if (oSum->lLength <= lSumLength) goto endif2;
    memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    
    endif2:

   /* Perform the addition. */
   ulCarry = 0;
   
   lIndex = 0;
   loop1:
   if (lIndex >= lSumLength) goto loop1End;
   
      ulSum = ulCarry;
      ulCarry = 0;

      ulSum += oAddend1->aulDigits[lIndex];
      if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
      ulCarry = 1;

      endif3:

      ulSum += oAddend2->aulDigits[lIndex];
      if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
      ulCarry = 1;

      endif4:

      oSum->aulDigits[lIndex] = ulSum;
      lIndex++;
      goto loop1;
   loop1End:

   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry != 1) goto endif5;

   if (lSumLength != MAX_DIGITS) goto endif6;
   return FALSE;
    
    endif6:

    oSum->aulDigits[lSumLength] = 1;
    lSumLength++;

    endif5:

   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}
