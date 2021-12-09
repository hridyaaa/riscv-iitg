module finite_field_mul (
	input [31:0] rs1,
	input [31:0] rs2,
// output signals
	output [31:0] rd_data
);
	
	wire [7:0] rs10 = rs1[07:00];
	wire [7:0] rs11 = rs1[15:08];
	wire [7:0] rs12 = rs1[23:16];
	wire [7:0] rs13 = rs1[31:24];
	
	wire [7:0] rs20 = rs2[07:00];
	wire [7:0] rs21 = rs2[15:08];
	wire [7:0] rs22 = rs2[23:16];
	wire [7:0] rs23 = rs2[31:24];
	
	wire [07:0] p00 = rs20[0] ? rs10 :  8'd0 ;
	wire [08:0] p01 = rs20[1] ? {rs10,1'd0} :  9'd0 ;
	wire [09:0] p02 = rs20[2] ? {rs10,2'd0} : 10'd0 ;
	wire [10:0] p03 = rs20[3] ? {rs10,3'd0} : 11'd0 ;
	wire [11:0] p04 = rs20[4] ? {rs10,4'd0} : 12'd0 ;
	wire [12:0] p05 = rs20[5] ? {rs10,5'd0} : 13'd0 ;
	wire [13:0] p06 = rs20[6] ? {rs10,6'd0} : 14'd0 ;
	wire [14:0] p07 = rs20[7] ? {rs10,7'd0} : 15'd0 ;
	
	wire [07:0] p10 = rs21[0] ? rs11 :  8'd0 ;
	wire [08:0] p11 = rs21[1] ? {rs11,1'd0} :  9'd0 ;
	wire [09:0] p12 = rs21[2] ? {rs11,2'd0} : 10'd0 ;
	wire [10:0] p13 = rs21[3] ? {rs11,3'd0} : 11'd0 ;
	wire [11:0] p14 = rs21[4] ? {rs11,4'd0} : 12'd0 ;
	wire [12:0] p15 = rs21[5] ? {rs11,5'd0} : 13'd0 ;
	wire [13:0] p16 = rs21[6] ? {rs11,6'd0} : 14'd0 ;
	wire [14:0] p17 = rs21[7] ? {rs11,7'd0} : 15'd0 ;
	
	wire [07:0] p20 = rs22[0] ? rs12 :  8'd0 ;
	wire [08:0] p21 = rs22[1] ? {rs12,1'd0} :  9'd0 ;
	wire [09:0] p22 = rs22[2] ? {rs12,2'd0} : 10'd0 ;
	wire [10:0] p23 = rs22[3] ? {rs12,3'd0} : 11'd0 ;
	wire [11:0] p24 = rs22[4] ? {rs12,4'd0} : 12'd0 ;
	wire [12:0] p25 = rs22[5] ? {rs12,5'd0} : 13'd0 ;
	wire [13:0] p26 = rs22[6] ? {rs12,6'd0} : 14'd0 ;
	wire [14:0] p27 = rs22[7] ? {rs12,7'd0} : 15'd0 ;
	
	wire [07:0] p30 = rs23[0] ? rs13 :  8'd0 ;
	wire [08:0] p31 = rs23[1] ? {rs13,1'd0} :  9'd0 ;
	wire [09:0] p32 = rs23[2] ? {rs13,2'd0} : 10'd0 ;
	wire [10:0] p33 = rs23[3] ? {rs13,3'd0} : 11'd0 ;
	wire [11:0] p34 = rs23[4] ? {rs13,4'd0} : 12'd0 ;
	wire [12:0] p35 = rs23[5] ? {rs13,5'd0} : 13'd0 ;
	wire [13:0] p36 = rs23[6] ? {rs13,6'd0} : 14'd0 ;
	wire [14:0] p37 = rs23[7] ? {rs13,7'd0} : 15'd0 ;
	
	wire [14:0] m0 = p00 ^ p01 ^ p02 ^ p03 ^ p04 ^ p05 ^ p06 ^ p07 ;
	wire [14:0] m1 = p10 ^ p11 ^ p12 ^ p13 ^ p14 ^ p15 ^ p16 ^ p17 ;
	wire [14:0] m2 = p20 ^ p21 ^ p22 ^ p23 ^ p24 ^ p25 ^ p26 ^ p27 ;
	wire [14:0] m3 = p30 ^ p31 ^ p32 ^ p33 ^ p34 ^ p35 ^ p36 ^ p37 ;
	
	wire [14:0] result = m0 ^ m1 ^ m2 ^ m3 ;
	
	// // works for all Rijndael's (AES) 8-bit finite field (Galois field) multiplication
	// wire [14:0] result6 = result[14]  ? result  ^ 15'b100011011000000 : result;
	// wire [13:0] result5 = result6[13] ? result6 ^ 14'b10001101100000 : result6;
	// wire [12:0] result4 = result5[12] ? result5 ^ 13'b1000110110000 : result5;
	// wire [11:0] result3 = result4[11] ? result4 ^ 12'b100011011000 : result4;
	// wire [10:0] result2 = result3[10] ? result3 ^ 11'b10001101100 : result3;
	// wire [ 9:0] result1 = result2[9]  ? result2 ^ 10'b1000110110 : result2;
	// wire [ 8:0] result0 = result1[8]  ? result1 ^  9'b100011011 : result1;
	
	// works only for Rijndael's (AES) finite field (Galois field) multiplication
	wire [8:0] result0 = result[8] ? result ^ 9'b100011011 : result;
	
	assign rd_data = {24'h000000, result0[7:0]} ;
	
	
endmodule
