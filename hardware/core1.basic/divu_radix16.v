module divu_radix16#(
	parameter WIDTH = 32
)(
	input clk,
	input reset,
	input pause,
	
	input en,
	input [WIDTH-1:0] divisor,
	input [WIDTH-1:0] dividend,      // width should be multiple of 4
	
	output ready,
	output [WIDTH-1:0] q,
	output [WIDTH-1:0] r,
	output vout
);

	// localparam width1 = $clog2(WIDTH) ;
	localparam width1 = 5 ;
	integer index;
	reg [width1-1:0] msb_count;
	always @* begin // combination logic
		for(index = 0; index < WIDTH; index = index + 1) begin
			if(dividend[index]) begin
				msb_count = index;
			end
		end
	end
	
	wire [width1-1:0] shifts = WIDTH - 4 - {msb_count[width1-1:2], 2'b00};
	
	wire [WIDTH-1:0] wire_dividend = dividend << shifts ;

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
	
	wire [ 3:0] wire_q0 ;
	
	wire [WIDTH-1:0] wire_d1 ;
	wire [WIDTH-5:0] wire_d0 = reg_dividend[WIDTH-5:0] ;
	
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
			reg_dividend <= {wire_d1, wire_d0, 4'd0} ;
			reg_q        <= {reg_q[WIDTH-5:0], wire_q0} ;
		end
	end
	
	wire [WIDTH+3:0] wire_b   = reg_divisor       ;
	wire [WIDTH+3:0] wire_2b  = reg_divisor << 1  ;
	wire [WIDTH+3:0] wire_3b  = wire_b + wire_2b  ;
	wire [WIDTH+3:0] wire_4b  = reg_divisor << 2  ;
	wire [WIDTH+3:0] wire_5b  = wire_4b + wire_b  ;
	wire [WIDTH+3:0] wire_6b  = wire_4b + wire_2b ;
	wire [WIDTH+3:0] wire_7b  = wire_4b + wire_3b ;
	wire [WIDTH+3:0] wire_8b  = reg_divisor << 3  ;
	wire [WIDTH+3:0] wire_9b  = wire_8b + wire_b  ;
	wire [WIDTH+3:0] wire_10b = wire_8b + wire_2b ;
	wire [WIDTH+3:0] wire_11b = wire_8b + wire_3b ;
	wire [WIDTH+3:0] wire_12b = wire_8b + wire_4b ;
	wire [WIDTH+3:0] wire_13b = wire_8b + wire_5b ;
	wire [WIDTH+3:0] wire_14b = wire_8b + wire_6b ;
	wire [WIDTH+3:0] wire_15b = wire_8b + wire_7b ;
	
	
	wire [WIDTH+3:0] wire_a = { reg_dividend[(2*WIDTH-1):WIDTH-4] } ;
	
	wire [WIDTH+3:0] wire_s   =   wire_a - wire_b ;
	wire [WIDTH+3:0] wire_2s  =   wire_a - wire_2b ;
	wire [WIDTH+3:0] wire_3s  =   wire_a - wire_3b ;
	wire [WIDTH+3:0] wire_4s  =   wire_a - wire_4b ;
	wire [WIDTH+3:0] wire_5s  =   wire_a - wire_5b ;
	wire [WIDTH+3:0] wire_6s  =   wire_a - wire_6b ;
	wire [WIDTH+3:0] wire_7s  =   wire_a - wire_7b ;
	wire [WIDTH+3:0] wire_8s  =   wire_a - wire_8b ;
	wire [WIDTH+3:0] wire_9s  =   wire_a - wire_9b ;
	wire [WIDTH+3:0] wire_10s =   wire_a - wire_10b ;
	wire [WIDTH+3:0] wire_11s =   wire_a - wire_11b ;
	wire [WIDTH+3:0] wire_12s =   wire_a - wire_12b ;
	wire [WIDTH+3:0] wire_13s =   wire_a - wire_13b ;
	wire [WIDTH+3:0] wire_14s =   wire_a - wire_14b ;
	wire [WIDTH+3:0] wire_15s =   wire_a - wire_15b ;
	
	assign wire_d1 = ( wire_15s[WIDTH+3] == 1'b0 ) ? wire_15s[WIDTH-1:0] 
	:                ( wire_14s[WIDTH+3] == 1'b0 ) ? wire_14s[WIDTH-1:0] 
	:                ( wire_13s[WIDTH+3] == 1'b0 ) ? wire_13s[WIDTH-1:0] 
	:                ( wire_12s[WIDTH+3] == 1'b0 ) ? wire_12s[WIDTH-1:0] 
	:                ( wire_11s[WIDTH+3] == 1'b0 ) ? wire_11s[WIDTH-1:0] 
	:                ( wire_10s[WIDTH+3] == 1'b0 ) ? wire_10s[WIDTH-1:0] 
	:                ( wire_9s[WIDTH+3]  == 1'b0 ) ? wire_9s[WIDTH-1:0] 
	:                ( wire_8s[WIDTH+3]  == 1'b0 ) ? wire_8s[WIDTH-1:0] 
	:                ( wire_7s[WIDTH+3]  == 1'b0 ) ? wire_7s[WIDTH-1:0] 
	:                ( wire_6s[WIDTH+3]  == 1'b0 ) ? wire_6s[WIDTH-1:0] 
	:                ( wire_5s[WIDTH+3]  == 1'b0 ) ? wire_5s[WIDTH-1:0] 
	:                ( wire_4s[WIDTH+3]  == 1'b0 ) ? wire_4s[WIDTH-1:0] 
	:                ( wire_3s[WIDTH+3]  == 1'b0 ) ? wire_3s[WIDTH-1:0] 
	:                ( wire_2s[WIDTH+3]  == 1'b0 ) ? wire_2s[WIDTH-1:0] 
	:                ( wire_s[WIDTH+3]   == 1'b0 ) ? wire_s[WIDTH-1:0] 
	:                  wire_a[WIDTH-1:0] ;
	
	
	assign wire_q0 = ( wire_15s[WIDTH+3] == 1'b0 ) ? 4'd15 
	:                ( wire_14s[WIDTH+3] == 1'b0 ) ? 4'd14
	:                ( wire_13s[WIDTH+3] == 1'b0 ) ? 4'd13 
	:                ( wire_12s[WIDTH+3] == 1'b0 ) ? 4'd12 
	:                ( wire_11s[WIDTH+3] == 1'b0 ) ? 4'd11 
	:                ( wire_10s[WIDTH+3] == 1'b0 ) ? 4'd10 
	:                ( wire_9s[WIDTH+3]  == 1'b0 ) ? 4'd9 
	:                ( wire_8s[WIDTH+3]  == 1'b0 ) ? 4'd8 
	:                ( wire_7s[WIDTH+3]  == 1'b0 ) ? 4'd7 
	:                ( wire_6s[WIDTH+3]  == 1'b0 ) ? 4'd6 
	:                ( wire_5s[WIDTH+3]  == 1'b0 ) ? 4'd5 
	:                ( wire_4s[WIDTH+3]  == 1'b0 ) ? 4'd4 
	:                ( wire_3s[WIDTH+3]  == 1'b0 ) ? 4'd3 
	:                ( wire_2s[WIDTH+3]  == 1'b0 ) ? 4'd2 
	:                ( wire_s[WIDTH+3]   == 1'b0 ) ? 4'd1 
	:                 4'd0 ;
	
	localparam width2 = width1 + 1 ;
	
	// reg [width2-1:0] count_limit;
	// always@(posedge clk) if (init) count_limit <= ( msb_count >> 2 ) + 1 ;
	
	reg [width2-1:0] count;
	always@(posedge clk) begin
		if      ( reset  ) count <= 32'hffffffff;
		else if ( init   ) count <= 0;
		else if ( !ready ) count <= count + 4;
	end
	
	// assign q    = wire_15b ;
	assign q    = reg_q ;
	assign r    = reg_dividend[(2*WIDTH-1):WIDTH] ;
	assign vout = ( !ready && count > msb_count ) ? 1'b1 : 1'b0 ;
	
endmodule
