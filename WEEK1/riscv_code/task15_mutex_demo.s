	.file	"task15_mutex_demo.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	spinlock
	.section	.sbss,"aw",@nobits
	.align	2
	.type	spinlock, @object
	.size	spinlock, 4
spinlock:
	.zero	4
	.globl	shared_counter
	.align	2
	.type	shared_counter, @object
	.size	shared_counter, 4
shared_counter:
	.zero	4
	.globl	thread1_iterations
	.align	2
	.type	thread1_iterations, @object
	.size	thread1_iterations, 4
thread1_iterations:
	.zero	4
	.globl	thread2_iterations
	.align	2
	.type	thread2_iterations, @object
	.size	thread2_iterations, 4
thread2_iterations:
	.zero	4
	.text
	.align	1
	.globl	spinlock_acquire
	.type	spinlock_acquire, @function
spinlock_acquire:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a4,-36(s0)
 #APP
# 12 "task15_mutex_demo.c" 1
	1:
    lr.w    a5, (a4)
    bnez    a5, 1b
    li      a5, 1
    sc.w    a5, a5, (a4)
    bnez    a5, 1b

# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	spinlock_acquire, .-spinlock_acquire
	.align	1
	.globl	spinlock_release
	.type	spinlock_release, @function
spinlock_release:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
 #APP
# 27 "task15_mutex_demo.c" 1
	sw      zero, 0(a5)

# 0 "" 2
 #NO_APP
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	spinlock_release, .-spinlock_release
	.align	1
	.globl	increment_shared_counter
	.type	increment_shared_counter, @function
increment_shared_counter:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	zero,-20(s0)
	j	.L4
.L7:
	lui	a5,%hi(spinlock)
	addi	a0,a5,%lo(spinlock)
	call	spinlock_acquire
	lui	a5,%hi(shared_counter)
	lw	a5,%lo(shared_counter)(a5)
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
	lui	a5,%hi(shared_counter)
	lw	a4,-24(s0)
	sw	a4,%lo(shared_counter)(a5)
	lw	a4,-36(s0)
	li	a5,1
	bne	a4,a5,.L5
	lui	a5,%hi(thread1_iterations)
	lw	a5,%lo(thread1_iterations)(a5)
	addi	a4,a5,1
	lui	a5,%hi(thread1_iterations)
	sw	a4,%lo(thread1_iterations)(a5)
	j	.L6
.L5:
	lui	a5,%hi(thread2_iterations)
	lw	a5,%lo(thread2_iterations)(a5)
	addi	a4,a5,1
	lui	a5,%hi(thread2_iterations)
	sw	a4,%lo(thread2_iterations)(a5)
.L6:
	lui	a5,%hi(spinlock)
	addi	a0,a5,%lo(spinlock)
	call	spinlock_release
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L4:
	lw	a4,-20(s0)
	lw	a5,-40(s0)
	blt	a4,a5,.L7
	nop
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	increment_shared_counter, .-increment_shared_counter
	.align	1
	.globl	thread1_function
	.type	thread1_function, @function
thread1_function:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a5,49152
	addi	a1,a5,848
	li	a0,1
	call	increment_shared_counter
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	thread1_function, .-thread1_function
	.align	1
	.globl	thread2_function
	.type	thread2_function, @function
thread2_function:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a5,49152
	addi	a1,a5,848
	li	a0,2
	call	increment_shared_counter
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	thread2_function, .-thread2_function
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
# 71 "task15_mutex_demo.c" 1
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
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(spinlock)
	sw	zero,%lo(spinlock)(a5)
	lui	a5,%hi(shared_counter)
	sw	zero,%lo(shared_counter)(a5)
	lui	a5,%hi(thread1_iterations)
	sw	zero,%lo(thread1_iterations)(a5)
	lui	a5,%hi(thread2_iterations)
	sw	zero,%lo(thread2_iterations)(a5)
	call	thread1_function
	li	a0,1000
	call	delay
	call	thread2_function
	li	a5,0
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
