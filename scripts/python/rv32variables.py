
global memory
global pc_offset
global pc
global npc
global reg
global reg_name
global wen
global radd
global wadd
global rdata
global wdata
global write_file_empty
global write_file_en
global valid_branch
global rden
global rdadd
global mac
global csr

reg_name = [  "000", " ra", " sp", " gp", " tp", " t0", " t1", " t2", " s0", " s1", " a0", " a1", " a2", " a3", " a4", 
" a5", " a6", " a7", " s2", " s3", " s4", " s5", " s6", " s7", " s8", " s9", "s10", "s11", " t3", " t4", " t5", " t6"] ;
	
file = open("./output/memory.hex","r")
memory = file.readlines()
file.close()

pc_offset 	= 0x00000200
npc  		= int(pc_offset)
write_file_empty = 1
write_file_en    = 0

# print "Start Address = ",str(hex(pc_offset))
reg = ['00000000']*33
for i in range(1,32):
	# reg[i] = hex(i)[2:].zfill(8)
	reg[i] = '00000000'
reg[2] = '0002f000'
csr   = ['00000000']*12
wen   = '000'
radd  = '00000000'
wadd  = '00000000'
rdata = '00000000'
wdata = '00000000'

valid_branch = 0
