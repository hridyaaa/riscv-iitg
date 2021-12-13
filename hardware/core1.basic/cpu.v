module cpu#(
	parameter AWIDTH_DBP=10,
	parameter DWIDTH_DBP=34
)(
    input clk,
	input reset,
	
	output [31:0] add1  ,
	input  [31:0] rdata1,
	output [ 3:0] wen1  ,
	output [31:0] wdata1,
	output [31:0] add2  ,
	input  [31:0] rdata2,
	output [ 3:0] wen2  ,
	output [31:0] wdata2,
	
	output [AWIDTH_DBP-1:0] dbp_add1  ,
	input  [DWIDTH_DBP-1:0] dbp_rdata1,
	output [AWIDTH_DBP-1:0] dbp_add2  ,
	input  [DWIDTH_DBP-1:0] dbp_rdata2,
	output                  dbp_wen2  ,
	output [DWIDTH_DBP-1:0] dbp_wdata2
);
	
//-----------------------------------------------------------------------------------------------//
//                                       Memory Controller                                       //
//-----------------------------------------------------------------------------------------------//

	wire        inst_rready;
	wire        inst_req   ;
	wire [31:0] inst_add   ;
	wire [31:0] inst       ;
	wire        vinst      ;
	wire        mm_pause   ;
	
	wire        mem_umload2;
	wire [6:0]  mem_rd_add2;
	
	wire [2:0]  mem_ren2   ;
	wire [31:0] mem_radd2  ;
	
	wire [2:0]  mem_wen2   ;
	wire [31:0] mem_wadd2  ;
	wire [31:0] mem_wdata2 ;
	
	wire        mem_rd_en  ;
	wire [6:0]  mem_rd_add ;
	wire [31:0] mem_rd_data;
	
	
	memory_controller  inst_memory_controller (
	   .clk         ( clk         ),
	   .reset       ( reset       ),
	   .inst_rready ( inst_rready ),
	   //------------------------------------------ Channel 1
	   .ren1        ( inst_req    ),
	   .radd1       ( inst_add    ),
	   .rdata1      ( inst        ),
	   .vrdata1     ( vinst       ),
	   //------------------------------------------ Channel 2
	   .umload      ( mem_umload2 ),
	   .rd_add2     ( mem_rd_add2 ),
	   
	   .ren2        ( mem_ren2    ),
	   .radd2       ( mem_radd2   ),
	   .wen2        ( mem_wen2    ),
	   .wadd2       ( mem_wadd2   ),
	   .wdata2      ( mem_wdata2  ),
	   
	   .rd_en       ( mem_rd_en   ),
	   .rd_add      ( mem_rd_add  ),
	   .rd_data     ( mem_rd_data ),
	   //------------------------------------------ Memory I/O Signals
	   .mem_add1    ( add1   ),
	   .mem_rdata1  ( rdata1 ),
	   .mem_wen1    ( wen1   ),
	   .mem_wdata1  ( wdata1 ),
	   .mem_add2    ( add2   ),
	   .mem_rdata2  ( rdata2 ),
	   .mem_wen2    ( wen2   ),
	   .mem_wdata2  ( wdata2 ),
	   
	   .mm_pause    ( mm_pause )
	);
	
//-----------------------------------------------------------------------------------------------//
//                                        Program Counter                                        //
//-----------------------------------------------------------------------------------------------//

	wire reset_pc ;
	wire pause_pc ;
	
	wire        de_pfalse  ;
	wire [31:0] pc_pc      ;
	wire [31:0] buff_pc_pc ;
	
	wire        jal     ;
	wire [31:0] jal_add ;
	
	wire [31:0] buff_dd_pc ;
	
	wire        buff_ex_jal    ;
	wire        buff_ex_jb     ;
	wire        buff_ex_jb_en  ;
	wire [31:0] buff_ex_jb_add ;
	wire [31:0] buff_pc_dbp    ;
	
	wire        pc_update1    ;
	wire        pc_update2    ;
	wire        pc_update3    ;
	wire        pc_update4    ;
	wire [31:0] pc_update_add ;
	
	DBP #(
	   .AWIDTH ( AWIDTH_DBP ),
	   .DWIDTH ( DWIDTH_DBP )
	) inst_DBP (
	   .clk           ( clk      ),
	   .reset         ( reset    ),
	   .clear_dbp     ( reset_pc ),
	   .pause         ( pause_pc ),
	   
	   .inst_req      ( inst_req ),
	   .inst_add      ( inst_add ),
	   
	   .de_pfalse     ( de_pfalse  ),
	   .pc_pc         ( pc_pc      ),
	   .buff_pc_pc    ( buff_pc_pc ),
	   
	   .jal           ( jal     ),
	   .jal_add       ( jal_add ),
	   
	   .buff_dd_pc    ( buff_dd_pc ),
	   
	   .buff_ex_jal    ( buff_ex_jal    ),
	   .buff_ex_jb     ( buff_ex_jb     ),
	   .buff_ex_jb_en  ( buff_ex_jb_en  ),
	   .buff_ex_jb_add ( buff_ex_jb_add ),
	   .buff_ex_pc     ( buff_pc_dbp    ),
	   
	   
	   .add1   ( dbp_add1   ),
	   .rdata1 ( dbp_rdata1 ),
	   .add2   ( dbp_add2   ),
	   .rdata2 ( dbp_rdata2 ),
	   .wen2   ( dbp_wen2   ),
	   .wdata2 ( dbp_wdata2 ),
	   
	   .pc_update1     ( pc_update1    ),
	   .pc_update2     ( pc_update2    ),
	   .pc_update3     ( pc_update3    ),
	   .pc_update4     ( pc_update4    ),
	   .pc_update_add  ( pc_update_add )
	);
	
	wire        pc_pinst ;
	// wire [31:0] pc_pc    ;
	wire [31:0] pc_inst  ;
	wire        pc_vout  ;

	prog_counter  PC (
	   .clk           ( clk      ),
	   .reset         ( reset    ),
	   .pause         ( pause_pc ),
	   
	   .pc_update1    ( pc_update1    ),
	   .pc_update2    ( pc_update2    ),
	   .pc_update3    ( pc_update3    ),
	   .pc_update4    ( pc_update4    ),
	   .pc_update_add ( pc_update_add ),
	//----------------------------------- Input signals
	   .inst_rready   ( inst_rready ),
	   .req           ( inst_req    ),
	   .inst_add      ( inst_add    ),
	   .vinst         ( vinst       ),
	   .inst          ( inst        ),
	//------------------------------------- Output signals
	   .pc_pinst      ( pc_pinst ),
	   .pc            ( pc_pc    ),
	   .inst_out      ( pc_inst  ),
	   .vinst_out     ( pc_vout  )
	);
	
	wire        buff_pc_pinst ;
	// wire [31:0] buff_pc_pc    ;
	wire [31:0] buff_pc_inst  ;
	wire        buff_pc_vout  ;
	
	localparam pc_WIDTH1 = 1+32+32 ;
	localparam pc_WIDTH2 = 1 ;
	
	buffer #(
	   .WIDTH1 ( pc_WIDTH1 ),
	   .WIDTH2 ( pc_WIDTH2 )
	)  buffer_pc (
	    .clk   ( clk      ),
	    .reset ( reset_pc ),
	    .pause ( pause_pc ),
	//-------------------------------------------------------------------------------
		.din1 ( {pc_pinst, pc_pc, pc_inst} ),
		.din2 ( {pc_vout} ),
	//-------------------------------------------------------------------------------
		.dout1 ( {buff_pc_pinst, buff_pc_pc, buff_pc_inst } ),
		.dout2 ( {buff_pc_vout} )
	);
	
//-----------------------------------------------------------------------------------------------//
//                            1st Stage : Instruction Decode	                                 //
//-----------------------------------------------------------------------------------------------//
	
	wire        wrd_en1   ;
	wire [6:0]  wrd_add1  ;
	wire [31:0] wrd_data1 ;
	wire        wrd_en2   ;
	wire [6:0]  wrd_add2  ;
	wire [31:0] wrd_data2 ;
	
	wire [31:0] de_rs1    ;
	wire [31:0] de_rs2    ;
	wire [31:0] de_data3  ;
	wire [ 2:0] de_r_wait ;
	wire [ 5:0] de_r_tag  ;
	wire [14:0] de_r_add  ;
	
	wire        de_branch   ;
	wire [12:0] de_control  ;
	wire [ 3:0] de_control2 ;
	wire [ 7:0] de_fn       ;
	
	wire clear_de;
	wire clear_ex;
	
	ps_decode  ID (
	   .clk         ( clk         ),
	   .reset       ( reset       ),
	   .clear_de    ( clear_de    ),
	   .clear_ex    ( clear_ex    ),
	//------------------------------------------- inputs
	   .pinst       ( buff_pc_pinst ),
	   .pc          ( buff_pc_pc    ),
	   .instruction ( buff_pc_inst  ),
	   .vinst       ( buff_pc_vout  ),
	    
	   .wrd_en1     ( wrd_en1       ),
	   .wrd_add1    ( wrd_add1[4:0] ),
	   .wrd_data1   ( wrd_data1     ),
	   .wrd_en2     ( wrd_en2       ),
	   .wrd_add2    ( wrd_add2[4:0] ),
	   .wrd_data2   ( wrd_data2     ),
	//------------------------------------------- outputs
	   .rs1         ( de_rs1    ),
	   .rs2         ( de_rs2    ),
	   .data3       ( de_data3  ),
	   .r_wait      ( de_r_wait ),
	   .r_tag       ( de_r_tag  ),
	   .r_add       ( de_r_add  ),
	   
	   .branch      ( de_branch   ),
	   .control     ( de_control  ),
	   .control2    ( de_control2 ),
	   .fn          ( de_fn       )
	);
	
	assign de_pfalse = de_control[12] ;
	
	wire [31:0] buff_de_pc       ;
	wire [31:0] buff_de_data3    ;
	wire        buff_de_branch   ;
	wire [12:0] buff_de_control  ;
	wire [ 3:0] buff_de_control2 ;
	wire [ 7:0] buff_de_fn       ;
	
	wire reset_de ;
	wire pause_de ;
	
	localparam de_WIDTH1 = 32+32 ;
	localparam de_WIDTH2 = 1+8+13+4 ;
	
	buffer #(
	   .WIDTH1 ( de_WIDTH1 ),
	   .WIDTH2 ( de_WIDTH2 )
	)  buffer_de (
	    .clk   ( clk      ),
	    .reset ( reset_de ),
	    .pause ( pause_de ),
	//-------------------------------------------------------------------------------
		.din1 ( {buff_pc_pc, de_data3 } ),
		.din2 ( {de_branch, de_fn, de_control, de_control2} ),
	//-------------------------------------------------------------------------------
		.dout1 ( {buff_de_pc, buff_de_data3 } ),
		.dout2 ( {buff_de_branch, buff_de_fn, buff_de_control, buff_de_control2 } )
	);
	
	// wire        fps_wrd_en1   ;
	// wire [6:0]  fps_wrd_add1  ;
	// wire [31:0] fps_wrd_data1 ;
	// wire        fps_wrd_en2 = 1'b0;
	// wire [6:0]  fps_wrd_add2 = 7'd0 ;
	// wire [31:0] fps_wrd_data2 ;
	
	// wire [04:0] fps_rs1_add;
	// wire [04:0] fps_rs2_add;
	// wire [04:0] fps_rd_add;
	// wire [ 4:0] fps_controller ;
	// wire [31:0] fps_rs1        ;
	// wire [31:0] fps_rs2        ;
	// wire [ 2:0] fps_r_wait     ;
	// wire [ 5:0] fps_r_tag      ;
	
	// fp_decode  inst_fp_decode (
	   // .clk            ( clk            ),
	   // .reset          ( reset          ),
	   // .clear_de       ( clear_de       ),
	   // .instruction    ( pc_inst        ),
	   
	   // .wrd_en1        ( fps_wrd_en1    ),
	   // .wrd_add1       ( fps_wrd_add1[4:0]),
	   // .wrd_data1      ( fps_wrd_data1  ),
	   // .wrd_en2        ( 1'b0           ),
	   // .wrd_add2       ( fps_wrd_add2[4:0]),
	   // .wrd_data2      ( fps_wrd_data2  ),
	   
	   // .rs1_add        ( fps_rs1_add    ),
	   // .rs2_add        ( fps_rs2_add    ),
	   // .rd_add         ( fps_rd_add     ),
	   
	   // .fps_controller ( fps_controller ),
	   // .rs1            ( fps_rs1        ),
	   // .rs2            ( fps_rs2        ),
	   // .r_wait         ( fps_r_wait     ),
	   // .r_tag          ( fps_r_tag      )
	// );
	
	// wire        buff_fps_ex_rd_en  ;
	// wire [6:0]  buff_fps_ex_rd_add ;
	// wire [31:0] buff_fps_ex_rd_data;
	
	// wire [04:0] buff_fps_rd_add;
	// wire [ 4:0] buff_fps_de_controller ;
	// wire [31:0] buff_fps_de_rs1     ;
	// wire [31:0] buff_fps_de_rs2     ;
	// wire [ 2:0] buff_fps_de_r_wait  ;
	// wire [ 1:0] buff_fps_de_rd_tag  ;
	
	// wire        buff_fps_de_pause   ;
	
	// wire clear_fps_de ;
	// wire pause_fps_de ;
	
	// fps_buff_de  inst_buff_fps_de (
	    // .clk             ( clk              ),
	    // .reset           ( reset | clear_de ),
	    // .pause           ( pause_fps_de     ),
	    // //---------------------------------------------------
		// .de_rs1_add    ( fps_rs1_add ),
		// .de_rs2_add    ( fps_rs2_add ),
		// .de_rd_add     ( fps_rd_add  ),
		
	    // .de_controller ( fps_controller  ),
	    // .de_rs1        ( fps_rs1         ),
	    // .de_rs2        ( fps_rs2         ),
	    // .de_r_wait     ( fps_r_wait      ),
	    // .de_r_tag      ( fps_r_tag       ),
		
	    // .wrd_en1         ( fps_wrd_en1    ),
	    // .wrd_add1        ( fps_wrd_add1   ),
	    // .wrd_data1       ( fps_wrd_data1  ),
	    // .wrd_en2         ( fps_wrd_en2    ),
	    // .wrd_add2        ( fps_wrd_add2   ),
	    // .wrd_data2       ( fps_wrd_data2  ),
	    // .buff_ex_rd_en   ( fps_wrd_en1    ),
	    // .buff_ex_rd_add  ( fps_wrd_add1   ),
	    // .buff_ex_rd_data ( fps_wrd_data1  ),
	    // //----------------------------------------------------
	    // .buff_rd_add     ( buff_fps_rd_add ),
		
		// .buff_rs1        ( buff_fps_de_rs1         ),
	    // .buff_rs2        ( buff_fps_de_rs2         ),
	    // .buff_r_wait     ( buff_fps_de_r_wait      ),
	    // .buff_rd_tag     ( buff_fps_de_rd_tag      ),
	    // .buff_controller ( buff_fps_de_controller  ),
		
		// .buff_de_pause   ( buff_fps_de_pause    )
	// );
	
//-----------------------------------------------------------------------------------------------//
//                                 2nd Stage : Data Distribute (DD)
//-----------------------------------------------------------------------------------------------//
	
	wire        ex_rd_en  ;
	wire [6:0]  ex_rd_add ;
	wire [31:0] ex_rd_data;
	wire        buff_ex_rd_en  ;
	wire [6:0]  buff_ex_rd_add ;
	wire [31:0] buff_ex_rd_data;
	
	wire [31:0] dd_rs1    ;
	wire [31:0] dd_rs2    ;
	wire [ 1:0] dd_rd_tag ;
	wire [ 4:0] dd_rd_add ;
	
	wire dd_pause ;
	
	data_distribute  inst_dd (
	    .clk        ( clk      ),
	    .reset      ( reset_de ),
	    .pause      ( pause_de ),
    //----------------------------------------- inputs
	    .de_rs1     ( de_rs1    ),
	    .de_rs2     ( de_rs2    ),
	    .de_r_wait  ( de_r_wait ),
	    .de_r_tag   ( de_r_tag  ),
	    .de_r_add   ( de_r_add  ),
		
	    .wrd_en1     ( wrd_en1     ),
	    .wrd_add1    ( wrd_add1    ),
	    .wrd_data1   ( wrd_data1   ),
	    .wrd_en2     ( wrd_en2     ),
	    .wrd_add2    ( wrd_add2    ),
	    .wrd_data2   ( wrd_data2   ),
	    .ex_rd_en    ( ex_rd_en    ),
	    .ex_rd_add   ( ex_rd_add   ),
	    .ex_rd_data  ( ex_rd_data  ),
		.mem_rd_en   ( mem_rd_en   ),
	    .mem_rd_add  ( mem_rd_add  ),
	    .mem_rd_data ( mem_rd_data ),
	    .buff_ex_rd_en   ( buff_ex_rd_en   ),
	    .buff_ex_rd_add  ( buff_ex_rd_add  ),
	    .buff_ex_rd_data ( buff_ex_rd_data ),
    //---------------------------------------------- outputs
	    .dd_rs1     ( dd_rs1    ),
	    .dd_rs2     ( dd_rs2    ),
	    .dd_rd_tag  ( dd_rd_tag ),
	    .dd_rd_add  ( dd_rd_add ),
		
		.dd_pause   ( dd_pause )
	);
	
	
	// wire [31:0] buff_dd_pc      ;
	wire [31:0] buff_dd_rs1     ;
	wire [31:0] buff_dd_rs2     ;
	wire [31:0] buff_dd_data3   ;
	wire [ 1:0] buff_dd_rd_tag  ;
	wire [ 4:0] buff_dd_rd_add  ;
	wire        buff_dd_branch  ;
	wire [12:0] buff_dd_control ;
	wire [ 3:0] buff_dd_control2;
	wire [ 7:0] buff_dd_fn      ;
	
	wire reset_dd ;
	wire pause_dd ;
	
	localparam dd_WIDTH1 = 32+32+32+32+2+5+4 ;
	localparam dd_WIDTH2 = 1+8+13 ;
	
	buffer #(
	   .WIDTH1 ( dd_WIDTH1 ),
	   .WIDTH2 ( dd_WIDTH2 )
	)  buffer_dd (
	   .clk   ( clk      ),
	   .reset ( reset_dd ),
	   .pause ( pause_dd ),
	   
	   .din1  ( {buff_de_pc, dd_rs1, dd_rs2, buff_de_data3, dd_rd_tag, dd_rd_add, buff_de_control2} ),
	   .din2  ( {buff_de_branch, buff_de_fn, buff_de_control} ),
	   
	   .dout1 ( {buff_dd_pc, buff_dd_rs1, buff_dd_rs2, buff_dd_data3, buff_dd_rd_tag, buff_dd_rd_add, buff_dd_control2} ),
	   .dout2 ( {buff_dd_branch, buff_dd_fn, buff_dd_control} )
	);
	
//-----------------------------------------------------------------------------------------------//
//                                 3rd Stage : Instruction Execute                               //
//-----------------------------------------------------------------------------------------------//

	wire        ex_branch      ;
	wire        ex_jalr        ;
	wire [31:0] ex_jalr_add    ;
	
	wire [2:0]  ex_mem_ren    ;
	wire [31:0] ex_mem_radd   ;
	wire [6:0]  ex_mem_rd_add ;
	wire [2:0]  ex_mem_wen    ;
	wire [31:0] ex_mem_wadd   ;
	wire [31:0] ex_mem_wdata  ;
	
	// wire        ex_rd_en      ;
	// wire [6:0]  ex_rd_add     ;
	// wire [31:0] ex_rd_data    ;
	
	wire        md_rd_en      ;
	wire [6:0]  md_rd_add     ;
	wire [31:0] md_rd_data    ;
	
	wire        fps_ex_rd_en   ;
	wire [6:0]  fps_ex_rd_add  ;
	wire [31:0] fps_ex_rd_data ;
	
	// wire clear_ex ;
	wire pause_ex ;
	wire ex_pause ;
	
    ps_execute  IE (
	   .clk             ( clk             ),
	   .reset           ( reset           ),
	   .pause           ( pause_ex        ),
	   .dbp_clear_ex    ( clear_ex        ),
	   //--------------------------------------- inputs
	   .pc              ( buff_dd_pc      ),
	   .rs1             ( buff_dd_rs1     ),
	   .rs2             ( buff_dd_rs2     ),
	   .data3           ( buff_dd_data3   ),
	   .rd_tag          ( buff_dd_rd_tag  ),
	   .rd_add          ( buff_dd_rd_add  ),
	   .branch          ( buff_dd_branch  ),
	   .control         ( buff_dd_control ),
	   .control2        ( buff_dd_control2),
	   .fn              ( buff_dd_fn      ),
	   
	   // .fps_rs1        ( buff_fps_de_rs1        ),
	   // .fps_rs2        ( buff_fps_de_rs2        ),
	   // .fps_r_wait     ( buff_fps_de_r_wait     ),
	   // .fps_rd_tag     ( buff_fps_de_rd_tag     ),
	   // .fps_rd_add     ( buff_fps_rd_add        ),
	   // .fps_controller ( buff_fps_de_controller ),
	   //--------------------------------------- outputs
	   .ex_branch     ( ex_branch       ),
	   .ex_jalr       ( ex_jalr         ),
	   .ex_jalr_add   ( ex_jalr_add     ),
	   
	   .ex_mem_ren    ( ex_mem_ren      ),
	   .ex_mem_radd   ( ex_mem_radd     ),
	   .ex_mem_rd_add ( ex_mem_rd_add   ),
	   .ex_mem_wen    ( ex_mem_wen      ),
	   .ex_mem_wadd   ( ex_mem_wadd     ),
	   .ex_mem_wdata  ( ex_mem_wdata    ),
	   
	   .ex_rd_en      ( ex_rd_en        ),
	   .ex_rd_add     ( ex_rd_add       ),
	   .ex_rd_data    ( ex_rd_data      ),
	   
	   .md_rd_data    ( md_rd_data      ),
	   .md_rd_add     ( md_rd_add       ),
	   .md_rd_en      ( md_rd_en        ),
	   
	   .ex_pause      ( ex_pause        )
	   
	   // .fps_ex_rd_en  ( fps_ex_rd_en   ),
	   // .fps_ex_rd_add ( fps_ex_rd_add  ),
	   // .fps_ex_rd_data( fps_ex_rd_data )
	);
	
	assign mem_umload2 = buff_dd_control[9] ;
	assign mem_rd_add2 = ex_mem_rd_add      ;
	
	assign mem_ren2    = ex_mem_ren   ;
	assign mem_radd2   = ex_mem_radd  ;
	assign mem_wen2    = ex_mem_wen   ;
	assign mem_wadd2   = ex_mem_wadd  ;
	assign mem_wdata2  = ex_mem_wdata ;
	
	// For simulation only
	// assign rd_en_all  = de_rd_en_i | de_rd_en_l | de_rd_en_m ;
	// assign rd_add_all = de_rd_add;
	// assign pc_sim     = buff_de_pc    ;
	
//-----------------------------------------------------------------------------------------------//
//                                     EX buffer
//-----------------------------------------------------------------------------------------------//
	wire ex_jal    = !clear_ex & (buff_dd_control[11] | buff_dd_control[12]) ;
	wire ex_jb     = !clear_ex & (buff_dd_branch | ex_jalr) ;
	wire ex_jb_en  = !clear_ex & (ex_branch      | ex_jalr) ;
	
	wire [31:0] ex_jb_add = ex_jalr_add ;
	wire [31:0] ex_pc     = buff_dd_pc  ;
	
	wire ex_rd_en_bex = clear_ex ? 0 : ex_rd_en ;
	
	// wire        pause_ex       ;
	wire [31:0] buff_ex_pc ;
	
	// wire        buff_ex_rd_en  ;
	// wire [4:0]  buff_ex_rd_add ;
	// wire [31:0] buff_ex_rd_data;
	wire        buff_md_rd_en  ;
	wire [6:0]  buff_md_rd_add ;
	wire [31:0] buff_md_rd_data;
	
	// wire        buff_fps_ex_rd_en  ;
	// wire [6:0]  buff_fps_ex_rd_add ;
	// wire [31:0] buff_fps_ex_rd_data;
	
	localparam ex_WIDTH1 = 32+32+7+32+7+32 ;
	localparam ex_WIDTH2 = 1+1+1+1+1 ;
	
	buffer #(
	   .WIDTH1 ( ex_WIDTH1 ),
	   .WIDTH2 ( ex_WIDTH2 )
	)  buffer_ex (
	    .clk   ( clk      ),
	    .reset ( reset    ),
	    .pause ( pause_ex ),
	//-------------------------------------------------------------------------------
		.din1 ( {ex_jb_add, ex_pc, ex_rd_add, ex_rd_data, md_rd_add, md_rd_data} ),
		.din2 ( {ex_jal, ex_jb, ex_jb_en, ex_rd_en_bex, md_rd_en} ),
	//-------------------------------------------------------------------------------
		.dout1 ( {buff_ex_jb_add, buff_ex_pc, buff_ex_rd_add, buff_ex_rd_data, buff_md_rd_add, buff_md_rd_data} ),
		.dout2 ( {buff_ex_jal, buff_ex_jb, buff_ex_jb_en, buff_ex_rd_en, buff_md_rd_en} )
	);
	
//-----------------------------------------------------------------------------------------------//
//                                     4th Stage : Register Write
//-----------------------------------------------------------------------------------------------//
	wire        oc_rd_en1   ;
	wire [6:0]  oc_rd_add1  ;
	wire [31:0] oc_rd_data1 ;
	wire        oc_rd_en2   ;
	wire [6:0]  oc_rd_add2  ;
	wire [31:0] oc_rd_data2 ;
	
	wire        oc_pause    ;
	
	reg_write  RW (
	   .clk        ( clk   ),
	   .reset      ( reset ),
	//---------------------------------------------- Inputs
	   .rd_en1    ( buff_ex_rd_en   ),
	   .rd_add1   ( buff_ex_rd_add  ),
	   .rd_data1  ( buff_ex_rd_data ),
	   
	   .rd_en2    ( mem_rd_en   ),
	   .rd_add2   ( mem_rd_add  ),
	   .rd_data2  ( mem_rd_data ),
	   
	   .rd_en3    ( buff_md_rd_en   ),
	   .rd_add3   ( buff_md_rd_add  ),
	   .rd_data3  ( buff_md_rd_data ),
	   
	//---------------------------------------------- Outputs
	   .wrd_en1   ( oc_rd_en1   ),
	   .wrd_add1  ( oc_rd_add1  ),
	   .wrd_data1 ( oc_rd_data1 ),
	    
	   .wrd_en2   ( oc_rd_en2   ),
	   .wrd_add2  ( oc_rd_add2  ),
	   .wrd_data2 ( oc_rd_data2 ),
	   
	//---------------------------------------------- Pause if two reg write signals
	   .oc_pause  ( oc_pause    )
	);
	
//-----------------------------------------------------------------------------------------------//
//                                     OC buffer
//-----------------------------------------------------------------------------------------------//
	
	wire        pause_oc       ;
	wire        buff_oc_rd_en1  ;
	wire [6:0]  buff_oc_rd_add1 ;
	wire [31:0] buff_oc_rd_data1;
	wire        buff_oc_rd_en2  ;
	wire [6:0]  buff_oc_rd_add2 ;
	wire [31:0] buff_oc_rd_data2;
	
	localparam OC_WIDTH1 = 7+32+7+32 ;
	localparam OC_WIDTH2 = 1+1 ;
	
	buffer #(
	   .WIDTH1 ( OC_WIDTH1 ),
	   .WIDTH2 ( OC_WIDTH2 )
	)  buffer_oc (
	    .clk   ( clk      ),
	    .reset ( reset    ),
	    .pause ( pause_oc ),
	//-------------------------------------------------------------------------------
		.din1 ( {oc_rd_add1,oc_rd_data1,oc_rd_add2,oc_rd_data2} ),
		.din2 ( {oc_rd_en1,oc_rd_en2} ),
	//-------------------------------------------------------------------------------
		.dout1 ( {buff_oc_rd_add1,buff_oc_rd_data1,buff_oc_rd_add2,buff_oc_rd_data2} ),
		.dout2 ( {buff_oc_rd_en1,buff_oc_rd_en2} )
	);
	
//---------------------------------------------------------------------------------//
	
	assign wrd_en1   = buff_oc_rd_en1   ;
	assign wrd_add1  = buff_oc_rd_add1  ;
	assign wrd_data1 = buff_oc_rd_data1 ;
	assign wrd_en2   = buff_oc_rd_en2   ;
	assign wrd_add2  = buff_oc_rd_add2  ;
	assign wrd_data2 = buff_oc_rd_data2 ;
	
	assign clear_de = pc_update3 ;
	assign clear_ex = pc_update4 ;
	
	assign reset_pc = reset | pc_update2 | pc_update3 | pc_update4 ;
	assign reset_de = reset | pc_update3 | pc_update4 ;
	assign reset_dd = reset | pc_update4 ;
	
	assign pause_pc = oc_pause | ex_pause | dd_pause | mm_pause ;
	assign pause_de = oc_pause | ex_pause | dd_pause | mm_pause ;
	assign pause_dd = oc_pause | ex_pause | mm_pause ;
	// assign pause_pc = oc_pause | ex_pause | buff_de_pause | buff_fps_de_pause ;
	// assign pause_de = oc_pause | ex_pause | buff_de_pause | buff_fps_de_pause ;
	assign pause_ex = oc_pause | mm_pause ;
	assign pause_oc = 1'b0 ;
	
	assign buff_pc_dbp = buff_ex_pc ;
	
	// assign pause_fps_de = pause_de ;
	
	assign jal     = buff_de_control[11] ;
	assign jal_add = buff_de_data3 ;

// ---------------		Reg Status Write (Simulation Only)	-------------------- //
	
	// wire        sim_rd_en  = ( clear_ex ) ? 0 : ( buff_dd_control[10] ) ;
	// wire [6:0]  sim_rd_add = { buff_dd_rd_tag, buff_dd_rd_add } ;
	// wire [31:0] sim_pc     = buff_dd_pc ;
	
	// reg_fwrite  inst_reg_fwrite (
	   // .clk        ( clk        ),
	   // .reset      ( reset      ),
	   
	   // .rd_en      ( sim_rd_en  ),
	   // .rd_add     ( sim_rd_add ),
	   // .pc         ( sim_pc     ),
	   // .mem_ren    ( mem_ren2   ),
	   // .mem_radd   ( mem_radd2  ),
	   // .mem_wen    ( mem_wen2   ),
	   // .mem_wadd   ( mem_wadd2  ),
	   // .mem_wdata  ( mem_wdata2 ),
	   
	   // .wrd_en1    ( wrd_en1   ),
	   // .wrd_add1   ( wrd_add1  ),
	   // .wrd_data1  ( wrd_data1 ),
	   // .wrd_en2    ( wrd_en2   ),
	   // .wrd_add2   ( wrd_add2  ),
	   // .wrd_data2  ( wrd_data2 )
	// );
	
endmodule

