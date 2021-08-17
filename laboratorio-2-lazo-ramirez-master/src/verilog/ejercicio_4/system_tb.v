`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;

	reg resetn = 0;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	wire trap;
	wire [7:0] out_byte;
	//wire [31:0] source_0;
	//wire [31:0] source_1;
	//wire [31:0] out_fact;
	//wire [31:0] out_mult_0;
	//wire [31:0] out_mult_1;
	wire out_byte_en;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_byte_en(out_byte_en)
		//.out_fact   (out_fact),
		//.source_0(source_0),
		//.source_1(source_1),
		//.out_mult_0(out_mult_0),
		//.out_mult_1(out_mult_1)
	);

	always @(posedge clk) begin
		if (resetn&& out_byte_en) begin
			$write("%c", out_byte);
			//$write("%c", source_0);
			//$write("%c", source_1);
			//$write("%c", out_fact);
			//$write("%c", out_mult_0);
			//$write("%c", out_mult_1);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
