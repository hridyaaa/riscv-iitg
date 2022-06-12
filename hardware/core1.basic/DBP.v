module DBP#(
		parameter AWIDTH=10,//address width 
		parameter DWIDTH=34//data width
)(
		input clk,
		input reset,
		input clear_dbp,
		input pause,
		//riscv will ignores the not taken condition
	//------------------------------------- input
		input        inst_req,
		input [31:0] inst_add,
		
		input        de_pfalse,
		input [31:0] pc_pc,
		input [31:0] buff_pc_pc,// these inputs are coming from other parts of the program
		
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
	
	assign add1 = inst_add[AWIDTH+1:2] ;//for instruction address//index 0 1nd 1 are for future updates,therefore start with index 
	assign add2 = wen2 ? buff_ex_pc[AWIDTH+1:2] : buff_dd_pc[AWIDTH+1:2] ;//write old pc address (already taken addresses of branch prediction table)
	
	wire [31:0] bht_badd1  ; //address in branch prediction table
	wire [1:0]  bht_count1 ; //counter for selectin states of two bit branch predictor
	
	assign {bht_count1, bht_badd1} = rdata1 ;//rdata1 contain info about the addressin branch history table +state
	
	wire [31:0] bht_badd2  ; 
	wire [1:0]  bht_count2 ; 
	
	assign {bht_count2, bht_badd2} = rdata2 ;//for second data
	
//-------------------------------------  Branch Prediction
	
	reg        reg_inst_req;
    always@(posedge clk) 
    if (reset|clear_dbp) reg_inst_req <= 0; //no instruction
    else if (!pause) reg_inst_req <= inst_req ; //if pause == low,instruction req goes to instruction register{like an enable to show whether instruction came or not,i guess}
	reg [31:0] reg_inst_add; //32 bit instruction address
    always@(posedge clk) if (reset|clear_dbp) reg_inst_add <= 0; //if reset,instruction address==000000
    else if (!pause) reg_inst_add <= inst_add ;//if not in pause instruction reg stores instruction address
	
	wire        predict_en  = ( reg_inst_req & bht_count1>1 ) ? 1'b1 : 1'b0 ;//if instruction req is high and if the state (counter)greater than 1 (weakly taken and strongly taken conditions are only possible)the predict enable =1
	wire [31:0] predict_add = bht_badd1 ;//assign address in branch prediction table as the predicted adderess
	
//------------------------------------- Branch Table Check
	
	wire branch_take  = buff_ex_jb_en ;//if the address already present in the history buffer,then taken
	wire branch_ntake = buff_ex_jb & !buff_ex_jb_en ;//previously not used,so branch wont takes.pc will be updated by pc+4
	
	wire wrong_prediction = ( ( branch_ntake | branch_take ) & ( buff_ex_jb_add != buff_dd_pc ) ) ? 1'b1 : 1'b0 ;//pranch prediction will become errorful if taken also.if such case give wrong prediction signal
	
	wire [31:0] pc_update_add1 = predict_add    ;//if taken the predicted address is stored in pc_update_add1
	wire [31:0] pc_update_add2 = buff_pc_pc+4   ;//if not taken update pc to next in struction
	wire [31:0] pc_update_add3 = jal_add        ;//jal instruction changes the address{address become sign extended offset+pc}
	wire [31:0] pc_update_add4 = buff_ex_jb_add ;//old address
	
	assign pc_update1 = !pause & predict_en ;
	assign pc_update2 = !pause & de_pfalse ;//false condition
	assign pc_update3 = (jal & jal_add!=buff_pc_pc) ;
	assign pc_update4 = wrong_prediction ;//mistake in prediction
	
	// assign pc_update = pc_update3 ? 1 
	// :                  pause      ? 0 
	// :                  pc_update2 ? 1
	// :                  pc_update1 ? 1 
	// :                               0 ;
	
	assign pc_update_add = pc_update4 ? pc_update_add4//if wrong prediction,then old address will be assigned
	:                      pc_update3 ? pc_update_add3// if jal operation ,then pc_update 3 will occur
	:                      pc_update2 ? pc_update_add2//in case of not taken condition,the pc goes to next instruction
	:                                   pc_update_add1 ;//if prediction is correct predicted address will be updated
	
	//------------------------------------- Branch Table Update
	
	wire [1:0] count = (branch_ntake & bht_count2>0) ? (bht_count2-1)//branch not taken and state lies in weakly taken or strongly taken state ,decrement counter
	:                  (bht_count2<3)                ? (bht_count2+1) //taken and count less than 3{strongly taken condition,then increment}
	:                                                   bht_count2 ;//else stay in the current state(strongly taken)
	
	assign wen2 = branch_ntake | branch_take | buff_ex_jal ;//write enable become 1 in thee conditions
	
	assign wdata2 = { count, buff_ex_jb_add } ;//final output of branc prediction will be stored in wdata2
	
	// assign pinst = pause ? 0 : pc_update2 ;
	
endmodule
