module divu_radix8#(
	parameter WIDTH = 33// 1extra bit for sign
)(
	input clk,
	input reset,
	input pause,
	
	input en,//enable
	input [WIDTH-1:0] divisor,
	input [WIDTH-1:0] dividend,      // width should be multiple of 4
	
	output ready,
	output [WIDTH-1:0] q,//quotient
	output [WIDTH-1:0] r,//remainder
	output vout
);

	// localparam width1 = $clog2(WIDTH) ;//similar to parameter
	localparam width1 = 8 ;
	
	integer index;
	reg [width1-1:0] msb_count ;
	
	initial msb_count = 0 ;
	always @* begin // combination logic
		for(index = 2; index < WIDTH; index = index + 3) begin
			if(dividend[index]!=0 || dividend[index-1]!=0 || dividend[index-2]!=0 ) begin //tactical move to reduce the number of bits by removing the redundantbits and setting the msb bit to most significant 1
				msb_count = index;
			end
		end
	end
	
	wire [width1-1:0] shifts = WIDTH - 1 - msb_count;
	
	wire [WIDTH-1:0] wire_dividend = dividend << shifts ;  //removing the redundant zeros

	reg reg_ready;
	always@(posedge clk) begin
	    if      ( reset ) reg_ready <= 1; 
		else if ( vout  ) reg_ready <= 1; 
		else if ( en    ) reg_ready <= 0; 
	end
	
	assign ready = reg_ready;
	
	wire init = en & ready;
	
	reg [WIDTH-1  :0] reg_divisor;
	reg [2*WIDTH-1:0] reg_dividend;
	
	reg [WIDTH-1  :0] reg_q;
	
	wire [2:0] wire_q0 ;
	
	wire [WIDTH-1:0] wire_d1 ;
	wire [WIDTH-4:0] wire_d0 = reg_dividend[WIDTH-4:0] ;
	
	always@(posedge clk) begin
		if (reset) begin
			reg_divisor  <= {WIDTH{1'b0}} ;
			reg_dividend <= {(2*WIDTH){1'b0}};
			reg_q        <= {WIDTH{1'b0}};
		end else if (init) begin
			reg_divisor  <= divisor ;
			reg_dividend <= {{WIDTH{1'b0}}, wire_dividend} ;
			reg_q        <= {WIDTH{1'b0}};
		end else begin
			reg_dividend <= {wire_d1, wire_d0, 3'd0} ;
			reg_q        <= {reg_q[WIDTH-4:0], wire_q0} ;
		end
	end
	
	wire [WIDTH+2:0] wire_b   = reg_divisor       ;
	wire [WIDTH+2:0] wire_2b  = reg_divisor << 1  ;
	wire [WIDTH+2:0] wire_3b  = wire_b + wire_2b  ;
	wire [WIDTH+2:0] wire_4b  = reg_divisor << 2  ;
	wire [WIDTH+2:0] wire_5b  = wire_4b + wire_b  ;
	wire [WIDTH+2:0] wire_6b  = wire_4b + wire_2b ;
	wire [WIDTH+2:0] wire_7b  = wire_4b + wire_3b ;
	
	wire [WIDTH+2:0] wire_a = { reg_dividend[(2*WIDTH-1):WIDTH-3] } ;
	
	wire [WIDTH+2:0] wire_s   =   wire_a - wire_b ;
	wire [WIDTH+2:0] wire_2s  =   wire_a - wire_2b ;
	wire [WIDTH+2:0] wire_3s  =   wire_a - wire_3b ;
	wire [WIDTH+2:0] wire_4s  =   wire_a - wire_4b ;
	wire [WIDTH+2:0] wire_5s  =   wire_a - wire_5b ;
	wire [WIDTH+2:0] wire_6s  =   wire_a - wire_6b ;
	wire [WIDTH+2:0] wire_7s  =   wire_a - wire_7b ;
	
	assign wire_d1 = ( wire_7s[WIDTH+2]  == 1'b0 ) ? wire_7s[WIDTH-1:0] 
	:                ( wire_6s[WIDTH+2]  == 1'b0 ) ? wire_6s[WIDTH-1:0] 
	:                ( wire_5s[WIDTH+2]  == 1'b0 ) ? wire_5s[WIDTH-1:0] 
	:                ( wire_4s[WIDTH+2]  == 1'b0 ) ? wire_4s[WIDTH-1:0] 
	:                ( wire_3s[WIDTH+2]  == 1'b0 ) ? wire_3s[WIDTH-1:0] 
	:                ( wire_2s[WIDTH+2]  == 1'b0 ) ? wire_2s[WIDTH-1:0] 
	:                ( wire_s[WIDTH+2]   == 1'b0 ) ? wire_s[WIDTH-1:0] 
	:                  wire_a[WIDTH-1:0] ;
	
	
	assign wire_q0 = ( wire_7s[WIDTH+2]  == 1'b0 ) ? 3'd7 
	:                ( wire_6s[WIDTH+2]  == 1'b0 ) ? 3'd6 
	:                ( wire_5s[WIDTH+2]  == 1'b0 ) ? 3'd5 
	:                ( wire_4s[WIDTH+2]  == 1'b0 ) ? 3'd4 
	:                ( wire_3s[WIDTH+2]  == 1'b0 ) ? 3'd3 
	:                ( wire_2s[WIDTH+2]  == 1'b0 ) ? 3'd2 
	:                ( wire_s[WIDTH+2]   == 1'b0 ) ? 3'd1 
	:                 3'd0 ;
	
	reg [width1-1:0] count_limit;
	always@(posedge clk) if (init) count_limit <= msb_count ;
	
	reg [width1:0] count;
	
	always@(posedge clk) begin
		if      ( reset  ) count <= 32'hffffffff;
		else if ( init   ) count <= 0;
		else if ( !ready ) count <= count + 3;
	end
	
	// assign q    = wire_15b ;
	assign q    = reg_q ;
	assign r    = reg_dividend[(2*WIDTH-1):WIDTH] ;
	assign vout = ( !ready && count > count_limit ) ? 1'b1 : 1'b0 ;
	
endmodule
