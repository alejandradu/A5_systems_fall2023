File Edit Options Buffers Tools Asm Help                           
        .arch armv8-a                                              
        .file   "mywc.c"                                           
        .text                                                      
        .local  lLineCount                                         
        .comm   lLineCount,8,8                                     
        .local  lWordCount                                         
        .comm   lWordCount,8,8                                     
        .local  lCharCount                                         
        .comm   lCharCount,8,8                                     
        .local  iChar                                              
        .comm   iChar,4,4                                          
        .local  iInWord                                            
        .comm   iInWord,4,4                                        
        .section        .rodata                                    
        .align  3                                                  
.LC0:                                                              
        .string "%7ld %7ld %7ld\n"                                 
        .text                                                      
        .align  2                                                  
        .global main                                               
        .type   main, %function                                    
main:                                                              
.LFB0:                                                             
        .cfi_startproc                                             
        stp     x29, x30, [sp, -16]!                               
        .cfi_def_cfa_offset 16                                     
        .cfi_offset 29, -16
        .cfi_offset 30, -8
        mov     x29, sp
        b       .L2
.L5:
        adrp    x0, lCharCount
        add     x0, x0, :lo12:lCharCount
        ldr     x0, [x0]
        add     x1, x0, 1
        adrp    x0, lCharCount
        add     x0, x0, :lo12:lCharCount
        str     x1, [x0]
        bl      __ctype_b_loc
        ldr     x1, [x0]
        adrp    x0, iChar
        add     x0, x0, :lo12:iChar
        ldr     w0, [x0]
        sxtw    x0, w0
        lsl     x0, x0, 1
        add     x0, x1, x0
        ldrh    w0, [x0]
        and     w0, w0, 8192
        cmp     w0, 0
        beq     .L3
        adrp    x0, iInWord
        add     x0, x0, :lo12:iInWord
        ldr     w0, [x0]
        cmp     w0, 0
-=--:----F1  mywc.s         Top (27,0)    Git:main  (Assembler) ---



// testing different stress sizes 