module divu_radix4#(
	parameter WIDTH = 32'd32
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
	
	reg [31:0] index;
	reg [width1-1:0] msb_count;
	always @* begin // combination logic
		for(index = 0; index < WIDTH; index = index + 1) begin
			if(dividend[index]) begin
				msb_count = index;
			end
		end
	end
	
	wire [width1-1:0] shifts = WIDTH - 4'd2 - {msb_count[width1-1:1], 1'b0};
	
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
	
	wire [1:0] wire_q0 ;
	
	wire [WIDTH-1:0] wire_d1 ;
	wire [WIDTH-3:0] wire_d0 = reg_dividend[WIDTH-3:0] ;
	
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
			reg_dividend <= {wire_d1, wire_d0, 2'd0} ;
			reg_q        <= {reg_q[WIDTH-3:0], wire_q0} ;
		end
	end
	
	wire [WIDTH+1:0] wire_b   = reg_divisor       ;
	wire [WIDTH+1:0] wire_2b  = reg_divisor << 1  ;
	wire [WIDTH+1:0] wire_3b  = wire_b + wire_2b  ;
	
	wire [WIDTH+1:0] wire_a = { reg_dividend[(2*WIDTH-1):WIDTH-2] } ;
	
	wire [WIDTH+1:0] wire_s   =   wire_a - wire_b ;
	wire [WIDTH+1:0] wire_2s  =   wire_a - wire_2b ;
	wire [WIDTH+1:0] wire_3s  =   wire_a - wire_3b ;
	
	assign wire_d1 = ( wire_3s[WIDTH+1]  == 1'b0 ) ? wire_3s[WIDTH-1:0] 
	:                ( wire_2s[WIDTH+1]  == 1'b0 ) ? wire_2s[WIDTH-1:0] 
	:                ( wire_s[WIDTH+1]   == 1'b0 ) ? wire_s[WIDTH-1:0] 
	:                  wire_a[WIDTH-1:0] ;
	
	
	assign wire_q0 = ( wire_3s[WIDTH+1]  == 1'b0 ) ? 2'd3 
	:                ( wire_2s[WIDTH+1]  == 1'b0 ) ? 2'd2 
	:                ( wire_s[WIDTH+1]   == 1'b0 ) ? 2'd1 
	:                 2'd0 ;
	
	reg [width1-1:0] count_limit;
	always@(posedge clk) if (init) count_limit <= msb_count ;
	
	localparam width2 = width1 + 1 ;
	
	reg [width2-1:0] count;
	
	always@(posedge clk) begin
		if      ( reset  ) count <= 32'hffffffff;
		else if ( init   ) count <= 0;
		else if ( !ready ) count <= count + 2;
	end
	
	// assign q    = wire_15b ;
	assign q    = reg_q ;
	assign r    = reg_dividend[(2*WIDTH-1):WIDTH] ;
	assign vout = ( !ready && count > count_limit ) ? 1'b1 : 1'b0 ;
	
endmodule
