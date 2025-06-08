	.file	"task17_simple_endian.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zmmul1p0_zaamo1p0_zalrsc1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	2
.LC0:
	.string	"RISC-V Endianness Test"
	.align	2
.LC1:
	.string	"======================"
	.align	2
.LC2:
	.string	"32-bit value: 0x%08X\n"
	.align	2
.LC3:
	.string	"Byte order: "
	.align	2
.LC4:
	.string	"%02X "
	.align	2
.LC5:
	.string	"Result: RISC-V is LITTLE-ENDIAN"
	.align	2
.LC6:
	.string	"Explanation: LSB (0x04) is at lowest address"
	.align	2
.LC7:
	.string	"Result: RISC-V is BIG-ENDIAN"
	.align	2
.LC8:
	.string	"Explanation: MSB (0x01) is at lowest address"
	.align	2
.LC9:
	.string	"Result: Unknown endianness"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,16908288
	addi	a5,a5,772
	sw	a5,-24(s0)
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	puts
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	puts
	lw	a5,-24(s0)
	mv	a1,a5
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	printf
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	sw	zero,-20(s0)
	j	.L2
.L3:
	lw	a5,-20(s0)
	addi	a5,a5,-16
	add	a5,a5,s0
	lbu	a5,-8(a5)
	mv	a1,a5
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	printf
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,3
	ble	a4,a5,.L3
	li	a0,10
	call	putchar
	lbu	a4,-24(s0)
	li	a5,4
	bne	a4,a5,.L4
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	puts
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	puts
	j	.L5
.L4:
	lbu	a4,-24(s0)
	li	a5,1
	bne	a4,a5,.L6
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	puts
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	puts
	j	.L5
.L6:
	lui	a5,%hi(.LC9)
	addi	a0,a5,%lo(.LC9)
	call	puts
.L5:
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
