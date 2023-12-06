	.arch armv8-a
	.file	"bigintadd.c"
	.text
	.align	2
	.type	BigInt_larger, %function
BigInt_larger:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	x0, [sp, 8]
	str	x1, [sp]
	ldr	x1, [sp, 8]
	ldr	x0, [sp]
	cmp	x1, x0
	ble	.L2
	ldr	x0, [sp, 8]
	str	x0, [sp, 24]
	b	.L3
.L2:
	ldr	x0, [sp]
	str	x0, [sp, 24]
.L3:
	ldr	x0, [sp, 24]
	add	sp, sp, 32
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	BigInt_larger, .-BigInt_larger
	.section	.rodata
	.align	3
.LC0:
	.string	"bigintadd.c"
	.align	3
.LC1:
	.string	"oAddend1 != NULL"
	.align	3
.LC2:
	.string	"oAddend2 != NULL"
	.align	3
.LC3:
	.string	"oSum != NULL"
	.align	3
.LC4:
	.string	"oSum != oAddend1"
	.align	3
.LC5:
	.string	"oSum != oAddend2"
	.text
	.align	2
	.global	BigInt_add
	.type	BigInt_add, %function
BigInt_add:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp
	str	x0, [sp, 40]
	str	x1, [sp, 32]
	str	x2, [sp, 24]
	ldr	x0, [sp, 40]
	cmp	x0, 0
	bne	.L6
	adrp	x0, __PRETTY_FUNCTION__.0
	add	x3, x0, :lo12:__PRETTY_FUNCTION__.0
	mov	w2, 41
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	__assert_fail
.L6:
	ldr	x0, [sp, 32]
	cmp	x0, 0
	bne	.L7
	adrp	x0, __PRETTY_FUNCTION__.0
	add	x3, x0, :lo12:__PRETTY_FUNCTION__.0
	mov	w2, 42
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	__assert_fail
.L7:
	ldr	x0, [sp, 24]
	cmp	x0, 0
	bne	.L8
	adrp	x0, __PRETTY_FUNCTION__.0
	add	x3, x0, :lo12:__PRETTY_FUNCTION__.0
	mov	w2, 43
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	__assert_fail
.L8:
	ldr	x1, [sp, 24]
	ldr	x0, [sp, 40]
	cmp	x1, x0
	bne	.L9
	adrp	x0, __PRETTY_FUNCTION__.0
	add	x3, x0, :lo12:__PRETTY_FUNCTION__.0
	mov	w2, 44
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	__assert_fail
.L9:
	ldr	x1, [sp, 24]
	ldr	x0, [sp, 32]
	cmp	x1, x0
	bne	.L10
	adrp	x0, __PRETTY_FUNCTION__.0
	add	x3, x0, :lo12:__PRETTY_FUNCTION__.0
	mov	w2, 45
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	__assert_fail
.L10:
	ldr	x0, [sp, 40]
	ldr	x2, [x0]
	ldr	x0, [sp, 32]
	ldr	x0, [x0]
	mov	x1, x0
	mov	x0, x2
	bl	BigInt_larger
	str	x0, [sp, 56]
	ldr	x0, [sp, 24]
	ldr	x0, [x0]
	ldr	x1, [sp, 56]
	cmp	x1, x0
	bge	.L11
	ldr	x0, [sp, 24]
	add	x0, x0, 8
	mov	x2, 262144
	mov	w1, 0
	bl	memset
.L11:
	str	xzr, [sp, 72]
	str	xzr, [sp, 64]
	b	.L12
.L15:
	ldr	x0, [sp, 72]
	str	x0, [sp, 48]
	str	xzr, [sp, 72]
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 64]
	lsl	x0, x0, 3
	add	x0, x1, x0
	ldr	x0, [x0, 8]
	ldr	x1, [sp, 48]
	add	x0, x1, x0
	str	x0, [sp, 48]
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 64]
	lsl	x0, x0, 3
	add	x0, x1, x0
	ldr	x0, [x0, 8]
	ldr	x1, [sp, 48]
	cmp	x1, x0
	bcs	.L13
	mov	x0, 1
	str	x0, [sp, 72]
.L13:
	ldr	x1, [sp, 32]
	ldr	x0, [sp, 64]
	lsl	x0, x0, 3
	add	x0, x1, x0
	ldr	x0, [x0, 8]
	ldr	x1, [sp, 48]
	add	x0, x1, x0
	str	x0, [sp, 48]
	ldr	x1, [sp, 32]
	ldr	x0, [sp, 64]
	lsl	x0, x0, 3
	add	x0, x1, x0
	ldr	x0, [x0, 8]
	ldr	x1, [sp, 48]
	cmp	x1, x0
	bcs	.L14
	mov	x0, 1
	str	x0, [sp, 72]
.L14:
	ldr	x1, [sp, 24]
	ldr	x0, [sp, 64]
	lsl	x0, x0, 3
	add	x0, x1, x0
	ldr	x1, [sp, 48]
	str	x1, [x0, 8]
	ldr	x0, [sp, 64]
	add	x0, x0, 1
	str	x0, [sp, 64]
.L12:
	ldr	x1, [sp, 64]
	ldr	x0, [sp, 56]
	cmp	x1, x0
	blt	.L15
	ldr	x0, [sp, 72]
	cmp	x0, 1
	bne	.L16
	ldr	x0, [sp, 56]
	cmp	x0, 32768
	bne	.L17
	mov	w0, 0
	b	.L18
.L17:
	ldr	x1, [sp, 24]
	ldr	x0, [sp, 56]
	lsl	x0, x0, 3
	add	x0, x1, x0
	mov	x1, 1
	str	x1, [x0, 8]
	ldr	x0, [sp, 56]
	add	x0, x0, 1
	str	x0, [sp, 56]
.L16:
	ldr	x0, [sp, 24]
	ldr	x1, [sp, 56]
	str	x1, [x0]
	mov	w0, 1
.L18:
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	BigInt_add, .-BigInt_add
	.section	.rodata
	.align	3
	.type	__PRETTY_FUNCTION__.0, %object
	.size	__PRETTY_FUNCTION__.0, 11
__PRETTY_FUNCTION__.0:
	.string	"BigInt_add"
	.ident	"GCC: (GNU) 11.3.1 20221121 (Red Hat 11.3.1-4)"
	.section	.note.GNU-stack,"",@progbits
