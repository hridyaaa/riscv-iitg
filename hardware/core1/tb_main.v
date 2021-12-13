// `timescale 1ns/1ns
module tb_main();
	reg reset;
	initial begin
	  reset <= 1;
	  #1001 reset <= 0;
	end

	reg clk;
	initial clk <= 0;
	always #5 clk <= ~clk;
	
	wire [31:0] axi_add, axi_rdata, axi_wdata;
	wire [ 3:0] axi_wen; 
	wire uart_tx,b,c;
	
	main main_inst(
		.clk (clk), 
		.reset (reset),
		.uart_tx (uart_tx),
		.b (b),
		.c (c)
	);
	
	// initial begin
		// $set_toggle_region(tb_main.main_inst);
		// $toggle_start();
		// #100000
		// $toggle_stop();
		// $toggle_report("cpu.saif", 1.0e-12, "tb_main");
		// #40 $finish;
	// end
	
endmodule
