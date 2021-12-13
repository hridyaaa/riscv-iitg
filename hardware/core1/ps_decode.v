module ps_decode(
	input clk      ,
	input reset    ,
	input clear_de ,
	input clear_ex ,
//---------------------------------------------- Inputs
	input pinst,
	input [31:0] pc,
    input [31:0] instruction,
	input vinst,
	//------------------------------ Register bank
	input        wrd_en1   ,
	input [4:0]  wrd_add1  ,
	input [31:0] wrd_data1 ,
	input        wrd_en2   ,
	input [4:0]  wrd_add2  ,
	input [31:0] wrd_data2 ,
	
//---------------------------------------------- Output Signals
	
	output        branch  ,
	
	// output        jal     ,
	// output [31:0] jal_add ,
	
	output [31:0] rs1     ,
	output [31:0] rs2     ,
	output [31:0] data3   ,
	output [ 2:0] r_wait  ,
	output [ 5:0] r_tag   ,
	output [14:0] r_add   ,
	
	output [12:0] control,
	output [ 3:0] control2,
	output [ 7:0] fn
);

	wire        vout   = ( instruction != 0 );
	wire [31:0] pc_out = pc;
	
	wire [6:0] opcode = instruction[6:0]   ;
	wire [2:0] fun3   = instruction[14:12] ;
	wire [6:0] fun7   = instruction[31:25] ;

//-------------------------------------------------------------------------------------------------------//
//                                          Register control                                             //
//-------------------------------------------------------------------------------------------------------//
	wire clear_de1 = clear_de | clear_ex ;

	wire rs1_en = !clear_de1 & vinst & ( opcode==7'b1100111|opcode==7'b1100011|opcode==7'b0000011
	|                opcode==7'b0100011|opcode==7'b0010011|opcode==7'b0110011
	|              ( opcode==7'b1110011&(fun3==3'b001|fun3==3'b010|fun3==3'b011)) 
	|                opcode==7'b0001011 );	
	
	wire rs2_en = !clear_de1 & vinst & ( opcode==7'b1100011|opcode==7'b0100011|opcode==7'b0110011 | (opcode==7'b0001011 & fun7!=7'b0000010) );
	
	// wire rd_en = ( opcode==7'b0110111|opcode==7'b0010111|opcode==7'b1101111|opcode==7'b1100111
	// |                   opcode==7'b0000011|opcode==7'b0010011|opcode==7'b0110011|opcode==7'b1110011 );
	
	wire [4:0] rs1_add = instruction[19:15];
	wire [4:0] rs2_add = instruction[24:20];
	wire [4:0] rd_add  = instruction[11:7];

	// CSR signals
	wire [11:0] csr_imm = instruction[31:20];
	wire [ 4:0] csr_add = instruction[19:15];
	
//-------------------------------------------------------------------------------------------------------//
//                                            RV32I Decode                                               //
//-------------------------------------------------------------------------------------------------------//
	wire        rd_en_i     ;
	wire        rd_en_l     ;
	wire [2:0]  mem_wen     ;
	wire [2:0]  mem_ren     ;
	wire        i_branch    ;
	wire        jal         ;
	wire [31:0] jal_add     ;
	wire        lui         ;
	wire        jalr        ;
	wire        umload      ;
	wire [31:0] var1        ;
	wire [31:0] var2        ;
	wire        var2rs1     ;
	wire        var2rs2     ;
	wire [3:0]  control_csr ;
	wire [7:0]  control_alu ;
	
	rv32i  decode_rv32i ( 
	   .instruction     ( instruction   ),
	   .pc              ( pc            ),
	   .rd_en_i         ( rd_en_i       ),
	   .rd_en_l         ( rd_en_l       ),
	   .mem_wen         ( mem_wen       ),
	   .mem_ren         ( mem_ren       ),
	   .branch          ( i_branch      ),
	   .jal             ( jal           ),
	   .jal_add         ( jal_add       ),
	   .lui             ( lui           ),
	   .jalr            ( jalr          ),
	   .umload          ( umload        ),
	   
	   .var1            ( var1          ),
	   .var2            ( var2          ),
	   
	   .var2rs1         ( var2rs1       ),
	   .var2rs2         ( var2rs2       ),
	   
	   .control_csr     ( control_csr   ),
	   .control_alu     ( control_alu   )
	);

// //-------------------------------------------------------------------------------------------------------//
// //                                            MAC Decode                                               //
// //-------------------------------------------------------------------------------------------------------//
	// wire rd_en_mac = !clear_de1 & (opcode==7'b0001011) & (rd_add!=5'b00000);
	// wire mac_int   = !clear_de1 & (opcode==7'b0001011 & fun3==3'b000 & fun7==7'b0000001) ;
	// wire mac_en    = !clear_de1 & (opcode==7'b0001011 & fun3==3'b001 & fun7==7'b0000001) ;
	
	// wire [7:0] control_mac = mac_int ? 31 
	// :                        mac_en  ? 32 
	// :                                   0 ;
	
//-------------------------------------------------------------------------------------------------------//
//                                              MUL DIV   
//-------------------------------------------------------------------------------------------------------//
	wire mac_init ;
	wire rs1_sign ;
	wire rs2_sign ;
	wire rd_en_m  ;
	
	wire [7:0] control_md ;
	
	rv32m  inst_rv32m (
	   .instruction ( instruction ),
	   .mac_init    ( mac_init    ),
	   .rs1_sign    ( rs1_sign    ),
	   .rs2_sign    ( rs2_sign    ),
	   .rd_en       ( rd_en_m     ),
	   .control_md  ( control_md  )
	);
	
	wire rd_en = !clear_de1 & vinst & ( rd_en_i | rd_en_l | rd_en_m ) ;
	
//-------------------------------------------------------------------------------------//
//                                  Register Bank                                      //
//-------------------------------------------------------------------------------------//
	
	wire        rs1_wait ;
	wire        rs2_wait ;
	wire        rd_wait  ;
	wire [1:0]  rs1_tag  ;
	wire [1:0]  rs2_tag  ;
	wire [1:0]  rd_tag   ;
	
	wire [31:0] rb_rs1;
	wire [31:0] rb_rs2;
	
	reg_bank  RB (
	   .clk        ( clk   ),
	   .reset      ( reset ),
	   .clear_de   ( clear_ex ),
	   //---------------------------- Write channel
	   .wrd_en1    ( wrd_en1    ),
	   .wrd_add1   ( wrd_add1   ),
	   .wrd_data1  ( wrd_data1  ),
	   .wrd_en2    ( wrd_en2    ),
	   .wrd_add2   ( wrd_add2   ),
	   .wrd_data2  ( wrd_data2  ),
	   //---------------------------- Read channel
	   .rs1_add    ( rs1_add    ),
	   .rs1_en     ( rs1_en     ),
	   .rs2_add    ( rs2_add    ),
	   .rs2_en     ( rs2_en     ),
	   .rd_add     ( rd_add     ),
	   .rd_en      ( rd_en      ),
	   //---------------------------- output data
	   .rs1_data   ( rb_rs1     ),
	   .rs2_data   ( rb_rs2     ),
	   .rs1_wait   ( rs1_wait   ),
	   .rs2_wait   ( rs2_wait   ),
	   .rd_wait    ( rd_wait    ),
	   .rs1_tag    ( rs1_tag    ),
	   .rs2_tag    ( rs2_tag    ),
	   .rd_tag     ( rd_tag     )
	);
//-------------------------------------------------------------------------------------------------------//
//                                            Outputs
//-------------------------------------------------------------------------------------------------------//
	
	wire pfalse = vinst & pinst & !i_branch & !jalr & !jal ;
	wire rd_en_0clk = rd_en_i ;
	
	// wire jal = vinst & i_jal ;
	
	// assign jal_add = i_jal ? i_jal_add
	// :                        pc+4 ; 
	
	assign branch = vinst & i_branch ;
	
	assign rs1 = var2rs1 ? var1 
	:                      rb_rs1 ;
	
	assign rs2 = var2rs2      ? var2 
	:                           rb_rs2 ;
	
	assign data3 = ( control_csr != 0 ) ? { 15'd0, csr_imm, csr_add }
	:                                     var2;
	
	assign r_wait = vinst ? { rd_wait, rs2_wait, rs1_wait } : 0 ;
	
	assign r_tag  = { rd_tag,  rs2_tag,  rs1_tag  } ;
	assign r_add  = { rd_add,  rs2_add,  rs1_add  } ;
	
	assign fn = vinst ? ( control_alu | control_md ) : 0 ;
	
	assign control2 = vinst ? { 1'b0, mac_init, rs1_sign, rs2_sign } : 0 ;
	
	assign control = vinst ? { pfalse, jal, rd_en, umload, jalr, rd_en_0clk, mem_ren[2:0], mem_wen[2:0], vout } : 0 ;
	
	
endmodule

