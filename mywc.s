//--------------------------------------------------------------------
// mywc.s                                                            
// Author: Siling & Alejandra                                         
//--------------------------------------------------------------------

.equ  FALSE, 0
.equ TRUE, 1
.equ EOF, 4,294,967,295

//--------------------------------------------------------------------

    .section .rodata

printfFormatStr:
    .string "%7ld %7ld %7ld\n"


//--------------------------------------------------------------------

    .section .data

lLineCount:
    .quad   0

lWordCount:
    .quad   0

lCharCount:
    .quad   0

iInWord:
    .word FALSE

//--------------------------------------------------------------------

    .section  .bss
iChar:
    .skip   4

//--------------------------------------------------------------------

.section .text

    //--------------------------------------------------------------------

    // Write to stdout counts of how many lines, words, and characters
    // are in stdin. A word is a sequence of non-whitespace characters.
    // Whitespace is defined by the isspace() function. Return 0. 

    // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:

    // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

// w1 --> iChar, x2-->lcharCount (), x3 -> lWordCount, W5 ->iInWord

wcLoop:
    // if ((iChar = getchar()) == EOF) goto wcLoopEnd;
    // iChar = getchar() (getChar returns to w0)
    // adr x1, iChar
    bl  getchar
    str w0, [x1]
    ldr w0, [x1]
    cmp w0, EOF
    beq wcLoopEnd

    // lCharCount++; 
    adr x0, lCharCount
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]


    // if (!isspace(iChar)) goto else1;
    adr x1, iChar
    ldr w0, [x1]
    bl isspace
    cmp w0, 0
    beq else1

    //lWordCount++
    adr x0, lWordCount
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]

    //iInWord = FALSE
    adr x0, iInWord
    mov w1, FALSE
    str w1, [x0]

    ifWordEnd:

    // goto endif1;
    b endif1

    else1:

    // if (iInWord)
    adr x0, iInWord
    ldr w1, [x0]
    cmp w1, 0
    // goto endif2
    bne endif2

    // iInWord = TRUE;
    adr x0, iInWord
    mov w1, TRUE
    str w1, [x0]

    endif2:

    endif1:

    //if (!(iChar == '\n')) goto endif3
    adr x0, iChar
    ldr w1, [x0]
    cmp w1, 10
    bne endif3

    //    lLineCount++;
    adr x0, lLineCount
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]

    endif3:

    // goto wcLoop;
    b wcLoop

    wcLoopEnd:

    // if (!iInWord) goto endif4;
    adr x0, iInWord
    ldr w1, [x0]
    cmp w1, 0
    beq endif4

    endif4:

    // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);

    adr x0, printfFormatStr
    adr x1, lLineCount
    ldr x1, [x1]
    adr x2, lWordCount
    ldr x2, [x2]
    adr x3, lCharCount
    ldr x3, [x3]
    bl  printf

     // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

    .size   main, (. - main)