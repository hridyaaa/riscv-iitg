
.L2:
	.globl	main
	.hidden	main
	.type	main, @function
main:
	li	zero,1
	li	ra,2 
	li	sp,0x0002f000
	li	gp,4 
	li	tp,5 
	li	t0,6 
	li	t1,7 
	li	t2,8 
	li	s0,9 
	li	s1,10
	li	a0,11
	li	a1,12
	li	a2,13
	li	a3,14
	li	a4,15
	li	a5,16
	li	a6,17
	li	a7,18
	li	s2,19
	li	s3,20
	li	s4,21
	li	s5,22
	li	s6,23
	li	s7,24
	li	s8,25
	li	s9,26
	li	s10,27
	li	s11,28
	li	t3,29
	li	t4,30
	li	t5,31
	li	t6,32
	j proc1
	
	
proc1:
	addi	a2,a1,0x500
	addi	a3,a2,0x500
	slti	a4,a3,-1
	sltiu	a4,a3,-1
	sltiu	a4,zero,1
	
	li 		a5,15
	andi 	a6,a5,-1
	ori 	a6,a5,-1
	xori 	a6,a5,-1
	
	li 		a2,255
	slli 	a3,a2,4
	srli 	a4,a2,4
	li  	a6,-3
	srai 	a7,a6,1
	
	lui 	a2, 0xff
	auipc 	a2, 0xf00
	
	li 		a2,5
	li 		a3,3
	add 	a4,a2,a3
	sub 	a5,a2,a3
	sub 	a6,a3,a2
	
	li 		a4,-1
	slt 	a6,a3,a2
	slt 	a6,a3,a4
	sltu 	a6,a4,a3
	li		a2,0
	sltu 	a6,zero,a2
	
	li 		a2,15
	li 		a3,-1
	and 	a6,a2,a3
	or	 	a6,a2,a3
	xor 	a6,a2,a3
	
	li 		a2,255
	li 		a3,4
	sll 	a4,a2,a3
	srl 	a5,a2,a3
	
	li  	a2,-3
	li  	a3,1
	sra 	a4,a2,a3
	
	jal 	func1 # or (jal ra,func1)
	
	li  	a2,3
	li  	a3,3
	li  	a4,-1
	beq 	a2,a4,proc2
	beq 	a2,a3,proc2
	li 		a6,-1
	
proc2:
	bne 	a2,a3,proc3
	bne 	a2,a4,proc3
	li 		a6,-1
	
proc3:
	blt 	a2,a4,proc4
	blt 	a4,a2,proc4
	li 		a6,-1
	
proc4:
	bltu 	a4,a2,proc5
	bltu 	a2,a4,proc5
	li 		a6,-1
	
proc5:
	bge 	a4,a2,proc6
	bge 	a2,a3,proc6
	li 		a6,-1
	
proc6:
	bgeu 	a4,a2,proc7
	bgeu 	a4,a2,proc7
	li 		a6,-1
	
proc7:
	li		a2,0x00010407
	sw		a2,8(sp)
	sh		a2,14(sp)
	sb		a2,17(sp)
	lw		a6,8(sp)
	lh		a6,14(sp)
	lb		a6,17(sp)
	
	li		a3,-1
	sw		a3,8(sp)
	sh		a3,14(sp)
	sb		a3,17(sp)
	lw		a6,8(sp)
	lh		a6,14(sp)
	lhu		a6,14(sp)
	lb		a6,17(sp)
	lbu		a6,17(sp)
	
	li		a2,12
	li		a3,13
	li		a4,14
	sw		a2,14(sp)
	lw		a3,14(sp)
	add		a6,a3,a4 # result should be 26 (0x1a)
	
	li		a4,14
	li		a5,15
	slli	a5,a5,0x2
    add     a5,a5,a4
    lw	    a5,0(sp)
    add     a5,a5,a4
	
	addi	a0,s0,1184
    jal	    ra,func1
    addi	a0,sp,8
	
	li		a1,15
	addi    a1,a1,1
	jal     ra,func2
	addi    a1,a1,1
	addi    a1,a1,1
	addi    a1,a1,1
	
	li		a2,-5
	li		a3,12
	li		a4,13
	# mul		a6,a3,a4
	# mulh	a6,a3,a4
	# mulhu	a6,a3,a4
	# mulhsu	a6,a3,a4
	# mulh	a7,a2,a4
	# mulhu	a7,a2,a4
	# mulhsu	a7,a2,a4
	
	# div		a6,a3,a4
	# rem		a6,a3,a4
	# divu	a6,a3,a4
	# remu	a6,a3,a4
	
	# fadd.s	f3,f1,f2
	# fsub.s	f4,f1,f2
	# fsub.s	f4,f2,f1
	# fmul.s	f5,f1,f2
	# fdiv.s	f6,f1,f2
	# fmin.s	f7,f1,f2
	# fmax.s	f8,f1,f2
	
div_jump:
	li		a2,10
	li		a4,-1
	div	    a4,a4,a2
	bnez	a4,div_jump
	
	j		finish
	
func1:
    addi	sp,sp,16
	ret

func2:
    addi	a1,a1,1
    addi	a1,a1,1
	ret
    addi	a1,a1,1
    addi	a1,a1,1
    addi	a1,a1,1
	
finish:
	j finish




