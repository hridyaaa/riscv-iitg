module reg_write(
	input clk,
	input reset,
	
	input        rd_en1,
	input [6:0]  rd_add1,
	input [31:0] rd_data1,      
	
	input        rd_en2,
	input [6:0]  rd_add2,
	input [31:0] rd_data2,
	
	input        rd_en3,
	input [6:0]  rd_add3,
	input [31:0] rd_data3,
	
//******** output signals **********//
	output        wrd_en1,
	output [6:0]  wrd_add1,
	output [31:0] wrd_data1,
	
	output        wrd_en2,
	output [6:0]  wrd_add2,
	output [31:0] wrd_data2,
	
	output oc_pause
	);
	
	wire reg_wen = rd_en1 & rd_en2 & rd_en3;
	wire reg_clear = (rd_en1 & !rd_en2 & !rd_en3) | (!rd_en1 & rd_en2 & !rd_en3) | (!rd_en1 & !rd_en2 & rd_en3) | (!rd_en1 & !rd_en2 & !rd_en3) ;
	
	reg        reg_rd_en  ; 
	reg [6:0]  reg_rd_add ; 
	reg [31:0] reg_rd_data; 
	
	always@(posedge clk) begin
		if      ( reset     ) { reg_rd_en, reg_rd_add, reg_rd_data } <= { 1'd0, 7'd0, 32'd0 };
		else if ( reg_wen   ) { reg_rd_en, reg_rd_add, reg_rd_data } <= { rd_en3, rd_add3, rd_data3 };
		else if ( reg_clear ) { reg_rd_en, reg_rd_add, reg_rd_data } <= { 1'd0, 7'd0, 32'd0 };
		
	end
	
	wire wire_oc_pause = ( rd_en1 & rd_en2 & rd_en3 ) ;
	
	reg reg_oc_pause; always@(posedge clk) if(reset) reg_oc_pause <= 0; else reg_oc_pause <= wire_oc_pause;
	
//-------------------------------------------------------------------------------------//
//                                     outputs
//-------------------------------------------------------------------------------------//
	
	assign wrd_en1 = rd_en1 | rd_en2 | rd_en3 | reg_rd_en;
	assign {wrd_add1, wrd_data1} = (rd_en1   ) ? {rd_add1, rd_data1}
	:                              (rd_en2   ) ? {rd_add2, rd_data2}
	:                              (rd_en3   ) ? {rd_add3, rd_data3}
	:                              (reg_rd_en) ? {reg_rd_add, reg_rd_data}
	:                              39'd0;
	
	wire en1 = rd_en1 & rd_en2;
	wire en2 = (rd_en1 | rd_en2) & rd_en3;
	wire en3 = (rd_en1 | rd_en2 | rd_en3) & reg_rd_add;
	
	assign wrd_en2 = en1 | en2 | en3 ;
	assign {wrd_add2, wrd_data2} = (en1) ? {rd_add2, rd_data2}
	:                              (en2) ? {rd_add3, rd_data3}
	:                              (en3) ? {reg_rd_add, reg_rd_data}
	:                              39'd0;

	assign oc_pause = reg_oc_pause;
	
endmodule