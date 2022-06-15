module data_distribute(
	input clk,
	input reset,
	input pause,
//---------------------------------------------- Inputs
	input [31:0] de_rs1     ,
	input [31:0] de_rs2     ,
	input [ 2:0] de_r_wait  ,
	input [ 5:0] de_r_tag   ,
	input [14:0] de_r_add   ,//inputs for decode stage
	
	input        wrd_en1    ,
	input [6:0]  wrd_add1   ,
	input [31:0] wrd_data1  ,
	input        wrd_en2    ,
	input [6:0]  wrd_add2   ,
	input [31:0] wrd_data2  ,
	input        ex_rd_en   ,
	input [6:0]  ex_rd_add  ,
	input [31:0] ex_rd_data ,//inputs for execution stage
	input        mem_rd_en   ,
	input [6:0]  mem_rd_add  ,
	input [31:0] mem_rd_data ,//inputs for memory read
	input        buff_ex_rd_en   ,
	input [6:0]  buff_ex_rd_add  ,
	input [31:0] buff_ex_rd_data ,
//---------------------------------------------- Inputs
	output [31:0] dd_rs1    ,
	output [31:0] dd_rs2    ,
	output [ 1:0] dd_rd_tag ,
	output [ 4:0] dd_rd_add ,//data destribusion variables
	output        dd_pause
);
	
	reg [ 5:0] reg_de_r_tag ; always@(posedge clk) if (reset) reg_de_r_tag <= 0; else if (!pause) reg_de_r_tag <= de_r_tag ;
	reg [14:0] reg_de_r_add ; always@(posedge clk) if (reset) reg_de_r_add <= 0; else if (!pause) reg_de_r_add <= de_r_add ;
	
	wire rs1_vwdata, rs2_vwdata, rd_vwdata ;
	
	reg reg_de_rd_wait  ; always@(posedge clk) if (reset) reg_de_rd_wait  <= 0; else if (!pause) reg_de_rd_wait  <= de_r_wait[2] ; else if ( rd_vwdata  ) reg_de_rd_wait  <= 1'b0 ;
	reg reg_de_rs2_wait ; always@(posedge clk) if (reset) reg_de_rs2_wait <= 0; else if (!pause) reg_de_rs2_wait <= de_r_wait[1] ; else if ( rs2_vwdata ) reg_de_rs2_wait <= 1'b0 ;
	reg reg_de_rs1_wait ; always@(posedge clk) if (reset) reg_de_rs1_wait <= 0; else if (!pause) reg_de_rs1_wait <= de_r_wait[0] ; else if ( rs1_vwdata ) reg_de_rs1_wait <= 1'b0 ;
	
	reg [31:0] reg_de_rs1 ; always@(posedge clk) if (reset) reg_de_rs1 <= 0; else if (!pause) reg_de_rs1 <= de_rs1 ; else if ( reg_de_rs1_wait ) reg_de_rs1 <= dd_rs1 ;
	reg [31:0] reg_de_rs2 ; always@(posedge clk) if (reset) reg_de_rs2 <= 0; else if (!pause) reg_de_rs2 <= de_rs2 ; else if ( reg_de_rs2_wait ) reg_de_rs2 <= dd_rs2 ;
	
	wire [1:0] reg_de_rs1_tag, reg_de_rs2_tag, reg_de_rd_tag ;
	
	assign { reg_de_rd_tag, reg_de_rs2_tag, reg_de_rs1_tag } = reg_de_r_tag ;
	
	wire [6:0] rd_add  = { reg_de_rd_tag  - 1, reg_de_r_add[14:10] } ;
	wire [6:0] rs2_add = { reg_de_rs2_tag - 1, reg_de_r_add[09:05] } ;
	wire [6:0] rs1_add = { reg_de_rs1_tag - 1, reg_de_r_add[04:00] } ;
	
	assign rd_vwdata  = ( reg_de_rd_wait & wrd_en1  & rd_add==wrd_add1  ) ? 1'b1
	:                   ( reg_de_rd_wait & wrd_en2  & rd_add==wrd_add2  ) ? 1'b1
	:                   ( reg_de_rd_wait & ex_rd_en & rd_add==ex_rd_add ) ? 1'b1
	:                   ( reg_de_rd_wait & buff_ex_rd_en & rd_add==buff_ex_rd_add ) ? 1'b1
	:                   ( reg_de_rd_wait & mem_rd_en     & rd_add==mem_rd_add     ) ? 1'b1
	:                                                                       1'b0 ;
	
	wire rs1_vwdata1 = ( reg_de_rs1_wait & wrd_en1  & rs1_add==wrd_add1  ) ;
	wire rs1_vwdata2 = ( reg_de_rs1_wait & wrd_en2  & rs1_add==wrd_add2  ) ;
	wire rs1_vwdata3 = ( reg_de_rs1_wait & ex_rd_en & rs1_add==ex_rd_add ) ;
	wire rs1_vwdata4 = ( reg_de_rs1_wait & buff_ex_rd_en & rs1_add==buff_ex_rd_add ) ;
	wire rs1_vwdata5 = ( reg_de_rs1_wait & mem_rd_en     & rs1_add==mem_rd_add ) ;
	
	wire rs2_vwdata1 = ( reg_de_rs2_wait & wrd_en1  & rs2_add==wrd_add1  ) ;
	wire rs2_vwdata2 = ( reg_de_rs2_wait & wrd_en2  & rs2_add==wrd_add2  ) ;
	wire rs2_vwdata3 = ( reg_de_rs2_wait & ex_rd_en & rs2_add==ex_rd_add ) ;
	wire rs2_vwdata4 = ( reg_de_rs2_wait & buff_ex_rd_en & rs2_add==buff_ex_rd_add ) ;
	wire rs2_vwdata5 = ( reg_de_rs2_wait & mem_rd_en     & rs2_add==mem_rd_add ) ;
	
	assign rs1_vwdata = rs1_vwdata1 | rs1_vwdata2 | rs1_vwdata3 | rs1_vwdata4 | rs1_vwdata5 ;
	assign rs2_vwdata = rs2_vwdata1 | rs2_vwdata2 | rs2_vwdata3 | rs2_vwdata4 | rs2_vwdata5 ;
	
	//----------------------------------------------------------------------------------------------------- outputs
	
	assign dd_rd_tag = reg_de_rd_tag;
	assign dd_rd_add = reg_de_r_add[14:10];
	
	assign dd_rs1 = ( rs1_vwdata1 ) ? wrd_data1
	:               ( rs1_vwdata2 ) ? wrd_data2
	:               ( rs1_vwdata3 ) ? ex_rd_data
	:               ( rs1_vwdata4 ) ? buff_ex_rd_data
	:               ( rs1_vwdata5 ) ? mem_rd_data
	:                                 reg_de_rs1 ;
	
	assign dd_rs2 = ( rs2_vwdata1 ) ? wrd_data1
	:               ( rs2_vwdata2 ) ? wrd_data2
	:               ( rs2_vwdata3 ) ? ex_rd_data
	:               ( rs2_vwdata4 ) ? buff_ex_rd_data
	:               ( rs2_vwdata5 ) ? mem_rd_data
	:                                 reg_de_rs2 ;
	
	assign dd_pause = (reg_de_rs1_wait & (!(wrd_en1&(rs1_add==wrd_add1)) & !(wrd_en2&(rs1_add==wrd_add2)) & !(ex_rd_en&(rs1_add==ex_rd_add)) & !(buff_ex_rd_en&(rs1_add==buff_ex_rd_add)) & !(mem_rd_en&(rs1_add==mem_rd_add)))) ? 1'b1
	:                 (reg_de_rs2_wait & (!(wrd_en1&(rs2_add==wrd_add1)) & !(wrd_en2&(rs2_add==wrd_add2)) & !(ex_rd_en&(rs2_add==ex_rd_add)) & !(buff_ex_rd_en&(rs2_add==buff_ex_rd_add)) & !(mem_rd_en&(rs2_add==mem_rd_add)))) ? 1'b1
	:                 (reg_de_rd_wait  & (!(wrd_en1&(rd_add ==wrd_add1)) & !(wrd_en2&(rd_add ==wrd_add2)) & !(ex_rd_en&(rd_add ==ex_rd_add)) & !(buff_ex_rd_en&(rd_add ==buff_ex_rd_add)) & !(mem_rd_en&(rd_add ==mem_rd_add)))) ? 1'b1 
	:                                                                                                                                                      1'b0 ;
	
	// reg [31:0] pause_count=0; always@(posedge clk) if (buff_de_pause) pause_count <= pause_count+1 ;
	
endmodule

