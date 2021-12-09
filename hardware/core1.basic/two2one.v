module two2one #(
	parameter  WIDTH = 40
)(
	input clk,
	input reset,
	input pause,
	
	input vdin1,
	input vdin2,
	
	input [WIDTH-1:0] din1,
	input [WIDTH-1:0] din2,
	
	output [WIDTH-1:0] dout,
	output             vdout,
	output pnc
);
	
	wire reg_write_en = vdin1 & vdin2 & !pause ;
	
	reg [WIDTH:0] reg_din2; always@(posedge clk) if (reset) reg_din2 <= {1'b0,{WIDTH{1'b0}}}; else if (reg_write_en) reg_din2 <= {vdin2,din2}; else if (!pause) reg_din2 <= {1'b0,{WIDTH{1'b0}}} ;
	
	wire din2_vreg = reg_din2[WIDTH];
	
	assign {vdout,dout} = (pause     ) ? {1'b0,{WIDTH{1'b0}}}
	:                     (vdin1     ) ? {vdin1,din1}
	:                     (vdin2     ) ? {vdin2,din2}
	:                     (din2_vreg ) ? reg_din2
	:                                    {1'b0,{WIDTH{1'b0}}} ;
	
	assign pnc = reg_write_en | (din2_vreg & pause) ;
	
endmodule

