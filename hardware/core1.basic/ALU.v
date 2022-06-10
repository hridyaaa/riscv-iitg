module ALU(
	input clk,
	input reset,
	input pause,
	
	input [31:0] din1,
	input [31:0] din2,
	input [7:0]  control,
	
	output [31:0] dout
);

	wire wire_add_en = ( control==8'h01 ) ; 
	wire wire_sub_en = ( control==8'h02 ) ; 
	wire wire_xor_en = ( control==8'h03 ) ; 
	wire wire_or_en  = ( control==8'h04 ) ; 
	wire wire_and_en = ( control==8'h05 ) ; //select lines for arithmatic operations

// Arithmetic
//---------------------------------------------------------
	
	wire [31:0] wire_add32 = din1 + din2 ;
	wire [31:0] wire_sub32 = din1 - din2 ;
	wire [31:0] wire_xor32 = din1 ^ din2 ;
	wire [31:0] wire_or32  = din1 | din2 ;
	wire [31:0] wire_and32 = din1 & din2 ;//arithmatic operations
	
// Comparator
//---------------------------------------------------------
	wire signed [31:0] sign_din1 = din1;
	wire signed [31:0] sign_din2 = din2;//for comparison purpose ,sign bit is important.therefore changed din and din2 to signed values.
	
	wire wire_equal   = ( din1 == din2 );
	wire wire_nequal  = ( din1 != din2 );
	wire wire_lesser  = ( sign_din1 <  sign_din2 );
	wire wire_gequal  = ( sign_din1 >= sign_din2 );
	wire wire_ulesser = ( din1 <  din2 );
	wire wire_ugequal = ( din1 >= din2 );//comparison operations
	
// Shift
//---------------------------------------------------------
	wire [ 4:0]  operand = din2[4:0];
    wire [31:0] wire_sll = din1 << operand;
	wire [31:0] wire_srl = din1 >> operand;//operand stores the values of no.of shifts.suppose the number of shifts were 4 then operand value will be 4,din1 shifted 4 times and the value will be stored in wire sr1
	wire [31:0] wire_sra = sign_din1 >>> operand;//shift and sign extend//original sign is copied in to vacated upper bits by this operation
	
	
	assign dout = ( wire_add_en    ) ? wire_add32 //if wire_add_en=1,do addition operation
	:	          ( wire_sub_en    ) ? wire_sub32 
	:	          ( wire_xor_en    ) ? wire_xor32 
	:	          ( wire_or_en     ) ? wire_or32  
	:	          ( wire_and_en    ) ? wire_and32 
	:	          ( control==8'h06 ) ? {31'd0, wire_equal  }
	:	          ( control==8'h07 ) ? {31'd0, wire_nequal }
	:	          ( control==8'h08 ) ? {31'd0, wire_lesser }
	:	          ( control==8'h09 ) ? {31'd0, wire_gequal }
	:	          ( control==8'h0a ) ? {31'd0, wire_ulesser}
	:	          ( control==8'h0b ) ? {31'd0, wire_ugequal}
	:	          ( control==8'h0c ) ? wire_sll
	:	          ( control==8'h0d ) ? wire_srl
	:	          ( control==8'h0e ) ? wire_sra
	:	            32'd0;
	
endmodule //control signals for comparison operations are given seperately
