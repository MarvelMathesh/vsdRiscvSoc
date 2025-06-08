	.file	"task10_gpio.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zcf1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	toggle_gpio
	.type	toggle_gpio, @function
toggle_gpio:
	li	a5,268509184
	li	a4,1
	sw	a4,0(a5)
	lw	a4,0(a5)
	not	a4,a4
	sw	a4,0(a5)
	lw	a4,0(a5)
	ori	a4,a4,1
	sw	a4,0(a5)
	lw	a4,0(a5)
	andi	a4,a4,-3
	sw	a4,0(a5)
	ret
	.size	toggle_gpio, .-toggle_gpio
	.align	1
	.globl	gpio_operations
	.type	gpio_operations, @function
gpio_operations:
	li	a5,268509184
	sw	zero,0(a5)
	li	a4,1
	sw	a4,0(a5)
	li	a4,-1
	sw	a4,0(a5)
	sw	zero,0(a5)
	ret
	.size	gpio_operations, .-gpio_operations
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	toggle_gpio
	li	a5,268509184
	sw	zero,0(a5)
	li	a4,1
	sw	a4,0(a5)
	li	a4,-1
	sw	a4,0(a5)
	li	a3,999424
	sw	zero,0(a5)
	addi	a3,a3,576
	lui	a4,%hi(counter.0)
.L5:
	lw	a5,%lo(counter.0)(a4)
	addi	a5,a5,1
	sw	a5,%lo(counter.0)(a4)
	lw	a5,%lo(counter.0)(a4)
	ble	a5,a3,.L5
	lw	ra,12(sp)
	li	a0,0
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.section	.sbss,"aw",@nobits
	.align	2
	.type	counter.0, @object
	.size	counter.0, 4
counter.0:
	.zero	4
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
