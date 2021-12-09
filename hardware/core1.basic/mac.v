module mac#(
	parameter PWIDTH  = 32'd22,
	parameter PWIDTH1 = 32'd44
)(
	input clk,
	input reset,
	input pause,
	
	input mul_en,
	input mac_low,
	input mac_high,
	input [32:0] din1,
	input [32:0] din2,
	
	// output [65:0] test,
	
	output [31:0] dlout,
	output [31:0] dhout,
	output vldout,
	output vhdout
);
	
	wire wire_en = (mac_low | mac_high) ;
	
	wire acc_en = wire_en & !mul_en ;
	
	reg [65:0] reg_data;
	
	wire [PWIDTH-1:0] old_data = (mul_en) ? {PWIDTH{1'b0}} : reg_data[PWIDTH-1:0] ;
	
	wire [33:00] pp01 = { 1'b1, ~(din1[32] & din2[00]), ( din1[31:0] & {32{din2[00]}} ) };
	wire [33:01] pp02 = { ~(din1[32] & din2[01]), (din1[31:0] & {32{din2[01]}}) };
	wire [34:02] pp03 = { ~(din1[32] & din2[02]), (din1[31:0] & {32{din2[02]}}) };
	wire [35:03] pp04 = { ~(din1[32] & din2[03]), (din1[31:0] & {32{din2[03]}}) };
	wire [36:04] pp05 = { ~(din1[32] & din2[04]), (din1[31:0] & {32{din2[04]}}) };
	wire [37:05] pp06 = { ~(din1[32] & din2[05]), (din1[31:0] & {32{din2[05]}}) };
	wire [38:06] pp07 = { ~(din1[32] & din2[06]), (din1[31:0] & {32{din2[06]}}) };
	wire [39:07] pp08 = { ~(din1[32] & din2[07]), (din1[31:0] & {32{din2[07]}}) };
	wire [40:08] pp09 = { ~(din1[32] & din2[08]), (din1[31:0] & {32{din2[08]}}) };
	wire [41:09] pp10 = { ~(din1[32] & din2[09]), (din1[31:0] & {32{din2[09]}}) };
	wire [42:10] pp11 = { ~(din1[32] & din2[10]), (din1[31:0] & {32{din2[10]}}) };
	wire [43:11] pp12 = { ~(din1[32] & din2[11]), (din1[31:0] & {32{din2[11]}}) };
	wire [44:12] pp13 = { ~(din1[32] & din2[12]), (din1[31:0] & {32{din2[12]}}) };
	wire [45:13] pp14 = { ~(din1[32] & din2[13]), (din1[31:0] & {32{din2[13]}}) };
	wire [46:14] pp15 = { ~(din1[32] & din2[14]), (din1[31:0] & {32{din2[14]}}) };
	wire [47:15] pp16 = { ~(din1[32] & din2[15]), (din1[31:0] & {32{din2[15]}}) };
	wire [48:16] pp17 = { ~(din1[32] & din2[16]), (din1[31:0] & {32{din2[16]}}) };
	wire [49:17] pp18 = { ~(din1[32] & din2[17]), (din1[31:0] & {32{din2[17]}}) };
	wire [50:18] pp19 = { ~(din1[32] & din2[18]), (din1[31:0] & {32{din2[18]}}) };
	wire [51:19] pp20 = { ~(din1[32] & din2[19]), (din1[31:0] & {32{din2[19]}}) };
	wire [52:20] pp21 = { ~(din1[32] & din2[20]), (din1[31:0] & {32{din2[20]}}) };
	wire [53:21] pp22 = { ~(din1[32] & din2[21]), (din1[31:0] & {32{din2[21]}}) };
	wire [54:22] pp23 = { ~(din1[32] & din2[22]), (din1[31:0] & {32{din2[22]}}) };
	wire [55:23] pp24 = { ~(din1[32] & din2[23]), (din1[31:0] & {32{din2[23]}}) };
	wire [56:24] pp25 = { ~(din1[32] & din2[24]), (din1[31:0] & {32{din2[24]}}) };
	wire [57:25] pp26 = { ~(din1[32] & din2[25]), (din1[31:0] & {32{din2[25]}}) };
	wire [58:26] pp27 = { ~(din1[32] & din2[26]), (din1[31:0] & {32{din2[26]}}) };
	wire [59:27] pp28 = { ~(din1[32] & din2[27]), (din1[31:0] & {32{din2[27]}}) };
	wire [60:28] pp29 = { ~(din1[32] & din2[28]), (din1[31:0] & {32{din2[28]}}) };
	wire [61:29] pp30 = { ~(din1[32] & din2[29]), (din1[31:0] & {32{din2[29]}}) };
	wire [62:30] pp31 = { ~(din1[32] & din2[30]), (din1[31:0] & {32{din2[30]}}) };
	wire [63:31] pp32 = { ~(din1[32] & din2[31]), (din1[31:0] & {32{din2[31]}}) };
	wire [65:32] pp33 = { 1'b1, (din1[32] & din2[32]), ~(din1[31:0] & {32{din2[32]}}) };
	
	
	wire [65:0] p01 = { 32'd0, pp01        };    wire [65:0] p11 = { 23'd0, pp11, 10'd0 };    wire [65:0] p21 = { 13'd0, pp21, 20'd0 };    
	wire [65:0] p02 = { 32'd0, pp02, 01'd0 };    wire [65:0] p12 = { 22'd0, pp12, 11'd0 };    wire [65:0] p22 = { 12'd0, pp22, 21'd0 };    
	wire [65:0] p03 = { 31'd0, pp03, 02'd0 };    wire [65:0] p13 = { 21'd0, pp13, 12'd0 };    wire [65:0] p23 = { 11'd0, pp23, 22'd0 };    
	wire [65:0] p04 = { 30'd0, pp04, 03'd0 };    wire [65:0] p14 = { 20'd0, pp14, 13'd0 };    wire [65:0] p24 = { 10'd0, pp24, 23'd0 };    
	wire [65:0] p05 = { 29'd0, pp05, 04'd0 };    wire [65:0] p15 = { 19'd0, pp15, 14'd0 };    wire [65:0] p25 = { 09'd0, pp25, 24'd0 };    
	wire [65:0] p06 = { 28'd0, pp06, 05'd0 };    wire [65:0] p16 = { 18'd0, pp16, 15'd0 };    wire [65:0] p26 = { 08'd0, pp26, 25'd0 };    
	wire [65:0] p07 = { 27'd0, pp07, 06'd0 };    wire [65:0] p17 = { 17'd0, pp17, 16'd0 };    wire [65:0] p27 = { 07'd0, pp27, 26'd0 };    
	wire [65:0] p08 = { 26'd0, pp08, 07'd0 };    wire [65:0] p18 = { 16'd0, pp18, 17'd0 };    wire [65:0] p28 = { 06'd0, pp28, 27'd0 };    
	wire [65:0] p09 = { 25'd0, pp09, 08'd0 };    wire [65:0] p19 = { 15'd0, pp19, 18'd0 };    wire [65:0] p29 = { 05'd0, pp29, 28'd0 };    
	wire [65:0] p10 = { 24'd0, pp10, 09'd0 };    wire [65:0] p20 = { 14'd0, pp20, 19'd0 };    wire [65:0] p30 = { 04'd0, pp30, 29'd0 };    
	
	wire [65:0] p31 = { 03'd0, pp31, 30'd0 };
	wire [65:0] p32 = { 02'd0, pp32, 31'd0 };
	wire [65:0] p33 = {        pp33, 32'd0 };
	
	// assign test = p01 + p02 + p03 + p04 + p05 + p06 + p07 + p08 
	// +             p09 + p10 + p11 + p12 + p13 + p14 + p15 + p16 
	// +             p17 + p18 + p19 + p20 + p21 + p22 + p23 + p24 
	// +             p25 + p26 + p27 + p28 + p29 + p30 + p31 + p32 
	// +             p33 ;
	
	wire [PWIDTH+5:0] wire_sum11 = p01[PWIDTH-1:0] + p02[PWIDTH-1:0] + p03[PWIDTH-1:0] + p04[PWIDTH-1:0] + p05[PWIDTH-1:0] + p06[PWIDTH-1:0] + p07[PWIDTH-1:0] + p08[PWIDTH-1:0] 
	+                              p09[PWIDTH-1:0] + p10[PWIDTH-1:0] + p11[PWIDTH-1:0] + p12[PWIDTH-1:0] + p13[PWIDTH-1:0] + p14[PWIDTH-1:0] + p15[PWIDTH-1:0] + p16[PWIDTH-1:0] 
	+                              p17[PWIDTH-1:0] + p18[PWIDTH-1:0] + p19[PWIDTH-1:0] + p20[PWIDTH-1:0] + p21[PWIDTH-1:0] + p22[PWIDTH-1:0] + p23[PWIDTH-1:0] + p24[PWIDTH-1:0] 
	+                              p25[PWIDTH-1:0] + p26[PWIDTH-1:0] + p27[PWIDTH-1:0] + p28[PWIDTH-1:0] + p29[PWIDTH-1:0] + p30[PWIDTH-1:0] + p31[PWIDTH-1:0] + p32[PWIDTH-1:0] 
	+                              p33[PWIDTH-1:0] + old_data ;
	
	
	wire [PWIDTH1+5:PWIDTH] wire_sum12 = p01[PWIDTH1-1:PWIDTH] + p02[PWIDTH1-1:PWIDTH] + p03[PWIDTH1-1:PWIDTH] + p04[PWIDTH1-1:PWIDTH] + p05[PWIDTH1-1:PWIDTH] + p06[PWIDTH1-1:PWIDTH] + p07[PWIDTH1-1:PWIDTH] + p08[PWIDTH1-1:PWIDTH] 
	+                                    p09[PWIDTH1-1:PWIDTH] + p10[PWIDTH1-1:PWIDTH] + p11[PWIDTH1-1:PWIDTH] + p12[PWIDTH1-1:PWIDTH] + p13[PWIDTH1-1:PWIDTH] + p14[PWIDTH1-1:PWIDTH] + p15[PWIDTH1-1:PWIDTH] + p16[PWIDTH1-1:PWIDTH] 
	+                                    p17[PWIDTH1-1:PWIDTH] + p18[PWIDTH1-1:PWIDTH] + p19[PWIDTH1-1:PWIDTH] + p20[PWIDTH1-1:PWIDTH] + p21[PWIDTH1-1:PWIDTH] + p22[PWIDTH1-1:PWIDTH] + p23[PWIDTH1-1:PWIDTH] + p24[PWIDTH1-1:PWIDTH] 
	+                                    p25[PWIDTH1-1:PWIDTH] + p26[PWIDTH1-1:PWIDTH] + p27[PWIDTH1-1:PWIDTH] + p28[PWIDTH1-1:PWIDTH] + p29[PWIDTH1-1:PWIDTH] + p30[PWIDTH1-1:PWIDTH] + p31[PWIDTH1-1:PWIDTH] + p32[PWIDTH1-1:PWIDTH] 
	+                                    p33[PWIDTH1-1:PWIDTH] ;
	
	wire [65:PWIDTH1] wire_sum13 = p01[65:PWIDTH1] + p02[65:PWIDTH1] + p03[65:PWIDTH1] + p04[65:PWIDTH1] + p05[65:PWIDTH1] + p06[65:PWIDTH1] + p07[65:PWIDTH1] + p08[65:PWIDTH1] 
	+                              p09[65:PWIDTH1] + p10[65:PWIDTH1] + p11[65:PWIDTH1] + p12[65:PWIDTH1] + p13[65:PWIDTH1] + p14[65:PWIDTH1] + p15[65:PWIDTH1] + p16[65:PWIDTH1] 
	+                              p17[65:PWIDTH1] + p18[65:PWIDTH1] + p19[65:PWIDTH1] + p20[65:PWIDTH1] + p21[65:PWIDTH1] + p22[65:PWIDTH1] + p23[65:PWIDTH1] + p24[65:PWIDTH1] 
	+                              p25[65:PWIDTH1] + p26[65:PWIDTH1] + p27[65:PWIDTH1] + p28[65:PWIDTH1] + p29[65:PWIDTH1] + p30[65:PWIDTH1] + p31[65:PWIDTH1] + p32[65:PWIDTH1] 
	+                              p33[65:PWIDTH1] ;
	
	// assign test = wire_sum11 + {wire_sum12, {PWIDTH{1'b0}}} + {wire_sum13, {PWIDTH1{1'b0}}} ; 
	
	reg [PWIDTH +5:PWIDTH ] reg_sum11; always@(posedge clk) if (reset) reg_sum11 <= 0; else if (!pause) reg_sum11 <= wire_sum11[PWIDTH+5:PWIDTH] ;
	reg [PWIDTH1+5:PWIDTH ] reg_sum12; always@(posedge clk) if (reset) reg_sum12 <= 0; else if (!pause) reg_sum12 <= wire_sum12 ;
	reg [       65:PWIDTH1] reg_sum13; always@(posedge clk) if (reset) reg_sum13 <= 0; else if (!pause) reg_sum13 <= wire_sum13 ;
	
	reg reg_mul_en1  ; always@(posedge clk) if (reset) reg_mul_en1   <= 0; else if (!pause) reg_mul_en1   <= mul_en ;
	reg reg_mac_low1 ; always@(posedge clk) if (reset) reg_mac_low1  <= 0; else if (!pause) reg_mac_low1  <= mac_low ;
	reg reg_mac_high1; always@(posedge clk) if (reset) reg_mac_high1 <= 0; else if (!pause) reg_mac_high1 <= mac_high ;
	
// Stage 2
// --------------------------------------------------------------------------------------------------------------------------------------------
	
	wire [PWIDTH1-1:PWIDTH] old_data2 = (reg_mul_en1) ? {(PWIDTH1-PWIDTH){1'b0}} : reg_data[PWIDTH1-1:PWIDTH] ;
	
	wire [PWIDTH1+1:PWIDTH ] wire_sum21 = reg_sum11[PWIDTH +5:PWIDTH ] + reg_sum12[PWIDTH1-1:PWIDTH ] + old_data2 ;
	wire [       65:PWIDTH1] wire_sum22 = reg_sum12[PWIDTH1+5:PWIDTH1] + reg_sum13[       65:PWIDTH1] ;
	
	// assign test = reg_data[PWIDTH-1:0] + {wire_sum21, {PWIDTH{1'b0}}} + {wire_sum22, {PWIDTH1{1'b0}}} ; 
	
	reg [PWIDTH1+1:PWIDTH1] reg_sum21; always@(posedge clk) if (reset) reg_sum21 <= 0; else if (!pause) reg_sum21 <= wire_sum21[PWIDTH1+1:PWIDTH1] ;
	reg [       65:PWIDTH1] reg_sum22; always@(posedge clk) if (reset) reg_sum22 <= 0; else if (!pause) reg_sum22 <= wire_sum22[65:PWIDTH1] ;
	
	reg reg_mul_en2  ; always@(posedge clk) if (reset) reg_mul_en2   <= 0; else if (!pause) reg_mul_en2   <= reg_mul_en1 ;
	reg reg_mac_low2 ; always@(posedge clk) if (reset) reg_mac_low2  <= 0; else if (!pause) reg_mac_low2  <= reg_mac_low1 ;
	reg reg_mac_high2; always@(posedge clk) if (reset) reg_mac_high2 <= 0; else if (!pause) reg_mac_high2 <= reg_mac_high1 ;
	
// Stage 3
// --------------------------------------------------------------------------------------------------------------------------------------------
	
	wire [65:PWIDTH1] old_data3 = (reg_mul_en2) ? {(66-PWIDTH1){1'b0}} : reg_data[65:PWIDTH1] ;
	
	wire [65:PWIDTH1] wire_sum31 = reg_sum21 + reg_sum22 + old_data3 ;
	
	wire wire_en1 = reg_mac_low1 | reg_mac_high1 ;
	wire wire_en2 = reg_mac_low2 | reg_mac_high2 ;
	
	always@(posedge clk) begin
		if (reset) reg_data[PWIDTH -1:0      ] <= 0; else if (!pause & wire_en  ) reg_data[PWIDTH -1:0      ] <= wire_sum11[PWIDTH -1:0      ] ;
		if (reset) reg_data[PWIDTH1-1:PWIDTH ] <= 0; else if (!pause & wire_en1 ) reg_data[PWIDTH1-1:PWIDTH ] <= wire_sum21[PWIDTH1-1:PWIDTH ] ;
		if (reset) reg_data[       65:PWIDTH1] <= 0; else if (!pause & wire_en2 ) reg_data[       65:PWIDTH1] <= wire_sum31[       65:PWIDTH1] ;
	end
	
	assign dlout = { wire_sum21[31:PWIDTH],  reg_data[PWIDTH -1:0 ] };
	assign dhout = { wire_sum31[65:PWIDTH1], reg_data[PWIDTH1-1:32] };
	
	assign vldout = !pause & reg_mac_low1 ; 
	assign vhdout = !pause & reg_mac_high2 ;
	
endmodule
