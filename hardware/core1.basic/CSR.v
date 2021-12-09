module CSR(
		input clk,
		input reset,
		input ins_counter_up,
		//--------------------//
		input [11:0] imm,
		output [31:0] rdata,
		output vrdata,
		input [31:0] wdata,
		input rw,
		input rs,
		input rc
    );
	
////////    Read/Write registers   ////////
	
	
	reg [31:0] FFLAGS;
	always@(posedge clk) begin
		if      (reset) FFLAGS <= 0;
		else if (rw && imm==12'h001) FFLAGS <= wdata;
		else if (rs && imm==12'h001) FFLAGS <= FFLAGS | wdata;
		else if (rc && imm==12'h001) FFLAGS <= FFLAGS & ~wdata;
	end
	
	reg [31:0] FRM;
	always@(posedge clk) begin
		if      (reset             ) FRM <= 0;
		else if (rw && imm==12'h002) FRM <= wdata;
		else if (rs && imm==12'h002) FRM <= FRM | wdata;
		else if (rc && imm==12'h002) FRM <= FRM & ~wdata;
	end
	
	reg [31:0] FCAR;
	always@(posedge clk) begin
		if      (             reset) FCAR <= 0;
		else if (rw && imm==12'h003) FCAR <= wdata;
		else if (rs && imm==12'h003) FCAR <= FCAR | wdata;
		else if (rc && imm==12'h003) FCAR <= FCAR & ~wdata;
	end
	
////////    Read only registers   ////////
	
	reg [63:0] RDCYCLE  ; always@(posedge clk) if (reset) RDCYCLE   <= 0; else RDCYCLE <= RDCYCLE + 1 ;
	reg [63:0] RDTIME   ; always@(posedge clk) if (reset) RDTIME    <= 0; else RDTIME  <= RDTIME  + 1 ;
	reg [63:0] RDINSTRET; always@(posedge clk) if (reset) RDINSTRET <= 0; else if (ins_counter_up) RDINSTRET <= RDINSTRET + 1;
	
	
	
////////    Output   ////////
	
	assign vrdata = rw | rs | rc ;
	assign rdata = reset          ? 0
	:              (imm==12'h001) ? FFLAGS
	:              (imm==12'h002) ? FRM
	:              (imm==12'h003) ? FCAR
	:              (imm==12'hc00) ? RDCYCLE[31:0]
	:              (imm==12'hc01) ? RDTIME[31:0]
	:              (imm==12'hc02) ? RDINSTRET[31:0]
	:              (imm==12'hc80) ? RDCYCLE[63:32]
	:              (imm==12'hc81) ? RDTIME[63:32]
	:              (imm==12'hc82) ? RDINSTRET[63:32]
    :              0;
	
endmodule

