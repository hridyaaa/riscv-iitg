#!/bin/bash python

def rv32i(inst, file_inst):

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
	imm_S = y[31:24:-1]+y[11:6:-1]
	imm_B = y[31]+y[7]+y[30:24:-1]+y[11:7:-1]+'0'
	imm_U = y[31:11:-1]
	imm_J = y[31]+y[19:11:-1]+y[20]+y[30:20:-1]+'0'
	
	exs_I = imm_I.rjust(32,imm_I[0])
	exs_S = imm_S.rjust(32,imm_S[0])
	exs_B = imm_B.rjust(32,imm_B[0])
	exs_U = imm_U.rjust(32,imm_U[0])
	exs_J = imm_J.rjust(32,imm_J[0])
	
	if exs_I[0]=='1':
		sign_I = -2147483648 + int(exs_I[1:],2)
	else:
		sign_I = int(exs_I,2)
	
	if exs_S[0]=='1':
		sign_S = -2147483648 + int(exs_S[1:],2)
	else:
		sign_S = int(exs_S,2)
	
	if exs_B[0]=='1':
		sign_B = -2147483648 + int(exs_B[1:],2)
	else:
		sign_B = int(exs_B,2)
	
	if exs_U[0]=='1':
		sign_U = -2147483648 + int(exs_U[1:],2)
	else:
		sign_U = int(exs_U,2)
	
	if exs_J[0]=='1':
		sign_J = -2147483648 + int(exs_J[1:],2)
	else:
		sign_J = int(exs_J,2)
	
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
		
	
	if imm_I=='000000000001':
		csr_add = 1 
	elif imm_I=='000000000010':
		csr_add = 2 
	elif imm_I=='000000000011':
		csr_add = 3 
	elif imm_I=='110000000000':
		csr_add = 4 
	elif imm_I=='110000000001':
		csr_add = 5 
	elif imm_I=='110000000010':
		csr_add = 6 
	elif imm_I=='110010000000':
		csr_add = 7 
	elif imm_I=='110010000001':
		csr_add = 8 
	elif imm_I=='110010000010':
		csr_add = 9 
	else:
		csr_add = 0
	
###########   LUI, AUIPC, JAL, JALR    #########
	
	if opcode=='0110111':
		file_inst.write("LUI    rd = %d, imm = %s\n" %(rd,hex(int(imm_U,2))))
		rv32variables.reg[rd] = hex(int(imm_U,2))[2:].zfill(5) + '0'*3
		rv32variables.rden = 1
	elif opcode=='0010111':
		file_inst.write("AUIPC  rd = %d, imm = %s\n" %(rd,hex(int(imm_U,2))))
		sum = rv32variables.pc + int(hex(int(imm_U,2)) + '000', 16)
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.reg[rd] = sum[-8:]
		rv32variables.rden = 1
	elif opcode=='1101111':
		file_inst.write("JAL    rd = %d, imm = %s\n" %(rd,hex(int(imm_J,2))))
		if inst[0:8] == '0000006f':  rv32variables.write_file_en = 0
		next_pc = rv32variables.pc + sign_J
		result = rv32variables.pc + 4
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
		rv32variables.npc = next_pc
	elif opcode=='1100111' and funct3=='000':
		file_inst.write("JALR   rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		sum = int(sum[-8:],16)
		if rd!=32:
			# file_inst.write((hex(rv32variables.pc + 4)[2:]).zfill(8))
			rv32variables.reg[rd] = (hex(rv32variables.pc + 4)[2:]).zfill(8)
			rv32variables.rden = 1
		rv32variables.npc = sum
	
###########   BEQ, BNE, BLT, BGE, BLTU, BGEU    #########
	
	elif opcode=='1100011' and funct3=='000':
		file_inst.write("BEQ    rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		rv32variables.valid_branch = 0
		if (unsigned_rs1 == unsigned_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
	elif opcode=='1100011' and funct3=='001':
		file_inst.write("BNE    rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		#file_inst.write(unsigned_rs1, unsigned_rs2, int(imm_B,2), rv32variables.pc)
		rv32variables.valid_branch = 0
		if (unsigned_rs1 != unsigned_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
	elif opcode=='1100011' and funct3=='100':
		file_inst.write("BLT    rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		rv32variables.valid_branch = 0
		if (signed_rs1<signed_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
	elif opcode=='1100011' and funct3=='101':
		file_inst.write("BGE    rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		rv32variables.valid_branch = 0
		if (signed_rs1>=signed_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
	elif opcode=='1100011' and funct3=='110':
		file_inst.write("BLTU   rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		rv32variables.valid_branch = 0
		if (unsigned_rs1 < unsigned_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
	elif opcode=='1100011' and funct3=='111':
		file_inst.write("BGEU   rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_B,2))))
		rv32variables.valid_branch = 0
		if (unsigned_rs1>=unsigned_rs2):
			rv32variables.npc = rv32variables.pc + sign_B
			# rv32variables.valid_branch = 1
		
###########   LB, LH, LW, LBU, LHU    #########
	
	elif opcode=='0000011' and funct3=='000':
		file_inst.write("LB     rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.radd = sum[-8:]
		rv32variables.rdata = rv32variables.memory[int(rv32variables.radd,16)/4]
		temp = ((bin(int(rv32variables.radd,16))[2:]).zfill(2))[-2:]
		if temp == '11':
			rv32variables.rdata = rv32variables.rdata[0:2]
		elif temp == '10':
			rv32variables.rdata = rv32variables.rdata[2:4]
		elif temp == '01':
			rv32variables.rdata = rv32variables.rdata[4:6]
		else:
			rv32variables.rdata = rv32variables.rdata[6:8]
		bin_rdata = bin(int(rv32variables.rdata,16))[2:]
		bin_rdata = bin_rdata.zfill(8)
		bin_rdata = bin_rdata.rjust(32,bin_rdata[0])
		result = int(bin_rdata,2)
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0000011' and funct3=='001':
		file_inst.write("LH     rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.radd = sum[-8:]
		rv32variables.rdata = rv32variables.memory[int(rv32variables.radd,16)/4]
		temp = ((bin(int(rv32variables.radd,16))[2:]).zfill(2))[-2:]
		if temp[0] == '1':
			rv32variables.rdata = rv32variables.rdata[0:4]
		else :
			rv32variables.rdata = rv32variables.rdata[4:8]
		bin_rdata = bin(int(rv32variables.rdata,16))[2:]
		bin_rdata = bin_rdata.zfill(16)
		bin_rdata = bin_rdata.rjust(32,bin_rdata[0])
		result = int(bin_rdata,2)
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0000011' and funct3=='010':
		file_inst.write("LW     rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1<<32)-1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.radd = sum[-8:]
		# print int(rv32variables.radd,16)/4 
		rv32variables.rdata = rv32variables.memory[int(rv32variables.radd,16)/4][0:8]
		# file_inst.write("read channel ",rv32variables.radd, rv32variables.rdata)
		rv32variables.reg[rd] = rv32variables.rdata
		rv32variables.rden = 1
	elif opcode=='0000011' and funct3=='100':
		file_inst.write("LBU    rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.radd = sum[-8:]
		rv32variables.rdata = rv32variables.memory[int(rv32variables.radd,16)/4]
		temp = ((bin(int(rv32variables.radd,16))[2:]).zfill(2))[-2:]
		#file_inst.write(rv32variables.radd, rv32variables.rdata, temp
		if temp == '11':
			rv32variables.rdata = rv32variables.rdata[0:2]
		elif temp == '10':
			rv32variables.rdata = rv32variables.rdata[2:4]
		elif temp == '01':
			rv32variables.rdata = rv32variables.rdata[4:6]
		else:
			rv32variables.rdata = rv32variables.rdata[6:8]
		rv32variables.reg[rd] = '000000'+rv32variables.rdata
		rv32variables.rden = 1
	elif opcode=='0000011' and funct3=='101':
		file_inst.write("LHU    rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.radd = sum[-8:]
		rv32variables.rdata = rv32variables.memory[int(rv32variables.radd,16)/4]
		temp = ((bin(int(rv32variables.radd,16))[2:]).zfill(2))[-2:]
		if temp[0] == '1':
			rv32variables.rdata = rv32variables.rdata[0:4]
		# elif temp == '10':
			# rv32variables.rdata = rv32variables.rdata[2:6]
		else :
			rv32variables.rdata = rv32variables.rdata[4:8]
		rv32variables.reg[rd] = '0000'+rv32variables.rdata
		rv32variables.rden = 1
	
###########   SB, SH, SW    #########
	
	elif opcode=='0100011' and funct3=='000':
		rv32variables.wen = '001'
		file_inst.write("SB     rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_S,2))))
		sum = unsigned_rs1 + sign_S
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.wadd = sum[-8:]
		rv32variables.wdata = rv32variables.reg[rs2]
		rv32variables.wdata = '000000' + rv32variables.wdata[6:8]
		temp = ((bin(int(rv32variables.wadd,16))[2:]).zfill(2))[-2:]
		if temp == '11':
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.wdata[6:8] + rv32variables.memory[int(rv32variables.wadd,16)/4][2:8] + '\n'
		elif temp == '10':
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.memory[int(rv32variables.wadd,16)/4][0:2] +  rv32variables.wdata[6:8] + rv32variables.memory[int(rv32variables.wadd,16)/4][4:8] + '\n'
		elif temp == '01':
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.memory[int(rv32variables.wadd,16)/4][0:4] +  rv32variables.wdata[6:8] + rv32variables.memory[int(rv32variables.wadd,16)/4][6:8] + '\n'
		else :
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.memory[int(rv32variables.wadd,16)/4][0:6] + rv32variables.wdata[6:8] + '\n'
	elif opcode=='0100011' and funct3=='001':
		rv32variables.wen = '010'
		file_inst.write("SH     rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_S,2))))
		sum = unsigned_rs1 + sign_S
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.wadd = sum[-8:]
		rv32variables.wdata = rv32variables.reg[rs2]
		rv32variables.wdata = '0000' + rv32variables.wdata[4:8]
		temp = ((bin(int(rv32variables.wadd,16))[2:]).zfill(2))[-2:]
		if temp[0] == '1':
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.wdata[4:8] + rv32variables.memory[int(rv32variables.wadd,16)/4][4:8] + '\n'
		else :
			rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.memory[int(rv32variables.wadd,16)/4][0:4] + rv32variables.wdata[4:8] + '\n'
	elif opcode=='0100011' and funct3=='010':
		rv32variables.wen = '100'
		file_inst.write("SW     rs1 = %d, rs2 = %d, imm = %s\n" %(rs1,rs2,hex(int(imm_S,2))))
		sum = unsigned_rs1 + sign_S
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.wadd = sum[-8:]
		rv32variables.wdata = rv32variables.reg[rs2]
		rv32variables.memory[int(rv32variables.wadd,16)/4] = rv32variables.wdata + '\n'
	
###########   ADDI, SLTI, SLTIU, XORI, ORI, ANDI    #########
	
	elif opcode=='0010011' and funct3=='000':
		file_inst.write("ADDI   rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		sum = unsigned_rs1 + sign_I
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.reg[rd] = sum[-8:]
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='010':
		file_inst.write("SLTI   rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		if (signed_rs1 < sign_I):
			rv32variables.reg[rd] = '00000001'
		else:
			rv32variables.reg[rd] = '00000000'
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='011':
		file_inst.write("SLTIU  rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		if (unsigned_rs1 < int(exs_I,2)):
			rv32variables.reg[rd] = '00000001'
		else:
			rv32variables.reg[rd] = '00000000'
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='100':
		file_inst.write("XORI   rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		result = unsigned_rs1 ^ sign_I
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='110':
		file_inst.write("ORI    rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		result = unsigned_rs1 | sign_I
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='111':
		file_inst.write("ANDI   rd = %d, rs1 = %d, imm = %s\n" %(rd,rs1,hex(int(imm_I,2))))
		result = unsigned_rs1 & sign_I
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	
###########   SLLI, SRLI, SRAI    #########
	
	elif opcode=='0010011' and funct3=='001' and funct7=='0000000':
		file_inst.write("SLLI   rd = %d, rs1 = %d, shamt =%d\n" %(rd,rs1,shamt))
		result = unsigned_rs1 << shamt
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='101' and funct7=='0000000':
		file_inst.write("SRLI   rd = %d, rs1 = %d, shamt =%d\n" %(rd,rs1,shamt))
		result = unsigned_rs1 >> shamt
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0010011' and funct3=='101' and funct7=='0100000':
		file_inst.write("SRAI   rd = %d, rs1 = %d, shamt =%d\n" %(rd,rs1,shamt))
		sh_data = unsigned_rs1 >> shamt
		sh_data = (bin(sh_data)[2:]).zfill(32)
		#file_inst.write(sh_data)
		if len(bin(unsigned_rs1))==34:
			sh_data = ('1'*shamt)+sh_data[shamt:]
		else:
			sh_data = ('0'*shamt)+sh_data[shamt:]
		result = int(sh_data,2)
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	
###########   ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND    #########
	
	elif opcode=='0110011' and funct3=='000' and funct7=='0000000':
		file_inst.write("ADD    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		sum = unsigned_rs1 + unsigned_rs2
		sum = hex(((1 << 32) - 1) & sum)[2:]
		sum = sum.zfill(8)
		rv32variables.reg[rd] = sum[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='000' and funct7=='0100000':
		file_inst.write("SUB    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		tc_rs2 = int('ffffffff',16) - unsigned_rs2 + 1
		result = unsigned_rs1 + tc_rs2
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='001' and funct7=='0000000':
		file_inst.write("SLL    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		sh_amount = int(bin_rs2[-5:],2)
		result = unsigned_rs1 << sh_amount
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='010' and funct7=='0000000':
		file_inst.write("SLT    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		if (signed_rs1<signed_rs2):
			rv32variables.reg[rd] = '00000001'
		else:
			rv32variables.reg[rd] = '00000000'
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='011' and funct7=='0000000':
		file_inst.write("SLTU   rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		if (rs1==0):
			if (unsigned_rs1 != unsigned_rs2):
				rv32variables.reg[rd] = '00000001'
			else:
				rv32variables.reg[rd] = '00000000'
		else:
			if (unsigned_rs1 < unsigned_rs2):
				rv32variables.reg[rd] = '00000001'
			else:
				rv32variables.reg[rd] = '00000000'
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='100' and funct7=='0000000':
		file_inst.write("XOR    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		result = unsigned_rs1 ^ unsigned_rs2
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='101' and funct7=='0000000':
		file_inst.write("SRL    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		sh_amount = int(bin_rs2[-5:],2)
		result = unsigned_rs1 >> sh_amount
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='101' and funct7=='0100000':
		file_inst.write("SRA    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		sh_amount = int(bin_rs2[-5:],2)
		sh_data = unsigned_rs1 >> sh_amount
		sh_data = bin(sh_data)[2:]
		if len(bin(unsigned_rs1))==34:
			sh_data = ('1'*sh_amount)+sh_data
		else:
			sh_data = ('0'*sh_amount)+sh_data
		result = int(sh_data,2)
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='110' and funct7=='0000000':
		file_inst.write("OR     rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		result = unsigned_rs1 | unsigned_rs2
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	elif opcode=='0110011' and funct3=='111' and funct7=='0000000':
		file_inst.write("AND    rd = %d, rs1 = %d, rs2 =%d\n" %(rd,rs1,rs2))
		result = unsigned_rs1 & unsigned_rs2
		result = hex(((1 << 32) - 1) & result)[2:]
		result = result.zfill(8)
		rv32variables.reg[rd] = result[-8:]
		rv32variables.rden = 1
	
###########   FENCE, FENCE.I    #########
	
	elif opcode=='0001111' and funct3=='000':
		file_inst.write("FENCE")
	elif opcode=='0001111' and funct3=='001':
		file_inst.write("FENCE.I")
	
###########   ECALL, EBREAK    #########
	
	elif opcode=='1110011' and funct3=='000' and imm_I=='000000000000':
		file_inst.write("ECAL\n")
	elif opcode=='1110011' and funct3=='000' and imm_I=='000000000001':
		file_inst.write("EBREAK\n")
	
###########   CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI     #########
	
	elif opcode=='1110011' and funct3=='001':
		file_inst.write("CSRRW  rd = %d, csr = %s, rs1 = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		csr_bin = bin(int(rv32variables.reg[rs1][-3:],16))[2:]
		csr_bin = csr_bin.zfill(12)
		rv32variables.csr[csr_add] = csr_bin[-12:]
	elif opcode=='1110011' and funct3=='010':
		file_inst.write("CSRRS  rd = %d, csr = %s, rs1 = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		if rs1!=0:
			csr_bin = bin(int(rv32variables.reg[rs1][-3:],16))[2:]
			csr_bin = csr_bin.zfill(12)
			csr_or = bin(int(csr_bin[-12:],2) | int(rv32variables.csr[csr_add],16))[2:]
			csr_or = csr_or.zfill(12)
			rv32variables.csr[csr_add] = csr_or
	elif opcode=='1110011' and funct3=='011':
		file_inst.write("CSRRC  rd = %d, csr = %s, rs1 = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		if rs1!=0:
			csr_rs1 = bin(int(rv32variables.reg[rs1][-3:],16))[2:]
			csr_rs1 = csr_rs1.zfill(12)
			csr_nrs1 = bin(int(csr_rs1,2) ^ int('fff',16))[2:]
			csr_nrs1 = csr_nrs1.zfill(12)
			csr_and = bin(int(csr_bin[-12:],2) & int(rv32variables.csr[csr_add],16))[2:]
			csr_and = csr_and.zfill(12)
			rv32variables.csr[csr_add] = csr_and
	elif opcode=='1110011' and funct3=='101':
		file_inst.write("CSRRWI rd = %d, csr = %s, zimm = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		csr_bin = bin_rs1
		csr_bin = csr_bin.zfill(12)
		rv32variables.csr[csr_add] = csr_bin[-12:]
	elif opcode=='1110011' and funct3=='110':
		file_inst.write("CSRRSI rd = %d, csr = %s, zimm = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		if rs1!=0:
			csr_bin = bin_rs1
			csr_bin = csr_bin.zfill(12)
			csr_or = bin(int(csr_bin[-12:],2) | int(rv32variables.csr[csr_add],16))[2:]
			csr_or = csr_or.zfill(12)
			rv32variables.csr[csr_add] = csr_or
	elif opcode=='1110011' and funct3=='111':
		file_inst.write("CSRRCI rd = %d, csr = %s, zimm = %d\n" %(rd,hex(int(imm_I,2)),rs1))
		if rd!=32:
			csr_hex = hex(int(rv32variables.csr[csr_add],16))[2:]
			csr_hex = csr_hex.zfill(8)
			rv32variables.reg[rd] = csr_hex
			rv32variables.rden = 1
		if rs1!=0:
			csr_rs1 = bin_rs1
			csr_rs1 = csr_rs1.zfill(12)
			csr_nrs1 = bin(int(csr_rs1,2) ^ int('fff',16))[2:]
			csr_nrs1 = csr_nrs1.zfill(12)
			csr_and = bin(int(csr_bin[-12:],2) & int(rv32variables.csr[csr_add],16))[2:]
			csr_and = csr_and.zfill(12)
			rv32variables.csr[csr_add] = csr_and

	# elif inst!='00000000\n':
		# file_inst.write("Instruction not found, Instruction =",inst)
	
	# file_inst.close()