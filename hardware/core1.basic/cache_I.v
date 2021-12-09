module cache_I #(
		parameter  ADD_WIDTH = 17,
		parameter      DEPTH = (2**ADD_WIDTH)/4
	)(
	input clk,reset,
	
	input  [31:0] add,
	output [31:0] rdata,
	input  [ 3:0] wen,
	input  [31:0] wdata
);

	reg [31:0] mem [0:DEPTH-1];
	
	initial $readmemh("/home/satya/phd_work/output/memory.hex",mem);
	
//// ----------------------		Read Channel		-------------------- ////
	
	wire [ADD_WIDTH-3:0] mem_add   = add[ADD_WIDTH-1:2] ;
	wire [31:0]          mem_rdata = mem[mem_add] ;
	
	reg [31:0] reg_rdata;  
	always@(posedge clk) begin
	  if   (reset) reg_rdata <= 32'd0;
	  else         reg_rdata <= mem_rdata;
	end

	assign rdata = reg_rdata;
	
// ----------------------		Write Channel		-------------------- ////
	
	wire [31:0] wdata1;
	assign wdata1[31:24] = (wen[3]) ? wdata[31:24] : mem_rdata[31:24];
	assign wdata1[23:16] = (wen[2]) ? wdata[23:16] : mem_rdata[23:16];
	assign wdata1[15: 8] = (wen[1]) ? wdata[15: 8] : mem_rdata[15: 8];
	assign wdata1[ 7: 0] = (wen[0]) ? wdata[ 7: 0] : mem_rdata[ 7: 0];
	
	always@(posedge clk) if( !reset & wen!=3'b000 ) mem[mem_add] <= wdata1;
	
endmodule
	