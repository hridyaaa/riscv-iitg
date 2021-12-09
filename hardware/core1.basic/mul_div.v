module mul_div (
	input clk,
	input reset,
	input pause,
	input [31:0] rs1,
	input [31:0] rs2,
	input [6:0]  in_rd_add,
	input [7:0]  fn,
	input [2:0]  control2,
// output signals
	output        rd_en,
	output [ 6:0] rd_add,
	output [31:0] rd_data,
	
	output        md_pause_next
);
	
	wire mac_init, rs1_sign, rs2_sign ;

	assign { mac_init, rs1_sign, rs2_sign } = control2 ;

//-------------------------------------------------------------------------------------//
//                                      MAC
//-------------------------------------------------------------------------------------//
	
	wire mac_low  = ( fn == 8'h1c ) ;
	wire mac_high = ( fn == 8'h1D ) ;
	
	wire mac_en = mac_high | mac_low ;
	
	wire [32:0] mac_din1 = rs1_sign ? {rs1[31],rs1} : {1'b0,rs1};
	wire [32:0] mac_din2 = rs2_sign ? {rs2[31],rs2} : {1'b0,rs2};
	
	wire [31:0] mac_dlout;
	wire [31:0] mac_dhout;
	wire mac_vldout;
	wire mac_vhdout;
	
	mac inst_mac (
	   .clk    ( clk       ),
	   .reset  ( reset     ),
	   .pause  ( pause     ),
	   .mul_en ( mac_init  ),
	   .mac_low  ( mac_low  ),
	   .mac_high ( mac_high ),
	   .din1   ( mac_din1  ),
	   .din2   ( mac_din2  ),
	   .dlout  ( mac_dlout  ),
	   .dhout  ( mac_dhout  ),
	   .vldout ( mac_vldout ),
	   .vhdout ( mac_vhdout )
	);
	
    reg [6:0] reg_mac_rd_add1; always@(posedge clk) if (reset) reg_mac_rd_add1 <= 0; else if (!pause) reg_mac_rd_add1 <= in_rd_add ;
    reg [6:0] reg_mac_rd_add2; always@(posedge clk) if (reset) reg_mac_rd_add2 <= 0; else if (!pause) reg_mac_rd_add2 <= reg_mac_rd_add1 ;
	
	wire        macl_rd_en   = pause ? 0 : mac_vldout ;
	wire [ 6:0] macl_rd_add  = reg_mac_rd_add1 ;
	wire [31:0] macl_rd_data = mac_dlout ;
	
	wire        mach_rd_en   = pause ? 0 : mac_vhdout ;
	wire [ 6:0] mach_rd_add  = reg_mac_rd_add2 ;
	wire [31:0] mach_rd_data = mac_dhout ;
	
//-------------------------------------------------------------------------------------//
//                                      Divider
//-------------------------------------------------------------------------------------//
	wire rs1_sign_true = rs1_sign & rs1[31] ;
	wire rs2_sign_true = rs2_sign & rs2[31] ;
	
	wire divr_sign = rs1_sign_true ;
    wire divq_sign = rs1_sign_true ^ rs2_sign_true ;
    
    wire [31:0] mag_rs1 = rs1_sign_true ? (~rs1+1'b1) : rs1 ;
    wire [31:0] mag_rs2 = rs2_sign_true ? (~rs2+1'b1) : rs2 ;
    
    wire divq_en = ( fn == 30 ) ;
    wire divr_en = ( fn == 31 ) ;
    
    wire div_en  =  divq_en | divr_en ;
    
    wire [9:0] div_data = { divq_sign, divr_sign, divr_en, in_rd_add } ;

	wire div_ready;
	
	reg [31:0] reg_mag_rs1 ; always@(posedge clk) if ( reset | div_ready ) reg_mag_rs1 <= 0; else if (!div_ready & div_en) reg_mag_rs1 <= mag_rs1;
    reg [31:0] reg_mag_rs2 ; always@(posedge clk) if ( reset | div_ready ) reg_mag_rs2 <= 0; else if (!div_ready & div_en) reg_mag_rs2 <= mag_rs2;
    reg        reg_div_en  ; always@(posedge clk) if ( reset | div_ready ) reg_div_en  <= 0; else if (!div_ready & div_en) reg_div_en  <= div_en;
    
	wire div_pause = !div_ready & (div_en|reg_div_en) ;
	
	reg [2:0] wadd ;
	wire fifo_wen = div_en ;
    always@(posedge clk) begin
    	if      ( reset    ) wadd <= 0;
    	else if ( fifo_wen ) wadd <= wadd + 1 ;
    end
    
    reg [9:0] fifo [7:0];
    always@(posedge clk) begin
    	if ( fifo_wen ) fifo[wadd] <= div_data ;
    end
    
	wire        wire_div_en  = div_en | reg_div_en ;
	wire [31:0] wire_mag_rs1 = ( reg_div_en ) ? reg_mag_rs1 : mag_rs1 ;
	wire [31:0] wire_mag_rs2 = ( reg_div_en ) ? reg_mag_rs2 : mag_rs2 ;
	
    wire [32:0] div_q;
    wire [32:0] div_r;
    wire        div_vout;
    
	divu_radix8 inst_divu_radix (
	   .clk      ( clk          ),
	   .reset    ( reset        ),
	   .pause    ( pause        ),
	   .en       ( wire_div_en  ),
	   .divisor  ( {1'b0,wire_mag_rs2} ),
	   .dividend ( {1'b0,wire_mag_rs1} ),
	   .ready    ( div_ready    ),
	   .q        ( div_q        ),
	   .r        ( div_r        ),
	   .vout     ( div_vout     )
	);
	
    wire [31:0] quotient  = div_q[31:0] ;
    wire [31:0] remainder = div_r[31:0] ;
	
	// div32_radix16  inst_div32_radix16 (
	   // .clk   ( clk          ),
	   // .reset ( reset        ),
	   // .en    ( wire_div_en  ),
	   // .a     ( wire_mag_rs1 ),
	   // .b     ( wire_mag_rs2 ),
	   // .ready ( div_ready    ),
	   // .q     ( quotient     ),
	   // .r     ( remainder    ),
	   // .vout  ( div_vout     )
	// );
	
    reg [2:0] radd;
    always@(posedge clk) begin
    	if      ( reset    ) radd <= 0;
    	else if ( div_vout ) radd <= radd + 1;
    end
    
    wire [9:0] fifo_out = fifo[radd];
    
    wire [31:0] signed_quotient  = ( fifo_out[9] ) ? ( ~quotient  + 1'b1 ) : quotient ;
    wire [31:0] signed_remainder = ( fifo_out[8] ) ? ( ~remainder + 1'b1 ) : remainder;
    
    wire        div_rd_en   = div_vout ;
    wire [6:0]  div_rd_add  = fifo_out[6:0] ;
    wire [31:0] div_rd_data = ( fifo_out[7] ) ? signed_remainder : signed_quotient ;
	
//-------------------------------------------------------------------------------------//
//                                      Output
//-------------------------------------------------------------------------------------//
	
	wire md_pnc;
	
	three2one #(
   .WIDTH ( 39 )
	)  two2one_md (
	   .clk   ( clk       ),
	   .reset ( reset     ),
	   .pause ( pause     ),
	   .vdin1 ( macl_rd_en ),
	   .vdin2 ( mach_rd_en ),
	   .vdin3 ( div_rd_en ),
	   
	   .din1  ( {macl_rd_add, macl_rd_data} ),
	   .din2  ( {mach_rd_add, mach_rd_data} ),
	   .din3  ( {div_rd_add, div_rd_data} ),
	   
	   .vdout ( rd_en ),
	   .dout  ( {rd_add, rd_data} ),
	   .pnc   ( md_pnc )
	);
	
	assign md_pause_next = div_pause | md_pnc ;
	
endmodule
