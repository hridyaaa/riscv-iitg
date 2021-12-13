module reg_bank(
		input clk,
		input reset,
		input clear_de,
		//--------------------------- Write channel
		input        wrd_en1,
        input [4:0]  wrd_add1,
        input [31:0] wrd_data1,
		input        wrd_en2,
        input [4:0]  wrd_add2,
        input [31:0] wrd_data2,
		//--------------------------- Read channel
		input  [4:0]  rs1_add,
		input         rs1_en,
		input  [4:0]  rs2_add,
		input         rs2_en,
		input  [4:0]  rd_add,
		input         rd_en,
		//--------------------------- Outputs
		output [31:0] rs1_data,
		output [31:0] rs2_data,
		output        rs1_wait,
		output        rs2_wait,
		output        rd_wait ,
		output [ 1:0] rs1_tag ,
		output [ 1:0] rs2_tag ,
		output [ 1:0] rd_tag  
    );

	reg [31:0] mem [0:31];
	
// ---------------		Write Channel		-------------------- //	
	
	wire vwrd_en1 = wrd_en1 & wrd_add1!=0 ; 
	wire vwrd_en2 = wrd_en2 & wrd_add2!=0 ; 
	
	always@(posedge clk) begin
        if ( reset ) begin			
			mem[00] <= 32'd0; mem[01] <= 32'd0; mem[02] <= 32'h0002f000; mem[03] <= 32'd0; 
			mem[04] <= 32'd0; mem[05] <= 32'd0; mem[06] <= 32'd0; mem[07] <= 32'd0; 
			mem[08] <= 32'd0; mem[09] <= 32'd0; mem[10] <= 32'd0; mem[11] <= 32'd0; 
			mem[12] <= 32'd0; mem[13] <= 32'd0; mem[14] <= 32'd0; mem[15] <= 32'd0; 
			mem[16] <= 32'd0; mem[17] <= 32'd0; mem[18] <= 32'd0; mem[19] <= 32'd0; 
			mem[20] <= 32'd0; mem[21] <= 32'd0; mem[22] <= 32'd0; mem[23] <= 32'd0; 
			mem[24] <= 32'd0; mem[25] <= 32'd0; mem[26] <= 32'd0; mem[27] <= 32'd0; 
			mem[28] <= 32'd0; mem[29] <= 32'd0; mem[30] <= 32'd0; mem[31] <= 32'd0; 
		end else if (!(vwrd_en1 & vwrd_en2 & wrd_add1==wrd_add2)) begin
			if (vwrd_en1) mem[wrd_add1] <= wrd_data1;
			if (vwrd_en2) mem[wrd_add2] <= wrd_data2;
		end
    end
	
// ---------------		Read Channel		--------------------//
	
	reg [2:0] reg_rd_count [31:0] ;
	
	wire vrs1_en = rs1_en & rs1_add!=0 ;
	wire vrs2_en = rs2_en & rs2_add!=0 ;
	wire vrd_en  = rd_en  & rd_add!=0  ;
	
	wire rs1_wready1 = vrs1_en & wrd_en1 & wrd_add1==rs1_add & (reg_rd_count[rs1_add] == 1) ;
	wire rs2_wready1 = vrs2_en & wrd_en1 & wrd_add1==rs2_add & (reg_rd_count[rs2_add] == 1) ;
	wire rd_wready1  = vrd_en  & wrd_en1 & wrd_add1==rd_add  & (reg_rd_count[rd_add]  == 1) ;
	
	wire rs1_wready2 = vrs1_en & wrd_en2 & wrd_add2==rs1_add & (reg_rd_count[rs1_add] == 1) ;
	wire rs2_wready2 = vrs2_en & wrd_en2 & wrd_add2==rs2_add & (reg_rd_count[rs2_add] == 1) ;
	wire rd_wready2  = vrd_en  & wrd_en2 & wrd_add2==rd_add  & (reg_rd_count[rd_add]  == 1) ;
	
	always@(posedge clk) begin
		if ( reset | clear_de ) begin
			reg_rd_count[00] <= 0;   reg_rd_count[01] <= 0;   reg_rd_count[02] <= 0;   reg_rd_count[03] <= 0;
			reg_rd_count[04] <= 0;   reg_rd_count[05] <= 0;   reg_rd_count[06] <= 0;   reg_rd_count[07] <= 0;
			reg_rd_count[08] <= 0;   reg_rd_count[09] <= 0;   reg_rd_count[10] <= 0;   reg_rd_count[11] <= 0;
			reg_rd_count[12] <= 0;   reg_rd_count[13] <= 0;   reg_rd_count[14] <= 0;   reg_rd_count[15] <= 0;
			reg_rd_count[16] <= 0;   reg_rd_count[17] <= 0;   reg_rd_count[18] <= 0;   reg_rd_count[19] <= 0;
			reg_rd_count[20] <= 0;   reg_rd_count[21] <= 0;   reg_rd_count[22] <= 0;   reg_rd_count[23] <= 0;
			reg_rd_count[24] <= 0;   reg_rd_count[25] <= 0;   reg_rd_count[26] <= 0;   reg_rd_count[27] <= 0;
			reg_rd_count[28] <= 0;   reg_rd_count[29] <= 0;   reg_rd_count[30] <= 0;   reg_rd_count[31] <= 0;
		// end else if ( !(vrd_en & wrd_en1 & wrd_add1==rd_add) & !(vrd_en & wrd_en2 & wrd_add2==rd_add) ) begin 
		end else begin 
			if ( vrd_en & !(wrd_en1 & wrd_add1==rd_add & reg_rd_count[rd_add]!=0) & !(wrd_en2 & wrd_add2==rd_add & reg_rd_count[rd_add]!=0) ) reg_rd_count[rd_add] <= reg_rd_count[rd_add] + 1'b1;
			
			if ( wrd_en1 & reg_rd_count[wrd_add1]!=0 & !(vrd_en & wrd_add1==rd_add) ) reg_rd_count[wrd_add1] <= reg_rd_count[wrd_add1] - 1'b1;
			if ( wrd_en2 & reg_rd_count[wrd_add2]!=0 & !(vrd_en & wrd_add2==rd_add) ) reg_rd_count[wrd_add2] <= reg_rd_count[wrd_add2] - 1'b1;
		end
	end
	
	// wire [31:0] rready = reg_rd_count;
	
	wire rs1_ready = ( reg_rd_count[rs1_add] != 0 ) ? 1'b0 : 1'b1 ;
	wire rs2_ready = ( reg_rd_count[rs2_add] != 0 ) ? 1'b0 : 1'b1 ;
	wire  rd_ready = ( reg_rd_count[rd_add]  != 0 ) ? 1'b0 : 1'b1 ;
	
	assign rs1_wait = ( vrs1_en & !rs1_ready & !rs1_wready1 & !rs1_wready2 ) ? 1'b1 : 1'b0 ;
	assign rs2_wait = ( vrs2_en & !rs2_ready & !rs2_wready1 & !rs2_wready2 ) ? 1'b1 : 1'b0 ;
	assign rd_wait  = ( vrd_en  & !rd_ready  & !rd_wready1  & !rd_wready2  ) ? 1'b1 : 1'b0 ;
	
	assign rs1_data = ( vrs1_en & wrd_en1 & wrd_add1==rs1_add ) ? wrd_data1 : ( vrs1_en & wrd_en2 & wrd_add2==rs1_add ) ? wrd_data2 : mem[rs1_add];
	assign rs2_data = ( vrs2_en & wrd_en1 & wrd_add1==rs2_add ) ? wrd_data1 : ( vrs2_en & wrd_en2 & wrd_add2==rs2_add ) ? wrd_data2 : mem[rs2_add];
	
	reg [1:0] reg_tag_count [31:0] ;
	always@(posedge clk) begin
		if ( reset ) begin
			reg_tag_count[00] <= 0;   reg_tag_count[01] <= 0;   reg_tag_count[02] <= 0;   reg_tag_count[03] <= 0;
			reg_tag_count[04] <= 0;   reg_tag_count[05] <= 0;   reg_tag_count[06] <= 0;   reg_tag_count[07] <= 0;
			reg_tag_count[08] <= 0;   reg_tag_count[09] <= 0;   reg_tag_count[10] <= 0;   reg_tag_count[11] <= 0;
			reg_tag_count[12] <= 0;   reg_tag_count[13] <= 0;   reg_tag_count[14] <= 0;   reg_tag_count[15] <= 0;
			reg_tag_count[16] <= 0;   reg_tag_count[17] <= 0;   reg_tag_count[18] <= 0;   reg_tag_count[19] <= 0;
			reg_tag_count[20] <= 0;   reg_tag_count[21] <= 0;   reg_tag_count[22] <= 0;   reg_tag_count[23] <= 0;
			reg_tag_count[24] <= 0;   reg_tag_count[25] <= 0;   reg_tag_count[26] <= 0;   reg_tag_count[27] <= 0;
			reg_tag_count[28] <= 0;   reg_tag_count[29] <= 0;   reg_tag_count[30] <= 0;   reg_tag_count[31] <= 0;
		// end else if ( !(vrd_en & wrd_en1 & wrd_add1==rd_add) & !(vrd_en & wrd_en2 & wrd_add2==rd_add) ) begin 
		end else begin 
			if ( vrd_en ) reg_tag_count[rd_add] <= reg_tag_count[rd_add] + 1'b1;
		end
	end
	
	assign rs1_tag = reg_tag_count[rs1_add] ;
	assign rs2_tag = reg_tag_count[rs2_add] ;
	assign rd_tag  = reg_tag_count[rd_add]  ;
	
// // ---------------		Reg Status Write (Simulation Only)	-------------------- //
	
	// reg_status_write  inst_reg_status_write (
	   // .clk        ( clk        ),
	   // .reset      ( reset      ),
	   // .wrd_en1    ( wrd_en1    ),
	   // .wrd_add1   ( wrd_add1   ),
	   // .wrd_en2    ( wrd_en2    ),
	   // .wrd_add2   ( wrd_add2   ),
	   // .rd_en_all  ( sim_rd_en  ),
	   // .rd_add_all ( sim_rd_add ),
	   // .pc         ( sim_pc     ),
	   // .mem_wen    ( mem_wen    ),
	   // .mem_wadd   ( mem_wadd   ),
	   // .mem_wdata  ( mem_wdata  ),
	   // .mem00      ( mem[00]   ),	   .mem01      ( mem[01]   ),	   .mem02      ( mem[02]   ),	   .mem03      ( mem[03]   ),
	   // .mem04      ( mem[04]   ),	   .mem05      ( mem[05]   ),	   .mem06      ( mem[06]   ),	   .mem07      ( mem[07]   ),
	   // .mem08      ( mem[08]   ),	   .mem09      ( mem[09]   ),	   .mem10      ( mem[10]   ),	   .mem11      ( mem[11]   ),
	   // .mem12      ( mem[12]   ),	   .mem13      ( mem[13]   ),	   .mem14      ( mem[14]   ),	   .mem15      ( mem[15]   ),
	   // .mem16      ( mem[16]   ),	   .mem17      ( mem[17]   ),	   .mem18      ( mem[18]   ),	   .mem19      ( mem[19]   ),
	   // .mem20      ( mem[20]   ),	   .mem21      ( mem[21]   ),	   .mem22      ( mem[22]   ),	   .mem23      ( mem[23]   ),
	   // .mem24      ( mem[24]   ),	   .mem25      ( mem[25]   ),	   .mem26      ( mem[26]   ),	   .mem27      ( mem[27]   ),
	   // .mem28      ( mem[28]   ),	   .mem29      ( mem[29]   ),	   .mem30      ( mem[30]   ),	   .mem31      ( mem[31]   )
	// );
	
endmodule
