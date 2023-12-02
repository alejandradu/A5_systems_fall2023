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

    // Parameter stack Offsets:
    .equ X19STORE, 8
    .equ X20STORE, 16

    // Local Variable Stack Offsets:
    .equ X21STORE, 24
    
    // Local Variable equivalent registers
    LLARGER .req x21

    // Parameter equivalent registers
    LLENGTH1 .req x19
    LLENGTH2 .req x20

BigInt_larger:
    // Prolog
    // push the entire frame
    sub sp, sp, BIG_INT_LARGER_ST
    // store the return address given by caller saved in x30
    str x30, [sp]

    // for parameters
    // store the original value of x19 given by caller to stack
    str x19, [sp, X19STORE]
    // store the original value of x20 given by caller to stack
    str x20, [sp, X20STORE]

    // for the local variable
    // store the original value of x21 given by caller to stack
    str x21, [sp, X21STORE]

    // save lLength1 to LLENGTH1 (x19)
    mov LLENGTH1, x0
    // save lLength2 to LLENGTH2 (x20)
    mov LLENGTH2, x1


    // long lLarger;

    //if (lLength1 <= lLength2) goto else1; (assuming these might be signed longs)
    ldr x0, [sp, LLENGTH1]
    ldr x1, [sp, LLENGTH2]
    cmp LLENGTH1, LLENGTH2
    ble else1

    // lLarger = lLength1;
    mov LLARGER, LLENGTH1

    // goto endif1;
    b endif1

    else1:

    // lLarger = lLength2;
    mov LLARGER, LLENGTH2

    endif1:

    // Epilog and return lLarger
        // the callee should save the return value in x0
        ldr     x0, LLARGER
        // ret branches to address x30
        ldr     x30, [sp]

        // restoring spaces allocated for parameters
        // restore the original value of x19 given by caller to stack
        ldr x19, [sp, X19STORE]
        // restore the original value of x20 given by caller to stack
        ldr x20, [sp, X20STORE]

        // restoring spaces allocated for the local variable
        // restore the original value of x21 given by caller to stack
        ldr x21, [sp, X21STORE]        
        
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
    .equ X19STORE, 8
    .equ X20STORE, 16
    .equ X21STORE, 24
    .equ X22STORE, 32

    // parameter stack offsets:
    .equ X23STORE, 40
    .equ X24STORE, 48
    .equ X25STORE, 56

    // Parameter equivalent registers
    OSUM .req x19
    OADDEND2 .req x20
    OADDEND1 .req x21

    // Local Variable equivalent registers
    ULCARRY .req x22
    ULSUM   .req x23
    LINDEX  .req x24
    LSUMLENGTH .req x25

    .global BigInt_add

BigInt_add:

    // Prolog
    sub  sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str x30, [sp]

    // store all the original values of registers allocated
    // for parameters and local variables
    str x19, [sp, X19STORE]
    str x20, [sp, X20STORE]
    str x21, [sp, X21STORE]
    str x22, [sp, X22STORE]
    str x23, [sp, X23STORE]
    str x24, [sp, X24STORE]
    str x25, [sp, X25STORE]

    // save the values of parameters into registers
    mov OSUM, x2
    mov OADDEND1, x0
    mov OADDEND2, x1

    // unsigned long ulCarry;
    // unsigned long ulSum;
    // long lIndex;
    // long lSumLength;

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [OADDEND1] // prepare to pass oAddend1->lLength
    ldr x1, [OADDEND2] // prepare to pass oAddend2->lLength
    bl  BigInt_larger
    mov LSUMLENGTH, x0 // saving output of BigInt_larger

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr x0, [OSUM]
    cmp x0, LSUMLENGTH
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    add x0, OSUM, AULDIGITS // prepare to pass oSum->aulDigits (not sure if works)
  
    // preparing to pass 0: assuming that 0 is treated as a long
    mov x1, 0 

    // preparing to pass MAX_DIGITS * sizeof(unsigned long)
    mov x2, MAX_DIGITS
    lsl x2, x2, 3
    bl memset

    endif2:

    // ulCarry = 0;
    mov ULCARRY, 0

    // lIndex = 0;
    mov LINDEX, 0

    loop1:

    //if (lIndex >= lSumLength) goto loop1End;
    cmp LINDEX, LSUMLENGTH
    bge loop1End

    // ulSum = ulCarry;
    mov ULSUM,  ULCARRY

    // ulCarry = 0;
    mov ulCarry, 0

    // ulSum += oAddend1->aulDigits[lIndex];
    add x0, OADDEND1, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]
    add ULSUM, ULSUM, x0

    // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    add x0, OADDEND1, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]  // x0 is the value of oAddend1->aulDigits[lIndex]
    // ideas for further optimization: get rid of the above
    // x0 is still oAddend1->aulDigits[lIndex]
    // x2 is still ulSum
    cmp ULSUM, x0
    bhs endif3

    //ulCarry = 1;
    mov ULCARRY, 1

    endif3:

    // ulSum += oAddend2->aulDigits[lIndex];
    add x0, OADDEND2, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]
    add ULSUM, ULSUM, x0

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
    mov x0, OADDEND2
    add x0, x0, AULDIGITS // idea for optimization: add x0, OADDEND2, AULDIGITS
    mov x1, LINDEX
    ldr x0, [x0, x1, lsl 3]  // x0 is the value of oAddend2->aulDigits[lIndex]
    // idea for optimization: get rid of the above
    // x0 is still oAddend2->aulDigits[lIndex]
    // x2 is still ulSum
    cmp ULSUM, x0
    bhs endif4

    // --------------- CHANGE THE ABOVE 

    //  ulCarry = 1;
    mov ULCARRY, 1

    endif4:

    // oSum->aulDigits[lIndex] = ulSum;
    mov x0, OSUM
    add x0, x0, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1   // x0 is the address of oSum->aulDigits[lIndex]
    str ULSUM, [x0]

    // lIndex++;
    add LINDEX, LINDEX, 1

    // goto loop1;
    b loop1

    loop1End:

    // if (ulCarry != 1) goto endif5;
    cmp ULCARRY, 1
    bne endif5

    // if (lSumLength != MAX_DIGITS) goto endif6;
    cmp LSUMLENGTH, MAX_DIGITS
    bne endif6

    // return FALSE;
    // Epilog and return lLarger
        // the callee should save the return value in x0
        mov     x0, FALSE
        // ret branches to address x30
        ldr     x30, [sp]

        // restore the space allocated for parameters & variables
        ldr x19, [sp, X19STORE]
        ldr x20, [sp, X20STORE]
        ldr x21, [sp, X21STORE]
        ldr x22, [sp, X22STORE]
        ldr x23, [sp, X23STORE]
        ldr x24, [sp, X24STORE]
        ldr x25, [sp, X25STORE]

        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)

    endif6:

    // oSum->aulDigits[lSumLength] = 1;
    mov x1, OSUM
    add OSUM, OSUM, AULDIGITS
    mov x2, LSUMLENGTH
    lsl x2, x2, 3
    add x1, x1, x2
    mov x0, 1
    str x0, [x1]

    // lSumLength++;
    add LSUMLENGTH, LSUMLENGTH, 1

    endif5:

    // oSum->lLength = lSumLength;
    str LSUMLENGTH, [OSUM]

    // return TRUE;
    // Epilog and return lLarger
        // the callee should save the return value in x0
        mov     x0, TRUE
        // ret branches to address x30
        ldr     x30, [sp]

        // restore the space allocated for parameters & variables
        ldr x19, [sp, X19STORE]
        ldr x20, [sp, X20STORE]
        ldr x21, [sp, X21STORE]
        ldr x22, [sp, X22STORE]
        ldr x23, [sp, X23STORE]
        ldr x24, [sp, X24STORE]
        ldr x25, [sp, X25STORE]

        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
