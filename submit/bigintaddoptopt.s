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

//--------------------------------------------------------------
// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
// be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if 
// an overflow occurred, and 1 (TRUE) otherwise. 
// int BigInt_add (BigInt_T oAddend1, BigInt_T oAddend2, 
// BigInt_T oSum)
//--------------------------------------------------------------

    // must be a multiple of 16
    .equ BIGINT_ADD_STACK_BYTECOUNT, 64   

    // local variable & parameter stack offsets:
    .equ X19STORE, 8
    .equ X20STORE, 16
    .equ X21STORE, 24
    .equ X24STORE, 48
    .equ X25STORE, 56

    // local variable & Parameter equivalent registers
    OSUM .req x19
    OADDEND2 .req x20
    OADDEND1 .req x21

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
    str x24, [sp, X24STORE]
    str x25, [sp, X25STORE]

    // save the values of parameters into registers
    mov OSUM, x2
    mov OADDEND1, x0    // THIS IS pointer to LLENGTH1
    mov OADDEND2, x1    // THIS IS pointer to LLENGTH2

    // unsigned long ulCarry;
    // unsigned long ulSum;
    // long lIndex;
    // long lSumLength;

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    //if (lLength1 <= lLength2) goto else1; 
    ldr x0, [OADDEND1]
    ldr x1, [OADDEND2]
    cmp x0, x1
    ble else1

    // lLarger = lLength1; 
    mov LSUMLENGTH, x0

    // goto endif1;
    b endif1

    else1:

    // lLarger = lLength2;
    mov LSUMLENGTH, x1

    endif1:

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr x0, [OSUM]
    cmp x0, LSUMLENGTH
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    add x0, OSUM, AULDIGITS // prepare to pass oSum->aulDigits 
  
    // preparing to pass 0: assuming that 0 is treated as a long
    mov x1, 0 

    // preparing to pass MAX_DIGITS * sizeof(unsigned long)
    mov x2, MAX_DIGITS
    lsl x2, x2, 3
    bl memset

    endif2:

    // lIndex = 0;
    mov LINDEX, 0

    //if (lIndex >= lSumLength) goto loop1End;
    cmp LINDEX, LSUMLENGTH
    //bge loop1EndNoCarry
    bge endif5
    

    // always enter the loop with c flag = 0
    loop1StartNoCarry:
    // setting the c flag back to zero in case it is 
    // changed by cmp
    adds xzr, xzr, xzr 
    // then start the loop
    b loopBody

    loop1StartWithCarry:
    // setting the c flag back to one in case it is
    // changed by cmp
    negs xzr, xzr


    loopBody:
    // ulSum += oAddend1->aulDigits[lIndex];
    add x0, OADDEND1, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1
    ldr x0, [x0]


    // ulSum += oAddend2->aulDigits[lIndex];
    add x1, OADDEND2, AULDIGITS
    mov x2, LINDEX
    lsl x2, x2, 3
    add x1, x1, x2
    ldr x1, [x1]
    adcs x2, x0, x1  // THIS WILL SET A NEW C TO KEEP


    // oSum->aulDigits[lIndex] = ulSum;
    mov x0, OSUM
    add x0, x0, AULDIGITS
    mov x1, LINDEX
    lsl x1, x1, 3
    add x0, x0, x1      // x0 is the address of oSum->aulDigits[lIndex]
    // str ULSUM, [x0]
    str x2, [x0]

    // lIndex++;
    add LINDEX, LINDEX, 1

    bcc noCarryDetected
    // if we detect a carry:
    //if (lIndex < lSumLength) goto loop1;
    cmp LINDEX, LSUMLENGTH
    blt loop1StartWithCarry  //HERE
    b loop1EndWithCarry

    noCarryDetected:
    // if we did not detect a carry:
    //if (lIndex < lSumLength) goto loop1;
    cmp LINDEX, LSUMLENGTH
    blt loop1StartNoCarry  //HERE
    //b loop1EndNoCarry
    b endif5  // directly to end w carry clear


    loop1EndWithCarry:

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
        ldr x24, [sp, X24STORE]
        ldr x25, [sp, X25STORE]

        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)

    endif6:

    // oSum->aulDigits[lSumLength] = 1;
    mov x1, OSUM
    add x1, x1, AULDIGITS 
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
        ldr x24, [sp, X24STORE]
        ldr x25, [sp, X25STORE]

        // pop the stack frame:
        add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
