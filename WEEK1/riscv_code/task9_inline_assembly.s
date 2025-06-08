	.file	"task9_inline_assembly.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zcf1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.type	rdcycle_demo, @function
rdcycle_demo:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,12288
	addi	a5,a5,57
	sw	a5,-20(s0)
	lw	a5,-20(s0)
 #APP
# 8 "task9_inline_assembly.c" 1
	mv a5, a5
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	rdcycle_demo, .-rdcycle_demo
	.align	1
	.type	add_inline, @function
add_inline:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 15 "task9_inline_assembly.c" 1
	add a5, a5, a4
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	add_inline, .-add_inline
	.align	1
	.type	demo_volatile, @function
demo_volatile:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a5,-36(s0)
 #APP
# 26 "task9_inline_assembly.c" 1
	slli a5, a5, 1
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	demo_volatile, .-demo_volatile
	.section	.rodata
	.align	2
.LC0:
	.string	"=== Task 9: Inline Assembly Basics ==="
	.align	2
.LC1:
	.string	"CSR 0xC00 (cycle counter) inline assembly demo\n"
	.align	2
.LC2:
	.string	"Simulated cycle count: %u\n"
	.align	2
.LC3:
	.string	"15 + 25 = %u (using inline assembly)\n"
	.align	2
.LC4:
	.string	"5 << 1 = %u (using volatile inline assembly)\n"
	.align	2
.LC5:
	.string	"\n=== Constraint Explanations ==="
	.align	2
.LC6:
	.string	"\"=r\"(output) - Output constraint:"
	.align	2
.LC7:
	.string	"  '=' means write-only (output)"
	.align	2
.LC8:
	.string	"  'r' means general-purpose register\n"
	.align	2
.LC9:
	.string	"\"r\"(input) - Input constraint:"
	.align	2
.LC10:
	.string	"  'r' means general-purpose register (read)\n"
	.align	2
.LC11:
	.string	"'volatile' keyword:"
	.align	2
.LC12:
	.string	"  Prevents compiler optimization"
	.align	2
.LC13:
	.string	"  Ensures assembly code is not removed"
	.align	2
.LC14:
	.string	"  Required for CSR reads and hardware operations"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	puts
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	puts
	call	rdcycle_demo
	sw	a0,-20(s0)
	lw	a1,-20(s0)
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	printf
	li	a1,25
	li	a0,15
	call	add_inline
	sw	a0,-24(s0)
	lw	a1,-24(s0)
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	li	a0,5
	call	demo_volatile
	sw	a0,-28(s0)
	lw	a1,-28(s0)
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	printf
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	puts
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	puts
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	puts
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	puts
	lui	a5,%hi(.LC9)
	addi	a0,a5,%lo(.LC9)
	call	puts
	lui	a5,%hi(.LC10)
	addi	a0,a5,%lo(.LC10)
	call	puts
	lui	a5,%hi(.LC11)
	addi	a0,a5,%lo(.LC11)
	call	puts
	lui	a5,%hi(.LC12)
	addi	a0,a5,%lo(.LC12)
	call	puts
	lui	a5,%hi(.LC13)
	addi	a0,a5,%lo(.LC13)
	call	puts
	lui	a5,%hi(.LC14)
	addi	a0,a5,%lo(.LC14)
	call	puts
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
