module rv32m(
        input [31:0] instruction,
		
		output [7:0] control_md,
		output       rs1_sign,
		output       rs2_sign,
		output       mac_init,
		output       rd_en
    );
	
	wire [6:0] opcode = instruction[6:0];
    wire [2:0] fun3 = instruction[14:12];
    wire [6:0] fun7 = instruction[31:25];

////////    MUL,MULH,MULHSU,MULHU    ////////
	wire mul    = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b000);
    wire mulh   = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b001);
    wire mulhsu = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b010);
    wire mulhu  = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b011);
	
////////    DIV,DIVU    ////////
	wire div  = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b100);
    wire divu = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b101);
	
////////    REM,REMU    ////////
    wire rem  = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b110);
    wire remu = (opcode==7'b0110011 & fun7==7'b0000001 & fun3==3'b111);
	
//-------------------------------------------- Outputs
	wire mac_high = mulh|mulhsu|mulhu ;
	wire mac_low  = mul ;
	
	assign rs1_sign = mul|mulh|mulhsu|div|rem ;
	assign rs2_sign = mul|mulh|div|rem ;
	
	assign mac_init = mul|mulh|mulhsu|mulhu ;
	
	wire rd_en2 = div|divu ;
	wire rd_en3 = rem|remu ;
	
	assign rd_en = mac_init | rd_en2 |rd_en3 ;
	
	assign control_md = ( mac_low  ) ? 8'h1c 
	:                   ( mac_high ) ? 8'h1d 
	:                   ( rd_en2   ) ? 8'h1e 
	:                   ( rd_en3   ) ? 8'h1f 
	:                                  8'h00 ;
	
endmodule
