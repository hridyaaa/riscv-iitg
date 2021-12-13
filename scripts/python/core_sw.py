#!/bin/bash python

import rv32variables
import rv32i
import rv32m

no_of_inst = 0
temp = 1
rv32variables.pc = int(rv32variables.pc_offset)
pc_old = -1
# print "Start Address = ",str(hex(rv32variables.pc_offset))

if (rv32variables.write_file_empty == 1 and rv32variables.npc == int(rv32variables.pc_offset)):
	rv32variables.write_file_en = 1
	
# while (rv32variables.write_file_en == 1 ):

file_inst  = open("output/instructions_sw.txt","w")
file_uart  = open("output/uart_sw.txt","w")
file_regsw = open("output/reg_status_sw.txt","w")

file_regsw.write("pc       (rd rd  wdata   ) (wen wadd     wdata    | radd    )\n") 
# file_regstat = open("output/software_reg_status.txt","w+")

while (rv32variables.write_file_en == 1 and temp < 100000000 ):
	
	temp = temp + 1
	
	temp_hex = hex(temp)[2:]
	temp_hex = temp_hex.zfill(16)
	temp_hex = temp_hex[-16:]
	rv32variables.csr[4] = temp_hex[-8:]
	rv32variables.csr[6] = temp_hex[-8:]
	rv32variables.csr[7] = temp_hex[0:8]
	rv32variables.csr[9] = temp_hex[0:8]
	
	rv32variables.valid_branch = 1
	rv32variables.write_file_empty = 0
	
	rv32variables.wen   = '000'
	rv32variables.radd  = '00000000'
	rv32variables.wadd  = '00000000'
	rv32variables.rdata = '00000000'
	rv32variables.wdata = '00000000'
	
	rv32variables.rden = 0
	rv32variables.rdadd = 0
	
	rv32variables.pc = int( ((hex(rv32variables.npc)[2:]).zfill(8))[-8:], 16)
	rv32variables.npc = rv32variables.pc + 4
	# print "PC ",rv32variables.pc
	
	# print "instruction line no =",(rv32variables.pc/4)
	x = rv32variables.memory[rv32variables.pc/4]
	
	pc_hex = (hex(rv32variables.pc)[2:]).zfill(8)
	
	# file_inst = open("output/sw_instructions.txt","a")
	file_inst.write("%s : %s  " %((hex(rv32variables.pc)[2:]).zfill(8), x[0:8]))
	# file_inst.close()
	
	rv32i.rv32i(x, file_inst)
	rv32m.rv32m(x, file_inst)
	
	# if (rv32variables.valid_branch == 1 or int(rv32variables.wen,2)!=0 ):
		# file_regstat.write("Wen  : %s \n" %rv32variables.wen   )
		# file_regstat.write("Wadd : %s \n" %rv32variables.wadd  )
		# file_regstat.write("Wdata: %s \n" %rv32variables.wdata )
		# file_regstat.write("PC   : %s \n" %pc_hex      )
		# file_regstat.write("zero : 00000000  ra   : %s  sp   : %s  gp   : %s \n" %( rv32variables.reg[1], rv32variables.reg[2], rv32variables.reg[3] ))
		# file_regstat.write("tp   : %s  t0   : %s  t1   : %s  t2   : %s \n" %(rv32variables.reg[4], rv32variables.reg[5], rv32variables.reg[6], rv32variables.reg[7] ) )
		# file_regstat.write("s0   : %s  s1   : %s  a0   : %s  a1   : %s \n" %(rv32variables.reg[8], rv32variables.reg[9], rv32variables.reg[10],rv32variables.reg[11]) )
		# file_regstat.write("a2   : %s  a3   : %s  a4   : %s  a5   : %s \n" %(rv32variables.reg[12],rv32variables.reg[13],rv32variables.reg[14],rv32variables.reg[15]) )
		# file_regstat.write("a6   : %s  a7   : %s  s2   : %s  s3   : %s \n" %(rv32variables.reg[16],rv32variables.reg[17],rv32variables.reg[18],rv32variables.reg[19]) )
		# file_regstat.write("s4   : %s  s5   : %s  s6   : %s  s7   : %s \n" %(rv32variables.reg[20],rv32variables.reg[21],rv32variables.reg[22],rv32variables.reg[23]) )
		# file_regstat.write("s8   : %s  s9   : %s  s10  : %s  s11  : %s \n" %(rv32variables.reg[24],rv32variables.reg[25],rv32variables.reg[26],rv32variables.reg[27]) )
		# file_regstat.write("t3   : %s  t4   : %s  t5   : %s  t6   : %s \n" %(rv32variables.reg[28],rv32variables.reg[29],rv32variables.reg[30],rv32variables.reg[31]) )
		# file_regstat.write("\n")
		
		# print rv32variables.write_file_empty
		# print rv32variables.write_file_en
		# no_of_inst = no_of_inst + 1
	
	if ( (rv32variables.rden == 1 and rv32variables.rdadd!=0) | int(rv32variables.wen,2)!=0 ):
		if ( int(rv32variables.wen,2)!=0 ) :
			rv32variables.rdadd = 0
	
		v1 = pc_hex
		v2 = rv32variables.rdadd
		v3 = rv32variables.reg_name[rv32variables.rdadd]
		v4 = rv32variables.reg[rv32variables.rdadd]
		v5 = rv32variables.wen
		v6 = rv32variables.wadd
		v7 = rv32variables.wdata
		v8 = rv32variables.radd
	
		file_regsw.write("%s (%02d %s %s) (%s %s %s | %s)\n" %(v1,v2,v3,v4,v5,v6,v7,v8) )
	
	if ( int(rv32variables.wen,2)!=0 and int(rv32variables.wadd,16)==0x000001f0 ):
		v1 = int(rv32variables.wdata,16)
		file_uart.write("%s" %(chr(v1)) )
	
	# if (rv32variables.write_file_empty == 0 and rv32variables.npc <= int(rv32variables.pc_offset)):
		# rv32variables.write_file_en = 0
	
	# print rv32variables.write_file_en, " : ", rv32variables.pc_offset
	
	# print "radd :",rv32variables.radd  ,"rdata:",rv32variables.rdata ,"wadd :",rv32variables.wadd  ,"wdata:",rv32variables.wdata
	# print "\n"
	
print rv32variables.write_file_en , " : " , temp 
print "No of instructions :  ", no_of_inst

file_inst.close()
file_uart.close()
file_regsw.close()

file = open("./output/memory.sw.hex","w")
file.writelines(rv32variables.memory)
file.close()
# print "End of Program"
	