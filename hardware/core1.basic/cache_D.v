module cache_D #(
		parameter  ADD_WIDTH = 18,//address width is specified
	parameter      DEPTH = (2**ADD_WIDTH)/4// made address byte addressible//(32/8)=4//RISC V is byte addressible
	)(
	input clk,reset,
	
	input  [31:0] add,
	output [31:0] rdata,
	input  [ 3:0] wen,//write enable
	input  [31:0] wdata
);
	
	reg [31:0] mem [0:DEPTH-1];//made an array

	initial $readmemh("./memory.hex",mem);//readmemh used to initialize memory
	
//// ----------------------		Read Channel		-------------------- ////
	
	wire [ADD_WIDTH-3:0] mem_add   = add[ADD_WIDTH-1:2] ;//adrress of data to be read or write is stored in mem_add
	wire [31:0]          mem_rdata = mem[mem_add] ;//data to be read or write is kept in mem_data
	
	reg [31:0] reg_rdata;  
	always@(posedge clk) begin
	  if   (reset) reg_rdata <= 32'd0;
	  else         reg_rdata <= mem_rdata;//reading
	end

	assign rdata = reg_rdata;//made an array
	
// ----------------------		Write Channel		-------------------- ////
	
	wire [31:0] wdata1;
	assign wdata1[31:24] = (wen[3]) ? wdata[31:24] : mem_rdata[31:24];//when write enable=1,write given data else write the read data(read+write condition)
	assign wdata1[23:16] = (wen[2]) ? wdata[23:16] : mem_rdata[23:16];
	assign wdata1[15: 8] = (wen[1]) ? wdata[15: 8] : mem_rdata[15: 8];
	assign wdata1[ 7: 0] = (wen[0]) ? wdata[ 7: 0] : mem_rdata[ 7: 0];
	
	always@(posedge clk) if( !reset & wen!=3'b000 ) mem[mem_add] <= wdata1;//the data is written in to the addressalready given
	
endmodule
	
