module DBP#(
		parameter AWIDTH=10,//address width 
		parameter DWIDTH=34//data width
)(
		input clk,
		input reset,
		input clear_dbp,
		input pause,
		
	//------------------------------------- input
		input        inst_req,
		input [31:0] inst_add,
		
		input        de_pfalse,
		input [31:0] pc_pc,
		input [31:0] buff_pc_pc,
		
		input        jal,
		input [31:0] jal_add,
		
		input [31:0] buff_dd_pc,
		
		input        buff_ex_jal,
		input        buff_ex_jb,
		input        buff_ex_jb_en,
		input [31:0] buff_ex_jb_add,
		input [31:0] buff_ex_pc,
		
	//------------------------------------- output
		output [AWIDTH-1:0] add1,
		input  [DWIDTH-1:0] rdata1,
		output [AWIDTH-1:0] add2,
		input  [DWIDTH-1:0] rdata2,
		output              wen2,
		output [DWIDTH-1:0] wdata2,
		
		output        pc_update1,
		output        pc_update2,
		output        pc_update3,
		output        pc_update4,
		output [31:0] pc_update_add
    );
	
//------------------------------------- Dynamic Branch Table
	
	assign add1 = inst_add[AWIDTH+1:2] ;
	assign add2 = wen2 ? buff_ex_pc[AWIDTH+1:2] : buff_dd_pc[AWIDTH+1:2] ;
	
	wire [31:0] bht_badd1  ; 
	wire [1:0]  bht_count1 ; 
	
	assign {bht_count1, bht_badd1} = rdata1 ;
	
	wire [31:0] bht_badd2  ; 
	wire [1:0]  bht_count2 ; 
	
	assign {bht_count2, bht_badd2} = rdata2 ;
	
//-------------------------------------  Branch Prediction
	
	reg        reg_inst_req; always@(posedge clk) if (reset|clear_dbp) reg_inst_req <= 0; else if (!pause) reg_inst_req <= inst_req ;
	reg [31:0] reg_inst_add; always@(posedge clk) if (reset|clear_dbp) reg_inst_add <= 0; else if (!pause) reg_inst_add <= inst_add ;
	
	wire        predict_en  = ( reg_inst_req & bht_count1>1 ) ? 1'b1 : 1'b0 ;
	wire [31:0] predict_add = bht_badd1 ;
	
//------------------------------------- Branch Table Check
	
	wire branch_take  = buff_ex_jb_en ;
	wire branch_ntake = buff_ex_jb & !buff_ex_jb_en ;
	
	wire wrong_prediction = ( ( branch_ntake | branch_take ) & ( buff_ex_jb_add != buff_dd_pc ) ) ? 1'b1 : 1'b0 ;
	
	wire [31:0] pc_update_add1 = predict_add    ;
	wire [31:0] pc_update_add2 = buff_pc_pc+4   ;
	wire [31:0] pc_update_add3 = jal_add        ;
	wire [31:0] pc_update_add4 = buff_ex_jb_add ;
	
	assign pc_update1 = !pause & predict_en ;
	assign pc_update2 = !pause & de_pfalse ;
	assign pc_update3 = (jal & jal_add!=buff_pc_pc) ;
	assign pc_update4 = wrong_prediction ;
	
	// assign pc_update = pc_update3 ? 1 
	// :                  pause      ? 0 
	// :                  pc_update2 ? 1
	// :                  pc_update1 ? 1 
	// :                               0 ;
	
	assign pc_update_add = pc_update4 ? pc_update_add4
	:                      pc_update3 ? pc_update_add3
	:                      pc_update2 ? pc_update_add2
	:                                   pc_update_add1 ;
	
	//------------------------------------- Branch Table Update
	
	wire [1:0] count = (branch_ntake & bht_count2>0) ? (bht_count2-1)
	:                  (bht_count2<3)                ? (bht_count2+1) 
	:                                                   bht_count2 ;
	
	assign wen2 = branch_ntake | branch_take | buff_ex_jal ;
	
	assign wdata2 = { count, buff_ex_jb_add } ;
	
	// assign pinst = pause ? 0 : pc_update2 ;
	
endmodule
