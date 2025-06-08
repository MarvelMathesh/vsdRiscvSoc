	.file	"task13_timer_interrupt.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0_zicsr2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	mtime
	.section	.sdata,"aw"
	.align	2
	.type	mtime, @object
	.size	mtime, 4
mtime:
	.word	33603576
	.globl	mtimecmp
	.align	2
	.type	mtimecmp, @object
	.size	mtimecmp, 4
mtimecmp:
	.word	33570816
	.globl	interrupt_count
	.section	.sbss,"aw",@nobits
	.align	2
	.type	interrupt_count, @object
	.size	interrupt_count, 4
interrupt_count:
	.zero	4
	.text
	.align	1
	.globl	timer_interrupt_handler
	.type	timer_interrupt_handler, @function
timer_interrupt_handler:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	a0,36(sp)
	sw	a1,32(sp)
	sw	a2,28(sp)
	sw	a3,24(sp)
	sw	a4,20(sp)
	sw	a5,16(sp)
	sw	a6,12(sp)
	sw	a7,8(sp)
	addi	s0,sp,48
	lui	a5,%hi(mtime)
	lw	a5,%lo(mtime)(a5)
	lw	a4,0(a5)
	lw	a5,4(a5)
	lui	a3,%hi(mtimecmp)
	lw	a6,%lo(mtimecmp)(a3)
	li	a0,9998336
	addi	a0,a0,1664
	li	a1,0
	add	a2,a4,a0
	mv	a7,a2
	sltu	a7,a7,a4
	add	a3,a5,a1
	add	a5,a7,a3
	mv	a3,a5
	mv	a4,a2
	mv	a5,a3
	sw	a4,0(a6)
	sw	a5,4(a6)
	lui	a5,%hi(interrupt_count)
	lw	a5,%lo(interrupt_count)(a5)
	addi	a4,a5,1
	lui	a5,%hi(interrupt_count)
	sw	a4,%lo(interrupt_count)(a5)
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	a0,36(sp)
	lw	a1,32(sp)
	lw	a2,28(sp)
	lw	a3,24(sp)
	lw	a4,20(sp)
	lw	a5,16(sp)
	lw	a6,12(sp)
	lw	a7,8(sp)
	addi	sp,sp,48
	mret
	.size	timer_interrupt_handler, .-timer_interrupt_handler
	.align	1
	.type	read_csr_mstatus, @function
read_csr_mstatus:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
 #APP
# 25 "task13_timer_interrupt.c" 1
	csrr a5, mstatus
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	read_csr_mstatus, .-read_csr_mstatus
	.align	1
	.type	read_csr_mie, @function
read_csr_mie:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
 #APP
# 31 "task13_timer_interrupt.c" 1
	csrr a5, mie
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	read_csr_mie, .-read_csr_mie
	.align	1
	.type	write_csr_mstatus, @function
write_csr_mstatus:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
 #APP
# 37 "task13_timer_interrupt.c" 1
	csrw mstatus, a5
# 0 "" 2
 #NO_APP
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	write_csr_mstatus, .-write_csr_mstatus
	.align	1
	.type	write_csr_mie, @function
write_csr_mie:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
 #APP
# 41 "task13_timer_interrupt.c" 1
	csrw mie, a5
# 0 "" 2
 #NO_APP
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	write_csr_mie, .-write_csr_mie
	.align	1
	.type	write_csr_mtvec, @function
write_csr_mtvec:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
 #APP
# 45 "task13_timer_interrupt.c" 1
	csrw mtvec, a5
# 0 "" 2
 #NO_APP
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	write_csr_mtvec, .-write_csr_mtvec
	.align	1
	.globl	enable_timer_interrupt
	.type	enable_timer_interrupt, @function
enable_timer_interrupt:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	lui	a5,%hi(mtime)
	lw	a5,%lo(mtime)(a5)
	lw	a4,0(a5)
	lw	a5,4(a5)
	lui	a3,%hi(mtimecmp)
	lw	a6,%lo(mtimecmp)(a3)
	li	a0,9998336
	addi	a0,a0,1664
	li	a1,0
	add	a2,a4,a0
	mv	a7,a2
	sltu	a7,a7,a4
	add	a3,a5,a1
	add	a5,a7,a3
	mv	a3,a5
	mv	a4,a2
	mv	a5,a3
	sw	a4,0(a6)
	sw	a5,4(a6)
	lui	a5,%hi(timer_interrupt_handler)
	addi	a5,a5,%lo(timer_interrupt_handler)
	mv	a0,a5
	call	write_csr_mtvec
	call	read_csr_mie
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	ori	a5,a5,128
	sw	a5,-20(s0)
	lw	a0,-20(s0)
	call	write_csr_mie
	call	read_csr_mstatus
	sw	a0,-24(s0)
	lw	a5,-24(s0)
	ori	a5,a5,8
	sw	a5,-24(s0)
	lw	a0,-24(s0)
	call	write_csr_mstatus
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	enable_timer_interrupt, .-enable_timer_interrupt
	.align	1
	.globl	delay
	.type	delay, @function
delay:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	j	.L11
.L12:
 #APP
# 68 "task13_timer_interrupt.c" 1
	nop
# 0 "" 2
 #NO_APP
.L11:
	lw	a5,-20(s0)
	addi	a4,a5,-1
	sw	a4,-20(s0)
	bne	a5,zero,.L12
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	delay, .-delay
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	call	enable_timer_interrupt
	sw	zero,-20(s0)
.L17:
	lui	a5,%hi(interrupt_count)
	lw	a5,%lo(interrupt_count)(a5)
	lw	a4,-20(s0)
	beq	a4,a5,.L14
	lui	a5,%hi(interrupt_count)
	lw	a5,%lo(interrupt_count)(a5)
	sw	a5,-20(s0)
.L14:
	li	a5,98304
	addi	a0,a5,1696
	call	delay
	lui	a5,%hi(interrupt_count)
	lw	a4,%lo(interrupt_count)(a5)
	li	a5,4
	bgtu	a4,a5,.L20
	j	.L17
.L20:
	nop
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
