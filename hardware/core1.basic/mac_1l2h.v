module mac_1l2h#(
	parameter PWIDTH = 32'd32
)(
	input clk,
	input reset,
	input pause,
	
	input mul_en,
	input mac_low,
	input mac_high,
	input [32:0] din1,
	input [32:0] din2,
	
	output [31:0] dlout,
	output [31:0] dhout,
	output vldout,
	output vhdout
);
	
	wire mac_en = (mac_low | mac_high) & !mul_en ;
	
	reg [65:0] reg_data;
	
	wire [PWIDTH-1:0] old_data0 = (mul_en) ? {PWIDTH{1'b0}} : reg_data ;
	
	wire [33:00] pp01 = { 1'b1, ~(din1[32] & din2[00]), ( din1[31:0] & {32{din2[00]}} ) };
	wire [33:00] pp02 = { ~(din1[32] & din2[01]), (din1[31:0] & {32{din2[01]}}),  1'd0 };
	wire [34:00] pp03 = { ~(din1[32] & din2[02]), (din1[31:0] & {32{din2[02]}}),  2'd0 };
	wire [35:00] pp04 = { ~(din1[32] & din2[03]), (din1[31:0] & {32{din2[03]}}),  3'd0 };
	wire [36:00] pp05 = { ~(din1[32] & din2[04]), (din1[31:0] & {32{din2[04]}}),  4'd0 };
	wire [37:00] pp06 = { ~(din1[32] & din2[05]), (din1[31:0] & {32{din2[05]}}),  5'd0 };
	wire [38:00] pp07 = { ~(din1[32] & din2[06]), (din1[31:0] & {32{din2[06]}}),  6'd0 };
	wire [39:00] pp08 = { ~(din1[32] & din2[07]), (din1[31:0] & {32{din2[07]}}),  7'd0 };
	wire [40:00] pp09 = { ~(din1[32] & din2[08]), (din1[31:0] & {32{din2[08]}}),  8'd0 };
	wire [41:00] pp10 = { ~(din1[32] & din2[09]), (din1[31:0] & {32{din2[09]}}),  9'd0 };
	wire [42:00] pp11 = { ~(din1[32] & din2[10]), (din1[31:0] & {32{din2[10]}}), 10'd0 };
	wire [43:00] pp12 = { ~(din1[32] & din2[11]), (din1[31:0] & {32{din2[11]}}), 11'd0 };
	wire [44:00] pp13 = { ~(din1[32] & din2[12]), (din1[31:0] & {32{din2[12]}}), 12'd0 };
	wire [45:00] pp14 = { ~(din1[32] & din2[13]), (din1[31:0] & {32{din2[13]}}), 13'd0 };
	wire [46:00] pp15 = { ~(din1[32] & din2[14]), (din1[31:0] & {32{din2[14]}}), 14'd0 };
	wire [47:00] pp16 = { ~(din1[32] & din2[15]), (din1[31:0] & {32{din2[15]}}), 15'd0 };
	wire [48:00] pp17 = { ~(din1[32] & din2[16]), (din1[31:0] & {32{din2[16]}}), 16'd0 };
	wire [49:00] pp18 = { ~(din1[32] & din2[17]), (din1[31:0] & {32{din2[17]}}), 17'd0 };
	wire [50:00] pp19 = { ~(din1[32] & din2[18]), (din1[31:0] & {32{din2[18]}}), 18'd0 };
	wire [51:00] pp20 = { ~(din1[32] & din2[19]), (din1[31:0] & {32{din2[19]}}), 19'd0 };
	wire [52:00] pp21 = { ~(din1[32] & din2[20]), (din1[31:0] & {32{din2[20]}}), 20'd0 };
	wire [53:00] pp22 = { ~(din1[32] & din2[21]), (din1[31:0] & {32{din2[21]}}), 21'd0 };
	wire [54:00] pp23 = { ~(din1[32] & din2[22]), (din1[31:0] & {32{din2[22]}}), 22'd0 };
	wire [55:00] pp24 = { ~(din1[32] & din2[23]), (din1[31:0] & {32{din2[23]}}), 23'd0 };
	wire [56:00] pp25 = { ~(din1[32] & din2[24]), (din1[31:0] & {32{din2[24]}}), 24'd0 };
	wire [57:00] pp26 = { ~(din1[32] & din2[25]), (din1[31:0] & {32{din2[25]}}), 25'd0 };
	wire [58:00] pp27 = { ~(din1[32] & din2[26]), (din1[31:0] & {32{din2[26]}}), 26'd0 };
	wire [59:00] pp28 = { ~(din1[32] & din2[27]), (din1[31:0] & {32{din2[27]}}), 27'd0 };
	wire [60:00] pp29 = { ~(din1[32] & din2[28]), (din1[31:0] & {32{din2[28]}}), 28'd0 };
	wire [61:00] pp30 = { ~(din1[32] & din2[29]), (din1[31:0] & {32{din2[29]}}), 29'd0 };
	wire [62:00] pp31 = { ~(din1[32] & din2[30]), (din1[31:0] & {32{din2[30]}}), 30'd0 };
	wire [63:00] pp32 = { ~(din1[32] & din2[31]), (din1[31:0] & {32{din2[31]}}), 31'd0 };
	wire [65:00] pp33 = { 1'b1, (din1[32] & din2[32]), ~(din1[31:0] & {32{din2[32]}}), 32'd0 };
	
	wire [PWIDTH+5:0] sum0 = pp01[PWIDTH-1:0] + pp02[PWIDTH-1:0] + pp03[PWIDTH-1:0] + pp04[PWIDTH-1:0] + pp05[PWIDTH-1:0] + pp06[PWIDTH-1:0] + pp07[PWIDTH-1:0] + pp08[PWIDTH-1:0] 
	+                        pp09[PWIDTH-1:0] + pp10[PWIDTH-1:0] + pp11[PWIDTH-1:0] + pp12[PWIDTH-1:0] + pp13[PWIDTH-1:0] + pp14[PWIDTH-1:0] + pp15[PWIDTH-1:0] + pp16[PWIDTH-1:0] 
	+                        pp17[PWIDTH-1:0] + pp18[PWIDTH-1:0] + pp19[PWIDTH-1:0] + pp20[PWIDTH-1:0] + pp21[PWIDTH-1:0] + pp22[PWIDTH-1:0] + pp23[PWIDTH-1:0] + pp24[PWIDTH-1:0] 
	+                        pp25[PWIDTH-1:0] + pp26[PWIDTH-1:0] + pp27[PWIDTH-1:0] + pp28[PWIDTH-1:0] + pp29[PWIDTH-1:0] + pp30[PWIDTH-1:0] + pp31[PWIDTH-1:0] + pp32[PWIDTH-1:0] 
	+                        pp33[PWIDTH-1:0] + old_data0 ;
	
	wire [65:PWIDTH] sum1 = pp01[33:PWIDTH] + pp02[33:PWIDTH] + pp03[34:PWIDTH] + pp04[35:PWIDTH] + pp05[36:PWIDTH] + pp06[37:PWIDTH] + pp07[38:PWIDTH] + pp08[39:PWIDTH] 
	+                       pp09[40:PWIDTH] + pp10[41:PWIDTH] + pp11[42:PWIDTH] + pp12[43:PWIDTH] + pp13[44:PWIDTH] + pp14[45:PWIDTH] + pp15[46:PWIDTH] + pp16[47:PWIDTH] 
	+                       pp17[48:PWIDTH] + pp18[49:PWIDTH] + pp19[50:PWIDTH] + pp20[51:PWIDTH] + pp21[52:PWIDTH] + pp22[53:PWIDTH] + pp23[54:PWIDTH] + pp24[55:PWIDTH] 
	+                       pp25[56:PWIDTH] + pp26[57:PWIDTH] + pp27[58:PWIDTH] + pp28[59:PWIDTH] + pp29[60:PWIDTH] + pp30[61:PWIDTH] + pp31[62:PWIDTH] + pp32[63:PWIDTH] 
	+                       pp33[65:PWIDTH] ;
	
	reg [PWIDTH+5:PWIDTH] reg_sum0; always@(posedge clk) if (reset) reg_sum0 <= 0; else if (!pause & (mac_en|mul_en)) reg_sum0 <= sum0[PWIDTH+5:PWIDTH] ;
	reg [65:PWIDTH]       reg_sum1; always@(posedge clk) if (reset) reg_sum1 <= 0; else if (!pause & (mac_en|mul_en)) reg_sum1 <= sum1 ;
	
	reg reg_en  ; always@(posedge clk) if (reset) reg_en   <= 0; else if (!pause) reg_en   <= mac_en;
	reg reg_init; always@(posedge clk) if (reset) reg_init <= 0; else if (!pause) reg_init <= mul_en;
	
	localparam WIDTH1 = 66 - PWIDTH ;
	wire [65:PWIDTH] old_data1 = (reg_init) ? {WIDTH1{1'b0}} : reg_data[65:PWIDTH];
	
	wire [65:PWIDTH] sum21 = reg_sum0 + reg_sum1 + old_data1 ;
	
	always@(posedge clk) begin
		if (reset) begin
			reg_data <= 66'd0; 
		end else if (!pause) begin
			if      (vldout && vhdout) reg_data             <= {sum21, sum0[PWIDTH-1:0]} ;
			else if (vldout          ) reg_data[PWIDTH-1:0] <= sum0[PWIDTH-1:0] ;
			else if (vhdout          ) reg_data[65:PWIDTH]  <= sum21 ;
		end
	end
	
	reg reg_datah; always@(posedge clk) if (reset) reg_datah <= 0; else if (!pause) reg_datah <= mac_high;
	
	assign dlout = sum0  ;
	assign dhout = sum21 ;
	
	assign vldout = !pause & mac_low ; 
	assign vhdout = !pause & reg_datah ;

endmodule
