module rv32i(
        input [31:0] instruction,
        input [31:0] pc,
		
		output rd_en_i,
		output rd_en_l,
		// memory signals
		output [2:0] mem_wen,
		output [2:0] mem_ren,
		// branch signals
		output jal,
		output [31:0] jal_add,
		output lui,
		output jalr,
		output branch,
		output umload,
		// data signals
		output [31:0] var1,
		output [31:0] var2,
		// variable
		output var2rs1,
		output var2rs2,
		
		output [3:0] control_csr,
		output [7:0] control_alu
    );
	
	wire [6:0] opcode = instruction[6:0];
    wire [2:0] fun3 = instruction[14:12];
    wire [6:0] fun7 = instruction[31:25];

//-------------------------------------------------------------------------------------------------------//
//                                            Immediates
//-------------------------------------------------------------------------------------------------------//
	// Immediate signals
    wire [11:0] imm_I = instruction[31:20];
    wire [11:0] imm_S = {instruction[31:25],instruction[11:7]};
    wire [11:0] imm_B = {instruction[31],instruction[7],instruction[30:25],instruction[11:8]};
	wire [19:0] imm_U = {instruction[31:12]};
	wire [19:0] imm_J = {instruction[31],instruction[19:12],instruction[20],instruction[30:21]};
	
////////    LUI, AUIPC, JAL, JALR    ////////
	wire   auipc = (opcode==7'b0010111);
    assign lui   = (opcode==7'b0110111);
    assign jal   = (opcode==7'b1101111);
    assign jalr  = (opcode==7'b1100111 & fun3==3'b000);
	
////////    BEQ, BNE, BLT, BGE, BLTU, BGEU    ////////
    wire beq  = (opcode==7'b1100011 & fun3==3'b000);
    wire bne  = (opcode==7'b1100011 & fun3==3'b001);
    wire blt  = (opcode==7'b1100011 & fun3==3'b100);
    wire bge  = (opcode==7'b1100011 & fun3==3'b101);
    wire bltu = (opcode==7'b1100011 & fun3==3'b110);
    wire bgeu = (opcode==7'b1100011 & fun3==3'b111);
	
////////    LB, LH, LW, LBU, LHU    ////////
    wire lb  = (opcode==7'b0000011 & fun3==3'b000);
    wire lh  = (opcode==7'b0000011 & fun3==3'b001);
    wire lw  = (opcode==7'b0000011 & fun3==3'b010);
    wire lbu = (opcode==7'b0000011 & fun3==3'b100);
    wire lhu = (opcode==7'b0000011 & fun3==3'b101);
	
////////    SB, SH, SW    ////////
    wire sb = (opcode==7'b0100011 & fun3==3'b000);
    wire sh = (opcode==7'b0100011 & fun3==3'b001);
    wire sw = (opcode==7'b0100011 & fun3==3'b010);
	
////////    ADDI, SLTI, SLTIU, XORI, ORI, ANDI    ////////
    wire addi  = (opcode==7'b0010011 & fun3==3'b000);
    wire slti  = (opcode==7'b0010011 & fun3==3'b010);
    wire sltiu = (opcode==7'b0010011 & fun3==3'b011);
    wire xori  = (opcode==7'b0010011 & fun3==3'b100);
    wire ori   = (opcode==7'b0010011 & fun3==3'b110);
    wire andi  = (opcode==7'b0010011 & fun3==3'b111);
	
////////    SLLI, SRLI, SRAI    ////////
    wire slli = (opcode==7'b0010011 & fun3==3'b001 & fun7==7'b0000000);
    wire srli = (opcode==7'b0010011 & fun3==3'b101 & fun7==7'b0000000);
    wire srai = (opcode==7'b0010011 & fun3==3'b101 & fun7==7'b0100000);
	
////////    ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND    ////////
    wire add  = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b000);
    wire sub  = (opcode==7'b0110011 & fun7==7'b0100000 & fun3==3'b000);
    wire sll  = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b001);
    wire slt  = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b010);
    wire sltu = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b011);
    wire xor2 = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b100);
    wire srl  = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b101);
    wire sra  = (opcode==7'b0110011 & fun7==7'b0100000 & fun3==3'b101);
    wire or2  = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b110);
    wire and2 = (opcode==7'b0110011 & fun7==7'b0000000 & fun3==3'b111);
	
////////    FENCE, FENCE.I    ////////
    wire fence  = (opcode==7'b0001111 & fun3==3'b000 & fun7==7'b0000000);
    wire fencei = (instruction==32'h000100f);
	
////////    ECALL, EBREAK    ////////
    wire ecall  = (instruction==32'h0000073);
    wire ebreak = (instruction==32'h0010073);
	
////////    CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI    ////////
    wire csrrw  = (opcode==7'b1110011 & fun3==3'b001);
    wire csrrs  = (opcode==7'b1110011 & fun3==3'b010);
    wire csrrc  = (opcode==7'b1110011 & fun3==3'b011);
    wire csrrwi = (opcode==7'b1110011 & fun3==3'b101);
    wire csrrsi = (opcode==7'b1110011 & fun3==3'b110);
    wire csrrci = (opcode==7'b1110011 & fun3==3'b111);
	
//****************************    Input Control Signals    *******************************//
	// temporary signals
	wire load  = lb | lbu | lh | lhu | lw;
	wire store = sw | sh | sb;
	// control signals
	assign branch = beq | bne | blt | bge | bltu | bgeu;
	assign umload = lhu | lbu;
	// memory signals
	assign mem_wen  = { sw, sh, sb };
	assign mem_ren  = { lw, ( lh | lhu ), ( lb | lbu ) };
	// alu signals
	wire alu_in2_I  = addi | xori | ori | andi | load | jalr;
	wire alu_in2_S  = store;
	// wire alu_in2_S  = store;
	wire alu_in2_B  = 0;
	wire alu_in2_J  = 0;
	wire alu_in2_U  = auipc;
	wire alu_add    = add | addi | auipc | jalr | store | load ;
	wire alu_sub    = sub;
	wire alu_xor    = xor2 | xori;
	wire alu_or     = or2  | ori;
	wire alu_and    = and2 | andi;
	// shift signals
	wire shift_operand_I = slli | srli | srai ;
	wire shift_left      = sll | slli ;
	wire shift_right     = srl | srli ;
	wire shift_aright    = sra | srai ;
	// comparator signals
	wire comp_in2_I   = (slti | sltiu);
	wire comp_equal   = beq;
	wire comp_nequal  = bne;
	wire comp_gequal  = bge;
	wire comp_lesser  = blt | slt | slti ;
	wire comp_ugequal = bgeu;
	wire comp_ulesser = bltu | sltu | sltiu ;
	// CSR signals
	wire csr_i  = csrrwi | csrrsi | csrrci ;
	wire csr_rw = csrrw  | csrrwi ;
	wire csr_rs = csrrs  | csrrsi ;
	wire csr_rc = csrrc  | csrrci ;
	
	//------------------------------------------------------- Adder
	
	// wire [31:0] adder_var = ( jal    ) ? { {11{imm_J[19]}}, imm_J, 1'b0 } 
	// :                       ( branch ) ? { {19{imm_B[11]}}, imm_B, 1'b0 } 
	// :                                    32'd0 ; 
	
	// wire [31:0] adder_dout = pc + adder_var;
	
	
	wire [31:0] adder_branch = pc + { {19{imm_B[11]}}, imm_B, 1'b0 } ;
	
	// wire [31:0] adder_dout = ( jal    ) ? adder_var1
	// :                        ( branch ) ? adder_var2
	// :                                     32'd0 ;
	
	//------------------------------------------------------- Outputs
	
	assign var1 = auipc ? pc
	:                     32'd0 ;
	
	
	wire var2_I = alu_in2_I | shift_operand_I | comp_in2_I ;
	wire var2_S = alu_in2_S ;
	wire var2_B = alu_in2_B ;
	wire var2_J = alu_in2_J ;
	wire var2_U = alu_in2_U | lui ;
	assign var2 = var2_I ? { {20{imm_I[11]}}, imm_I } 
	:             var2_S ? { {20{imm_S[11]}}, imm_S } 
	:             var2_B ? { {19{imm_B[11]}}, imm_B, 1'b0 } 
	:             var2_J ? { {11{imm_J[19]}}, imm_J, 1'b0 } 
	:             var2_U ? { imm_U, 12'h000 } 	
	:             jal    ? jal_add
	:             branch ? adder_branch
	: 			           32'd0;
	
	assign control_csr   = {csr_i,csr_rw,csr_rs,csr_rc};
//---------------------------------------------------------------- outputs
	
	assign jal_add = pc + { {11{imm_J[19]}}, imm_J, 1'b0 } ;
	
	assign rd_en_i = lui|auipc|jal|jalr|add|addi|sub|alu_xor|alu_or|alu_and|shift_left|shift_right|shift_aright|slt|sltu|slti|sltiu|csr_rs|csr_rw|csr_rc;
	assign rd_en_l = load;
	
	assign var2rs1 = auipc | jal ;
	assign var2rs2 = alu_in2_I | alu_in2_B | alu_in2_J | alu_in2_U | shift_operand_I | comp_in2_I ;
	
	assign control_alu = ( alu_add      ) ? 8'h01
	:	                 ( alu_sub      ) ? 8'h02
	:	                 ( alu_xor      ) ? 8'h03
	:	                 ( alu_or       ) ? 8'h04
	:	                 ( alu_and      ) ? 8'h05
	:	                 ( comp_equal   ) ? 8'h06
	:	                 ( comp_nequal  ) ? 8'h07
	:	                 ( comp_lesser  ) ? 8'h08
	:	                 ( comp_gequal  ) ? 8'h09
	:	                 ( comp_ulesser ) ? 8'h0a
	:	                 ( comp_ugequal ) ? 8'h0b
	:	                 ( shift_left   ) ? 8'h0c
	:	                 ( shift_right  ) ? 8'h0d
	:	                 ( shift_aright ) ? 8'h0e
	:	                 ( lui          ) ? 8'h0f
	:	                 ( jal          ) ? 8'h10
	:	                 ( csr_i        ) ? 8'h12
	:	                 ( csr_rw       ) ? 8'h13
	:	                 ( csr_rs       ) ? 8'h14
	:	                 ( csr_rc       ) ? 8'h15
	:	                                     0 ;
	
	
endmodule

