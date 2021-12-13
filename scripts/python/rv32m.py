#!/bin/bash python

def rv32m(inst, file_inst):

	import rv32variables
	# file_inst = open("output/sw_instructions.txt","a")
	
	y = bin(int(inst, 16))[2:].zfill(32)
	# file_inst.write("Instrution =", y, "PC =", hex(rv32variables.pc))
	y = y[::-1]
	opcode = y[6::-1]
	rd = int(y[11:6:-1],2)
	rv32variables.rdadd = rd 
	if rd == 0:
		rd = 32
		rv32variables.valid_branch = 0
	rs1 = int(y[19:14:-1],2)
	rs2 = int(y[24:19:-1],2)
	funct3 = y[14:11:-1]
	funct7 = y[31:24:-1]
	shamt = rs2
	imm_I = y[31:19:-1]
	sign_I = imm_I.rjust(32,imm_I[0])
	imm_S = y[31:24:-1]+y[11:6:-1]
	sign_S = imm_S.rjust(32,imm_S[0])
	imm_B = y[31]+y[7]+y[30:24:-1]+y[11:7:-1]+'0'
	sign_B = imm_B.rjust(32,imm_B[0])
	imm_U = y[31:11:-1]
	sign_U = imm_U.rjust(32,imm_U[0])
	imm_J = y[31]+y[19:11:-1]+y[20]+y[30:20:-1]+'0'
	sign_J = imm_J.rjust(32,imm_J[0])
	
	unsigned_rs1 = int(rv32variables.reg[rs1],16)
	unsigned_rs2 = int(rv32variables.reg[rs2],16)
	
	bin_rs1 = bin(unsigned_rs1)[2:].zfill(32)
	bin_rs2 = bin(unsigned_rs2)[2:].zfill(32)
	
	if bin_rs1[0]=='1':
		signed_rs1 = -2147483648 + int(bin_rs1[1:],2)
	else:
		signed_rs1 = int(bin_rs1,2)
	
	if bin_rs2[0]=='1':
		signed_rs2 = -2147483648 + int(bin_rs2[1:],2)
	else:
		signed_rs2 = int(bin_rs2,2)
	
###########   MUL, MULH, MULHSU, MULHU    #########
	
	if opcode=='0001011' and funct7=='0000000' and funct3=='000':
		file_inst.write("MAC  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = (unsigned_rs1 * unsigned_rs2) + rv32variables.mac
		rv32variables.mac = result
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[8:16]
		rv32variables.rden = 1
	elif opcode=='0001011' and funct7=='0000000' and funct3=='001':
		file_inst.write("MACH  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = (signed_rs1 * signed_rs2) + rv32variables.mac
		rv32variables.mac = result
		if result<0:
			result = 18446744073709551616 + result
			result = bin(result)[2:]
			result = result.rjust(64,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0001011' and funct7=='0000000' and funct3=='010':
		file_inst.write("MACHSU  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = (signed_rs1 * unsigned_rs2) + rv32variables.mac
		rv32variables.mac = result
		if result<0:
			result = 18446744073709551616 + result
			result = bin(result)[2:]
			result = result.rjust(64,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0001011' and funct7=='0000000' and funct3=='011':
		file_inst.write("MACHU  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = (unsigned_rs1 * unsigned_rs2) + rv32variables.mac
		rv32variables.mac = result
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='000':
		file_inst.write("MUL  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = unsigned_rs1 * unsigned_rs2
		rv32variables.mac = result
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[8:16]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='001':
		file_inst.write("MULH  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = signed_rs1 * signed_rs2
		rv32variables.mac = result
		if result<0:
			result = 18446744073709551616 + result
			result = bin(result)[2:]
			result = result.rjust(64,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='010':
		file_inst.write("MULHSU  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = signed_rs1 * unsigned_rs2
		rv32variables.mac = result
		if result<0:
			result = 18446744073709551616 + result
			result = bin(result)[2:]
			result = result.rjust(64,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='011':
		file_inst.write("MULHU  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		result = unsigned_rs1 * unsigned_rs2
		rv32variables.mac = result
		result = hex(result)[2:]
		result = result.zfill(16)
		rv32variables.reg[rd] = result[0:8]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='100':
		file_inst.write("DIV  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		if signed_rs2==0:
			result1 = -1
			result  = 0xffffffff
		else:
			result1 = signed_rs1 / signed_rs2
			result = abs(signed_rs1) / abs(signed_rs2)
		if result1<-1:
			result = 4294967296 - result
			result = bin(result)[2:]
			result = result.rjust(32,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='101':
		file_inst.write("DIVU  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		if signed_rs2==0:
			result = 0xffffffff
		else :
			result = unsigned_rs1 / unsigned_rs2
		result = hex(result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='110':
		file_inst.write("REM  rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		if signed_rs2==0:
			result1 = signed_rs1
			result  = abs(signed_rs1)
		else:
			result1 = signed_rs1 % signed_rs2
			result = abs(signed_rs1) % abs(signed_rs2)
		if result1<0:
			result = 4294967296 - result
			result = bin(result)[2:]
			result = result.rjust(32,'1')
			result = int(result,2)
		result = hex(result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result
		rv32variables.rden = 1
	elif opcode=='0110011' and funct7=='0000001' and funct3=='111':
		file_inst.write("REMU rd = %d, rs1 = %d, rs2 = %d\n" %(rd,rs1,rs2))
		if unsigned_rs2==0:
			result  = unsigned_rs1
		else:
			result = unsigned_rs1 % unsigned_rs2
		result = hex(result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result
		rv32variables.rden = 1
		
	# file_inst.close()
	
	
	