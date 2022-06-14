module buffer#(
	parameter WIDTH1 = 32+32+32+32+2+5+4,
	parameter WIDTH2 = 1+8+13
)(
	input clk,
	input reset,
	input pause,
//---------------------------------------------- Inputs
	input [WIDTH1-1:0] din1,
	input [WIDTH2-1:0] din2,
//---------------------------------------------- Outputs
	output [WIDTH1-1:0] dout1,
	output [WIDTH2-1:0] dout2
);

	reg [WIDTH1-1:0] reg_din1 ; always@(posedge clk) if (reset) reg_din1 <= {WIDTH1{1'b0}} ; else if (!pause) reg_din1 <= din1 ;
	reg [WIDTH2-1:0] reg_din2 ; always@(posedge clk) if (reset) reg_din2 <= {WIDTH2{1'b0}} ; else if (!pause) reg_din2 <= din2 ;//if not in pause condition ,thenthe inputs to alu,din1 and din2 temp stored in reg_din1 and reg_din2 respectively
	
	assign dout1 = reg_din1 ;
	assign dout2 = pause ? {WIDTH2{1'b0}} : reg_din2 ;//output=dout1 and dout2 is coming from the buffer
	
endmodule
