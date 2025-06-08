	.file	"task14_atomic_demo.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	shared_counter
	.section	.sbss,"aw",@nobits
	.align	2
	.type	shared_counter, @object
	.size	shared_counter, 4
shared_counter:
	.zero	4
	.globl	lock_variable
	.align	2
	.type	lock_variable, @object
	.size	lock_variable, 4
lock_variable:
	.zero	4
	.text
	.align	1
	.type	atomic_load_reserved, @function
atomic_load_reserved:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a5,-36(s0)
 #APP
# 10 "task14_atomic_demo.c" 1
	lr.w a5, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_load_reserved, .-atomic_load_reserved
	.align	1
	.type	atomic_store_conditional, @function
atomic_store_conditional:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 16 "task14_atomic_demo.c" 1
	sc.w a5, a4, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_store_conditional, .-atomic_store_conditional
	.align	1
	.type	atomic_add, @function
atomic_add:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 23 "task14_atomic_demo.c" 1
	amoadd.w a5, a4, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_add, .-atomic_add
	.align	1
	.type	atomic_swap, @function
atomic_swap:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 29 "task14_atomic_demo.c" 1
	amoswap.w a5, a4, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_swap, .-atomic_swap
	.align	1
	.type	atomic_and, @function
atomic_and:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 35 "task14_atomic_demo.c" 1
	amoand.w a5, a4, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_and, .-atomic_and
	.align	1
	.type	atomic_or, @function
atomic_or:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	lw	a4,-40(s0)
 #APP
# 41 "task14_atomic_demo.c" 1
	amoor.w a5, a4, (a5)
# 0 "" 2
 #NO_APP
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_or, .-atomic_or
	.align	1
	.globl	atomic_increment_lr_sc
	.type	atomic_increment_lr_sc, @function
atomic_increment_lr_sc:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
.L14:
	lw	a0,-36(s0)
	call	atomic_load_reserved
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	addi	a5,a5,1
	mv	a1,a5
	lw	a0,-36(s0)
	call	atomic_store_conditional
	sw	a0,-24(s0)
	lw	a5,-24(s0)
	bne	a5,zero,.L14
	nop
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	atomic_increment_lr_sc, .-atomic_increment_lr_sc
	.align	1
	.globl	acquire_lock
	.type	acquire_lock, @function
acquire_lock:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	nop
.L16:
	li	a1,1
	lw	a0,-20(s0)
	call	atomic_swap
	mv	a5,a0
	bne	a5,zero,.L16
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	acquire_lock, .-acquire_lock
	.align	1
	.globl	release_lock
	.type	release_lock, @function
release_lock:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	li	a1,0
	lw	a0,-20(s0)
	call	atomic_swap
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	release_lock, .-release_lock
	.align	1
	.globl	demonstrate_atomic_operations
	.type	demonstrate_atomic_operations, @function
demonstrate_atomic_operations:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a1,5
	lui	a5,%hi(shared_counter)
	addi	a0,a5,%lo(shared_counter)
	call	atomic_add
	sw	a0,-20(s0)
	li	a1,100
	lui	a5,%hi(shared_counter)
	addi	a0,a5,%lo(shared_counter)
	call	atomic_swap
	sw	a0,-20(s0)
	li	a1,255
	lui	a5,%hi(shared_counter)
	addi	a0,a5,%lo(shared_counter)
	call	atomic_and
	sw	a0,-20(s0)
	li	a1,-2147483648
	lui	a5,%hi(shared_counter)
	addi	a0,a5,%lo(shared_counter)
	call	atomic_or
	sw	a0,-20(s0)
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	demonstrate_atomic_operations, .-demonstrate_atomic_operations
	.align	1
	.globl	demonstrate_lock_free_increment
	.type	demonstrate_lock_free_increment, @function
demonstrate_lock_free_increment:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	zero,-20(s0)
	j	.L20
.L21:
	lui	a5,%hi(shared_counter)
	addi	a0,a5,%lo(shared_counter)
	call	atomic_increment_lr_sc
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L20:
	lw	a4,-20(s0)
	li	a5,9
	ble	a4,a5,.L21
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	demonstrate_lock_free_increment, .-demonstrate_lock_free_increment
	.align	1
	.globl	demonstrate_spinlock
	.type	demonstrate_spinlock, @function
demonstrate_spinlock:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(lock_variable)
	addi	a0,a5,%lo(lock_variable)
	call	acquire_lock
	lui	a5,%hi(shared_counter)
	lw	a5,%lo(shared_counter)(a5)
	addi	a4,a5,1
	lui	a5,%hi(shared_counter)
	sw	a4,%lo(shared_counter)(a5)
	lui	a5,%hi(lock_variable)
	addi	a0,a5,%lo(lock_variable)
	call	release_lock
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	demonstrate_spinlock, .-demonstrate_spinlock
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(shared_counter)
	sw	zero,%lo(shared_counter)(a5)
	lui	a5,%hi(lock_variable)
	sw	zero,%lo(lock_variable)(a5)
	call	demonstrate_atomic_operations
	call	demonstrate_lock_free_increment
	call	demonstrate_spinlock
	li	a5,0
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
