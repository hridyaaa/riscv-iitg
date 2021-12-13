module main(
    input clk, reset,
	
	output c,b,
	
	output uart_tx
	
	// input  [31:0] add2,
	// output [31:0] rdata2,
	// input  [ 3:0] wen2,
	// input  [31:0] wdata2
);
	assign b = reset;
	
	reg [31:0] temp; 
	always@(posedge clk) if (reset) temp <= 0; else temp <= temp+1 ;
	
	assign c = temp[27] ;
	
	localparam AWIDTH_DBP = 10 ;          // Size of history table
	localparam DWIDTH_DBP = 32+2 ;
	
	wire [AWIDTH_DBP-1:0] dbp_add1   ;
	wire [DWIDTH_DBP-1:0] dbp_rdata1 ;
	wire [AWIDTH_DBP-1:0] dbp_add2   ;
	wire [DWIDTH_DBP-1:0] dbp_rdata2 ;
	wire                  dbp_wen2   ;
	wire [DWIDTH_DBP-1:0] dbp_wdata2 ;
	
	DBP_BHT #(
	   .AWIDTH ( AWIDTH_DBP ),
	   .DWIDTH ( DWIDTH_DBP )
	)  BHT (
	   .clk    ( clk        ),
	   .reset  ( reset      ),
	   .add1   ( dbp_add1   ),
	   .rdata1 ( dbp_rdata1 ),
	   .add2   ( dbp_add2   ),
	   .rdata2 ( dbp_rdata2 ),
	   .wen2   ( dbp_wen2   ),
	   .wdata2 ( dbp_wdata2 )
	);
	
	wire [31:0] add1   ;
	wire [31:0] rdata1 ;
	wire [ 3:0] wen1   ;
	wire [31:0] wdata1 ;
	
	wire [31:0] add2   ;
	wire [31:0] rdata2 ;
	wire [ 3:0] wen2   ;
	wire [31:0] wdata2 ;
	
	
	cpu #(
	   .AWIDTH_DBP ( AWIDTH_DBP ),
	   .DWIDTH_DBP ( DWIDTH_DBP )
	) cpu_inst (
		.clk   ( clk  ),
		.reset ( reset),
		// Channel 1
		.add1   ( add1   ),
		.rdata1 ( rdata1 ),
		.wen1   ( wen1   ),
		.wdata1 ( wdata1 ),
		// Channel 2
		.add2   ( add2   ),
		.rdata2 ( rdata2 ),
		.wen2   ( wen2   ),
		.wdata2 ( wdata2 ),
		
		.dbp_add1   ( dbp_add1   ),
		.dbp_rdata1 ( dbp_rdata1 ),
		.dbp_add2   ( dbp_add2   ),
		.dbp_rdata2 ( dbp_rdata2 ),
		.dbp_wen2   ( dbp_wen2   ),
		.dbp_wdata2 ( dbp_wdata2 )
	);
	
	wire [3:0] wen_D   ; assign wen_D    = (add2 == 32'h000001f0) ? 0    : wen2 ;
	wire [3:0] wen_peph; assign wen_peph = (add2 == 32'h000001f0) ? wen2 : 0    ;
	
	/////////////////////////////////////////////////////////////
	//               For FPGA Verification
	//               128KB I-Cache and 64KB D-Cache 
	/////////////////////////////////////////////////////////////
	
	cache_I #( .ADD_WIDTH(18) ) 
	cache_instruction (
		.clk   ( clk    ),
		.reset ( reset  ),
		.add   ( add1   ),
		.rdata ( rdata1 ),
		.wen   ( wen1   ),
		.wdata ( wdata1 )
	);
	
	cache_D #( .ADD_WIDTH(18) ) 
	cache_data (
		.clk   ( clk    ),
		.reset ( reset  ),
		.add   ( add2   ),
		.rdata ( rdata2 ),
		.wen   ( wen_D  ),
		.wdata ( wdata2 )
	);
	
	uart uart_inst(
		.clk_100MHz(clk), .reset(reset),
		.din(wdata2[7:0]),
		.vdin(wen_peph[3] | wen_peph[2] | wen_peph[1] | wen_peph[0]),
		.dout(uart_tx)
	);
	
	
	//////////////////////////////////////////////////////////////
	//               For ASIC Synthesis
	//               4KB I-Cache and 2KB D-Cache 
	//////////////////////////////////////////////////////////////
	
	
	// cache_I #( .ADD_WIDTH(12) ) 
	// cache_instruction (
		// .clk   ( clk   ),
		// .reset ( reset ),
		// .add   ( add   ),
		// .rdata ( rdata )
	// );
	
	// cache_D #( .ADD_WIDTH(11) ) 
	// cache_data (
		// .clk   ( clk    ),
		// .reset ( reset  ),
		// .add   ( add    ),
		// .rdata ( rdata  ),
		// .we    ( we_D   ),
		// .wdata ( wdata2 )
	// );
	
endmodule
