//--------------------------------------------------------------------
// bigintadd.s                                                            
// Author: Siling & Alejandra                                         
//--------------------------------------------------------------------

.equ TRUE, 1
.equ FALSE, 0
.equ AULDIGITS, 8
.equ MAX_DIGITS, 32768

//--------------------------------------------------------------------
    .section .rodata

//--------------------------------------------------------------------

    .section .data

//--------------------------------------------------------------------

    .section .bss

//--------------------------------------------------------------------

    .section .text

    //----------------------------------------------------------------
    // Return the larger of lLength1 and lLength2.
    // static long BigInt_larger(long lLength1, long lLength2)
    //----------------------------------------------------------------

    // Must be a multiple of 16
    .equ BIG_INT_LARGER_ST, 32

    // Local Variable Stack Offsets:
    .equ LLARGER, 8

    // Parameter stack Offsets:
    .equ LLENGTH2, 16
    .equ LLENGTH1, 24

BigInt_larger:
    // Prolog
    // push the entire frame
    sub sp, sp, BIG_INT_LARGER_ST
    // store the return address given by caller saved in x30
    str x30, [sp]
    // store the first parameter given by caller saved in x0
    str x0, [sp, LLENGTH1]
    // store the second parameter given by caller saved in x1
    str x1, [sp, LLENGTH2]


    // long lLarger;

    //if (lLength1 <= lLength2) goto else1; (assuming these might be signed longs)
    ldr x0, [sp, LLENGTH1]
    ldr x1, [sp, LLENGTH2]
    cmp x0, x1
    ble else1

    // lLarger = lLength1;
    str x0, [sp, LLARGER]

    // goto endif1;
    b endif1

    else1:

    // lLarger = lLength2;
    str x1, [sp, LLARGER]

    endif1:

    // Epilog and return lLarger
        // the callee should save the return value in x0
        ldr     x0, [sp, LLARGER]
        // ret branches to address x30
        ldr     x30, [sp]
        // pop the stack frame:
        add     sp, sp, BIG_INT_LARGER_ST
        ret

        .size   BigInt_larger, (. - BigInt_larger)


    //--------------------------------------------------------------
    // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
    // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if 
    // an overflow occurred, and 1 (TRUE) otherwise. 
    // int BigInt_add (BigInt_T oAddend1, BigInt_T oAddend2, 
    // BigInt_T oSum)
    //--------------------------------------------------------------

    // must be a multiple of 16
    .equ BIGINT_ADD_STACK_BYTECOUNT, 64

    // local variable stack offsets:
    .equ ULCARRY, 8
    .equ ULSUM, 16
    .equ LINDEX, 24
    .equ LSUMLENGTH, 32

    // parameter stack offsets:
    .equ OSUM, 40
    .equ OADDEND2, 48
    .equ OADDEND1, 56

    .global BigInt_add

BigInt_add:

    // Prolog
    sub  sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str x30, [sp]
    str x0, [sp, OADDEND1]
    str x1, [sp, OADDEND2]
    str x2, [sp, OSUM]

    // unsigned long ulCarry;
    // unsigned long ulSum;
    // long lIndex;
    // long lSumLength;

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [sp,OADDEND1]
    ldr x0, [x0]
    ldr x1, [sp, OADDEND2]
    ldr x1, [x1]
    bl  BigInt_larger
    str x0, [sp, LSUMLENGTH]

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr x0, [sp, OSUM]
    ldr x0, [x0]
    ldr x1, [sp, LSUMLENGTH]
    cmp x0, x1
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, OSUM]
    // ldr x0, [x0, AULDIGITS]
    add x0, x0, AULDIGITS

    // assuming that 0 is treated as a long
    mov x1, 0 
    mov x2, MAX_DIGITS
    lsl x2, x2, 3
    bl memset

    endif2:

    // ulCarry = 0;
    mov x0, 0
    str x0, [sp, ULCARRY]

    // lIndex = 0;
    str x0, [sp, LINDEX]

    loop1:

    //if (lIndex >= lSumLength) goto loop1End;
    ldr x0, [sp, LINDEX]
    ldr x1, [sp, LSUMLENGTH]
    cmp x0, x1
    bge loop1End

    // ulSum = ulCarry;
    ldr x0, [sp, ULCARRY]
    str x0, [sp, ULSUM]

    // ulCarry = 0;
    mov x0, 0
    str x0, [sp, ULCARRY]

    // ulSum += oAddend1->aulDigits[lIndex];
    ldr x0, [sp, OADDEND1]
    add x0, x0, AULDIGITS
    ldr x1, [sp, LINDEX]
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]
    // ldr x0, [x0, AULDIGITS]
    // ldr x1, [sp, LINDEX]
    // ldr x0, [x0, x1, lsl 3]
    ldr x2, [sp, ULSUM]
    add x2, x2, x0
    str x2, [sp, ULSUM]

    //if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    // x0 is still oAddend1->aulDigits[lIndex]
    // x2 is still ulSum
    cmp x2, x0
    bhs endif3

    //ulCarry = 1;
    mov x0, 1
    str x0, [sp, ULCARRY]

    endif3:

    // ulSum += oAddend2->aulDigits[lIndex];
    ldr x0, [sp, OADDEND2]
    add x0, x0, AULDIGITS
    ldr x1, [sp, LINDEX]
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]
    // ldr x0, [x0, AULDIGITS]
    // ldr x1, [sp, LINDEX]
    // ldr x0, [x0, x1, lsl 3]
    ldr x2, [sp, ULSUM]
    add x2, x2, x0
    str x2, [sp, ULSUM]

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
    // x0 is still oAddend2->aulDigits[lIndex]
    // x2 is still ulSum
    cmp x2, x0
    bhs endif4

    //  ulCarry = 1;
    mov x0, 1
    str x0, [sp, ULCARRY]

    endif4:

    // probably nothing wrong here
    // oSum->aulDigits[lIndex] = ulSum;
    ldr x0, [sp, ULSUM]
    ldr x1, [sp, OSUM]
    add x1, x1, AULDIGITS
    // ldr x1, [x1, AULDIGITS]
    ldr x2, [sp, LINDEX]
    lsl x2, x2, 3
    add x1, x1, x2
    // ldr x1, [x1, x2]
    str x0, [x1]
    // idea for optimization:  str x0, [sp, OSUM, AULDIGITS, LINDEX, lsl 3]

    // lIndex++;
    ldr x0, [sp, LINDEX]
    add x0, x0, 1
    str x0, [sp, LINDEX]

    // goto loop1;
    b loop1

    loop1End:

    // if (ulCarry != 1) goto endif5;
    ldr x0, [sp, ULCARRY]
    cmp x0, 1
    bne endif5

    // if (lSumLength != MAX_DIGITS) goto endif6;
    ldr x0, [sp, LSUMLENGTH]
    cmp x0, MAX_DIGITS
    bne endif6

    // return FALSE;
    // not sure if the following works
    // Epilog and return lLarger
        // the callee should save the return value in x0
        mov     x0, FALSE
        // ret branches to address x30
        ldr     x30, [sp]
        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)

    endif6:

    // definitely something wrong here
    // oSum->aulDigits[lSumLength] = 1;
    mov x0, 1
    ldr x1, [sp, OSUM]
    add x1, x1, AULDIGITS
    // ldr x1, [x1, AULDIGITS]
    ldr x2, [sp, LSUMLENGTH]
    lsl x2, x2, 3
    add x1, x1, x2
    // ldr x1, [x1, x2]
    str x0, [x1]

    // not sure if the following line works
    // ldr x0, [sp, ULSUM]
    // ldr x1, [sp, OSUM]
    // ldr x1, [x1, AULDIGITS]
    // mov x2, LINDEX
    // lsl x2, x2, 3
    // ldr x1, [x1, x2]
    // str x0, [sp, x1]

    // lSumLength++;
    ldr x0, [sp, LSUMLENGTH]
    add x0, x0, 1
    str x0, [sp, LSUMLENGTH]

    endif5:

    // oSum->lLength = lSumLength;
    ldr x0, [sp, LSUMLENGTH]
    str x0, [sp, OSUM]

    // return TRUE;
    // Epilog and return lLarger
        // the callee should save the return value in x0
        mov     x0, TRUE
        // ret branches to address x30
        ldr     x30, [sp]
        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
