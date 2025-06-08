main:
	lui	a0,%hi(.LC0)
	addi	sp,sp,-16
	addi	a0,a0,%lo(.LC0)
	sw	ra,12(sp)
	call	puts
	lw	ra,12(sp)
	li	a0,0
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
