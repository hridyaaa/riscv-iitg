module memory_controller(
	input clk,
	input reset,
	output inst_rready,
	
	// Channel 1
	input         ren1,
	input  [31:0] radd1,
	output [31:0] rdata1,
	output        vrdata1,
	
	input [6:0] rd_add2,
	input        umload,
	
	// Channel 2
	input [2:0]  ren2,
	input [31:0] radd2,
	input [2:0]  wen2,
	input [31:0] wadd2,
	input [31:0] wdata2,
	
	output        rd_en,
	output [6:0]  rd_add,
	output [31:0] rd_data,
	
	output  [31:0] mem_add1,
	input   [31:0] mem_rdata1,
	output   [3:0] mem_wen1,
	output  [31:0] mem_wdata1,
	output  [31:0] mem_add2,
	input   [31:0] mem_rdata2,
	output   [3:0] mem_wen2,
	output  [31:0] mem_wdata2,
	
	output mm_pause
);
	wire pause_req ;
	
	assign inst_rready = (reset) ? 1'b0 : 1'b1 ;
	
	assign mm_pause = 1'b0 ;
	
//-------------------------------------------------------------------------------------//
//                                     Channel 1
//-------------------------------------------------------------------------------------//
	
	reg reg_vrdata1; always@(posedge clk) if (reset) reg_vrdata1 <= 1'b0; else reg_vrdata1 <= ren1 ;
	
	assign rdata1  = mem_rdata1 ;
	assign vrdata1 = reg_vrdata1;
	
//-------------------------------------------------------------------------------------//
//                                     Channel 2
//-------------------------------------------------------------------------------------//
	
	wire [3:0] wire_vrdata2 = (ren2[2]==1'b1) ? 4'b1111 
	:                         (ren2[1]==1'b1 & radd2[1]==1'b0) ? 4'b0011 
	:                         (ren2[1]==1'b1 & radd2[1]==1'b1) ? 4'b1100 
	:                         (ren2[0]==1'b1 & radd2[1:0]==2'b00) ? 4'b0001 
	:                         (ren2[0]==1'b1 & radd2[1:0]==2'b01) ? 4'b0010 
	:                         (ren2[0]==1'b1 & radd2[1:0]==2'b10) ? 4'b0100 
	:                         (ren2[0]==1'b1 & radd2[1:0]==2'b11) ? 4'b1000 
	:                         4'b0000;
	
	reg        reg_ren2   ; always@(posedge clk) if (reset) reg_ren2    <= 0; else reg_ren2    <= ( ren2!=0 ) ;
	reg        reg_umload ; always@(posedge clk) if (reset) reg_umload  <= 0; else reg_umload  <= umload      ;
	reg [ 6:0] reg_rd_add2; always@(posedge clk) if (reset) reg_rd_add2 <= 0; else reg_rd_add2 <= rd_add2     ;
	reg [ 3:0] reg_vrdata2; always@(posedge clk) if (reset) reg_vrdata2 <= 0; else reg_vrdata2 <= wire_vrdata2;
    
	wire [31:0] wire_mem_rdata = mem_rdata2 ;
	
	assign rd_en   = reg_ren2;
    assign rd_add  = reg_rd_add2;
    assign rd_data = ( reg_vrdata2 == 4'b1111              ) ? wire_mem_rdata
	:                ( reg_vrdata2 == 4'b0011 & reg_umload ) ? { 16'd0,                   wire_mem_rdata[15:0]  } 
	:                ( reg_vrdata2 == 4'b0011              ) ? {{16{wire_mem_rdata[15]}}, wire_mem_rdata[15:0]  } 
	:                ( reg_vrdata2 == 4'b1100 & reg_umload ) ? { 16'd0,                   wire_mem_rdata[31:16] } 
	:                ( reg_vrdata2 == 4'b1100              ) ? {{16{wire_mem_rdata[31]}}, wire_mem_rdata[31:16] } 
	:                ( reg_vrdata2 == 4'b0001 & reg_umload ) ? { 24'd0,                   wire_mem_rdata[7:0]   } 
	:                ( reg_vrdata2 == 4'b0001              ) ? {{24{wire_mem_rdata[7]}},  wire_mem_rdata[7:0]   } 
	:                ( reg_vrdata2 == 4'b0010 & reg_umload ) ? { 24'd0,                   wire_mem_rdata[15:8]  } 
	:                ( reg_vrdata2 == 4'b0010              ) ? {{24{wire_mem_rdata[15]}}, wire_mem_rdata[15:8]  } 
	:                ( reg_vrdata2 == 4'b0100 & reg_umload ) ? { 24'd0,                   wire_mem_rdata[23:16] } 
	:                ( reg_vrdata2 == 4'b0100              ) ? {{24{wire_mem_rdata[23]}}, wire_mem_rdata[23:16] } 
	:                ( reg_vrdata2 == 4'b1000 & reg_umload ) ? { 24'd0,                   wire_mem_rdata[31:24] } 
	:                ( reg_vrdata2 == 4'b1000              ) ? {{24{wire_mem_rdata[31]}}, wire_mem_rdata[31:24] } 
	:                32'd0 ;
	
	wire [3:0 ]wire_wen2 = ( wen2[2] ) ? 4'b1111 
	:                      ( wen2[1] & wadd2[1]==0 ) ? 4'b0011 
	:                      ( wen2[1] & wadd2[1]==1 ) ? 4'b1100 
	:                      ( wen2[0] & wadd2[1:0]==2'b00 ) ? 4'b0001 
	:                      ( wen2[0] & wadd2[1:0]==2'b01 ) ? 4'b0010 
	:                      ( wen2[0] & wadd2[1:0]==2'b10 ) ? 4'b0100 
	:                      ( wen2[0] & wadd2[1:0]==2'b11 ) ? 4'b1000 
	:                        4'b0000 ;
	
//-------------------------------------------------------------------------------------//
//                                     Memory outputs
//-------------------------------------------------------------------------------------//
	assign 	 mem_add1   = radd1 ;
	assign   mem_wen1   = 0 ;
	assign   mem_wdata1 = 0 ;
	
	assign 	 mem_add2   = ( wen2!=0 ) ? wadd2 : radd2 ;
	assign 	 mem_wen2   = wire_wen2 ;
	assign   mem_wdata2 = wdata2 ;
	
	
endmodule
