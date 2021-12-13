module ps_execute(
		input clk,
		input reset,
		input pause,
		input dbp_clear_ex,
		
		input [31:0] pc      ,
		input        branch  ,
		input [31:0] rs1     ,
		input [31:0] rs2     ,
		input [31:0] data3   ,
		input [ 1:0] rd_tag  ,
		input [ 4:0] rd_add  ,
		input [12:0] control ,
		input [ 3:0] control2,
		input [ 7:0] fn      ,
		
		// input [ 4:0] fps_controller,
		// input [31:0] fps_rs1       ,
		// input [31:0] fps_rs2       ,
		// input [ 2:0] fps_r_wait    ,
		// input [ 1:0] fps_rd_tag    ,
		// input [04:0] fps_rd_add    ,
    //----------------------------------------- output signals
		output        ex_branch   ,
		output        ex_jalr     ,
		output [31:0] ex_jalr_add ,
		
		output [2:0]  ex_mem_ren    ,
		output [31:0] ex_mem_radd   ,
		output [6:0]  ex_mem_rd_add ,
		output [2:0]  ex_mem_wen    ,
		output [31:0] ex_mem_wadd   ,
		output [31:0] ex_mem_wdata  ,
	//----------------------------------------- outputs for next stage
		output        ex_rd_en   ,
		output [6:0]  ex_rd_add  ,
		output [31:0] ex_rd_data ,
        
        output        md_rd_en   ,
        output [6:0]  md_rd_add  ,
		output [31:0] md_rd_data ,
        
        // output        fps_ex_rd_en   ,
        // output [6:0]  fps_ex_rd_add  ,
		// output [31:0] fps_ex_rd_data ,
	//----------------------------------------- pause signal
		output        ex_pause
    );
	
	wire        vin         ;
	wire [2:0]  mem_wen     ;
	wire [2:0]  mem_ren     ;
	wire [3:0]  control_csr ;
	wire        jalr        ;
	wire        rd_en_i     ;
	
	assign { jalr, rd_en_i }    = control[8:7] ;
	assign { mem_ren, mem_wen } = control[6:1] ;
	assign { vin }              = control[0]   ;
	
	wire [6:0] rd_add_tag = { rd_tag, rd_add };
	
//-------------------------------------------------------------------------------------//
//                                         CSR
//-------------------------------------------------------------------------------------//
	
	wire [11:0] csr_imm = data3[16:5] ;
	wire [4:0]  csr_add = data3[ 4:0] ; 
	
	wire csr_i  = ( fn == 8'h12 ) ;
	wire csr_rw = ( fn == 8'h13 ) ;
	wire csr_rs = ( fn == 8'h14 ) ;
	wire csr_rc = ( fn == 8'h15 ) ;
	
	wire [31:0] csr_wdata   = ( csr_i ) ? { 27'd0, csr_add } : rs1  ;
	
	wire [31:0] csr_rdata;
	wire        csr_vrdata;
	
	CSR  inst_csr (
	   .clk            ( clk        ),
	   .reset          ( reset      ),
	   .ins_counter_up ( vin        ),
	   .imm            ( csr_imm    ),
	   .rdata          ( csr_rdata  ),
	   .vrdata         ( csr_vrdata ),
	   .wdata          ( csr_wdata  ),
	   .rw             ( csr_rw     ),
	   .rs             ( csr_rs     ),
	   .rc             ( csr_rc     )
	);
	
//-------------------------------------------------------------------------------------//
//                                       ALU
//-------------------------------------------------------------------------------------//
	wire [31:0] alu_in1 = rs1 ;
	wire [31:0] alu_in2 = rs2 ;
	
	// wire [3:0]  control_alu = ( fn[7:4] == 4'd0 ) ? fn[3:0] : 4'd0 ;
	wire [7:0]  control_alu = fn[7:0] ;

	wire [31:0] alu_out;
	
	ALU inst_ALU(
        .clk     ( clk         ),
        .reset   ( reset       ),
        .pause   ( pause       ),
        .din1    ( alu_in1     ),
		.din2    ( alu_in2     ),
        .control ( control_alu ), 
		.dout    ( alu_out     )
    );

//-------------------------------------------------------------------------------------//
//                                      MUL-DIV
//-------------------------------------------------------------------------------------//
    
	wire [7:0] fn_md = dbp_clear_ex ? 0 : fn ;
	
	wire md_pause_next;
	wire [31:0] wire_md_rd_data;
    wire [6:0]  wire_md_rd_add ;
    wire        wire_md_vrd    ;
	
	mul_div  inst_mul_div (
	   .clk        ( clk           ),
	   .reset      ( reset         ),
	   .pause      ( pause         ),
	   .rs1        ( rs1           ),
	   .rs2        ( rs2           ),
	   .in_rd_add  ( rd_add_tag    ),
	   .fn         ( fn_md         ),
	   .control2   ( control2[2:0] ),
	   // output
	   .rd_en      ( wire_md_vrd     ),
	   .rd_add     ( wire_md_rd_add  ),
	   .rd_data    ( wire_md_rd_data ),
	   .md_pause_next ( md_pause_next   )
	);
	
	assign md_rd_en   = wire_md_vrd     ;
	assign md_rd_add  = wire_md_rd_add  ;
	assign md_rd_data = wire_md_rd_data ;
	
//-------------------------------------------------------------------------------------//
//                                      output
//-------------------------------------------------------------------------------------//
	
	wire [31:0] next_pc = pc + 4;
	
	wire lui = ( fn == 8'h0f ) ;
	wire jal = ( fn == 8'h10 ) ;
	
	wire [31:0] ex_rd_data1 = ( jalr | jal ) ? next_pc
	:                         ( lui        ) ? data3 
	:                         ( csr_vrdata ) ? csr_rdata 
	:                                          alu_out ;

	wire branch_correct = branch & !dbp_clear_ex ;
	
	wire pfalse = control[12] ;
	
	assign ex_jalr     = !dbp_clear_ex & jalr ;
	assign ex_branch   = branch_correct & alu_out[0] ;
	assign ex_jalr_add = jalr      ? { alu_out[31:1], 1'b0 } 
	:                    ex_branch ? data3 
	:                    branch    ? next_pc
	:                    pfalse    ? next_pc
	:                                data3 ;
	
	wire [31:0] adder_dout = rs1 + data3 ;
	
	assign ex_mem_ren    = dbp_clear_ex ? 0 : mem_ren ;
	assign ex_mem_radd   = adder_dout ;
	assign ex_mem_rd_add = rd_add_tag ;
	assign ex_mem_wen    = dbp_clear_ex ? 0 : mem_wen ;
	assign ex_mem_wadd   = adder_dout ;
	assign ex_mem_wdata  = (mem_wen==1) ?  {rs2[7:0],rs2[7:0],rs2[7:0],rs2[7:0]}
	:                      (mem_wen==2) ?  {rs2[15:0],rs2[15:0]}
	:                                      rs2    ; 
	
	assign ex_rd_en   = rd_en_i ;
	assign ex_rd_add  = rd_add_tag  ;
	assign ex_rd_data = ex_rd_data1 ;
	
	// wire fps_pnc;
	// fps_execution  inst_fps_execution (
	   // .clk            ( clk            ),
	   // .reset          ( reset          ),
	   // .fps_controller ( fps_controller ),
	   // .fps_rs1        ( fps_rs1        ),
	   // .fps_rs2        ( fps_rs2        ),
	   // .fps_r_wait     ( fps_r_wait     ),
	   // .fps_rd_tag     ( fps_rd_tag     ),
	   // .fps_rd_add     ( fps_rd_add     ),
	   
	   // .fps_ex_rd_data ( fps_ex_rd_data ),
	   // .fps_ex_rd_add  ( fps_ex_rd_add  ),
	   // .fps_ex_rd_en   ( fps_ex_rd_en   ),
	   // .fps_pnc        ( fps_pnc        ) 
	// );
	
	
//-------------------------------------------------------------------------------------//
//                                      Pause
//-------------------------------------------------------------------------------------//
	// reg reg_ex_pause; always@(posedge clk) if (reset) reg_ex_pause <= 0; else reg_ex_pause <= (fps_pnc | md_pause_next) ;
	reg reg_ex_pause; always@(posedge clk) if (reset) reg_ex_pause <= 0; else reg_ex_pause <= md_pause_next ;
	assign ex_pause = reg_ex_pause ;
	
endmodule
