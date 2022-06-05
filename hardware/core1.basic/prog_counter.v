module prog_counter(
		input clk,
		input reset,
		input pause,
		
		input        pc_update1   ,
		input        pc_update2   ,
		input        pc_update3   ,
		input        pc_update4   ,
		input [31:0] pc_update_add,
		
		input         inst_rready,
		output        req        ,
		output [31:0] inst_add   ,
		input         vinst      ,
		input [31:0]  inst       ,
		
		output pc_pinst,
		output [31:0] pc,
		output [31:0] inst_out,
		output vinst_out
    );
	
	wire pc_update = pc_update1 | pc_update2 | pc_update3 | pc_update4 ;//signal representing any of the pc update
	
	reg reg_pinst;
	reg [31:0] reg_pc;  // current instruction address
	
	wire [31:0] wire_pc = pc_update ? pc_update_add
	:                                  reg_pc + 32'd4 ;//either pc goes to next instruction,or will be updated to a new physical address
	
	always@(posedge clk) if (reset) reg_pc <= 32'h000001fc ; else if (req) reg_pc <= wire_pc ;//on reseting pc initialised to 01fc//address stored in pc
	
	always@(posedge clk) if (reset) reg_pinst <=  1'b0 ; else if (req) reg_pinst <= pc_update1 ;//instruction is stored in pc inst
	
//-------------------------------------------------------------- Output signals
	
	assign req = (reset      ) ? 1'b0 
	:            (pc_update  ) ? 1'b1 
	:            (pause      ) ? 1'b0 
	:            (inst_rready) ? 1'b1 
	:            1'b0;
	
	assign inst_add = wire_pc;
//-------------------------------------------------------------- Buffer stage
	wire buffer_en = pause & vinst;
	
	reg buffer_full; 
	always@(posedge clk) begin
		if      ( reset     ) buffer_full<=1'b0; 
		else if ( pc_update ) buffer_full<=1'b0; 
		else if ( buffer_en ) buffer_full<=1'b1; 
		else if ( !pause    ) buffer_full<=1'b0;// store address in buffer
	end
	
	reg [31:0] buffer_inst; 
	always@(posedge clk) begin
		if      ( reset     ) buffer_inst<=32'd0; 
		else if ( buffer_en ) buffer_inst<=inst; 
		else if ( !pause    ) buffer_inst<=32'd0;//store corresponding instruction in buffer
	end
	
//-------------------------------------------------------------- Output signals
	
	assign pc_pinst = pc_update1  ;
	assign pc       = reg_pc ;
	assign inst_out = buffer_full ? buffer_inst : inst ;
	
	assign vinst_out = pause       ? 1'b0 
	:                  buffer_full ? 1'b1
	:                                vinst ;
	
endmodule

