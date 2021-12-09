module three2one #(
	parameter  WIDTH = 40
)(
	input clk,
	input reset,
	input pause,
	
	input vdin1,
	input vdin2,
	input vdin3,
	
	input [WIDTH-1:0] din1,
	input [WIDTH-1:0] din2,
	input [WIDTH-1:0] din3,
	
	output [WIDTH-1:0] dout,
	output             vdout,
	output pnc
);
	
	wire [WIDTH-1:0] dout1  ;
	wire vdout1 ;
	wire pnc1   ;
	wire pnc2   ;
	
	reg pause2; always@(posedge clk) if (reset) pause2 <= 0; else pause2 <= pnc2;
	
	two2one #(
		.WIDTH ( WIDTH )
	)  inst1_two2one (
		.clk   ( clk    ),
		.reset ( reset  ),
		.pause ( pause2 | pause ),
		.vdin1 ( vdin1  ),
		.vdin2 ( vdin2  ),
		.din1  ( din1   ),
		.din2  ( din2   ),
		.dout  ( dout1  ),
		.vdout ( vdout1 ),
		.pnc   ( pnc1   )
	);
	
	two2one #(
		.WIDTH ( WIDTH )
	)  inst2_two2one (
		.clk   ( clk   ),
		.reset ( reset ),
		.pause ( pause ),
		.vdin1 ( vdout1 ),
		.vdin2 ( vdin3 ),
		.din1  ( dout1  ),
		.din2  ( din3  ),
		.dout  ( dout  ),
		.vdout ( vdout ),
		.pnc   ( pnc2   )
	);
	
	assign pnc = pnc1 | pnc2 ;
	
endmodule

