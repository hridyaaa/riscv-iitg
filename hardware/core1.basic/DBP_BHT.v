module DBP_BHT #(
	parameter AWIDTH  = 10,
	parameter DWIDTH = 32
)(
	input clk,
	input reset,

	input  [AWIDTH-1:0] add1,//output of dbp
	output [DWIDTH-1:0] rdata1,//input of dbp
	
	input  [AWIDTH-1:0] add2,//output of dbp is input to bht
	output [DWIDTH-1:0] rdata2,//input to dbp,output of bht
	input               wen2,//write enable is a signal frpom dbp,for bht updation
	input  [DWIDTH-1:0] wdata2//final address by branch prediction was stored in wdata2,which should be updated in bht
);

	localparam DEPTH = 2**AWIDTH ; 
	
	reg [DWIDTH-1:0] ram_memory [DEPTH-1:0];
	
	initial $readmemh("./bht_init.hex",ram_memory);//for software verification
	
	// localparam DWIDTH1 = DWIDTH -1 ;
	// genvar i;
	// generate // optional if > *-2001
	// for (i=0; i<DEPTH ; i=i+1) begin 
		// initial ram_memory[i] <= {DWIDTH{1'b0}} ;
		// // initial ram_memory[i] <= {{DWIDTH1{1'b0}}, 1'b1} ;
	// end
	// endgenerate
	
//// ----------------------		Channel	1	-------------------- ////
	reg [DWIDTH-1:0] reg_rdata1 ;
	
	always@(posedge clk) begin
	  if   (reset) reg_rdata1 <= 32'd0 ;
	  else         reg_rdata1 <= ram_memory[add1] ;//content of add1 in ram memory is copied to reg data1
	end
	
	assign rdata1 = reg_rdata1 ;//address is copied to r data which is te op of bht
	
	// always@(posedge clk) if ( !reset & wen1 ) ram_memory[add1] <= wdata1 ;
	
//// ----------------------		Channel	2	-------------------- ////
	reg [DWIDTH-1:0] reg_rdata2 ;
	
	always@(posedge clk) begin
	  if   (reset) reg_rdata2 <= 32'd0 ;
	  else         reg_rdata2 <= ram_memory[add2] ;
	end
	
	assign rdata2 = reg_rdata2;
	
	always@(posedge clk) if ( !reset & wen2 ) ram_memory[add2] <= wdata2 ;//new data came,write it in to memory
	
endmodule
	
