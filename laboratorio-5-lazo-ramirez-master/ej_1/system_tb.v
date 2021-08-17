`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;
	reg enable = 0;

	reg resetn = 0;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
		repeat (100) @(posedge clk);
		resetn <= 1;
		repeat (50) @(posedge clk);
		enable <= 1;
		repeat (500) @(posedge clk);
		enable <= 0;
		repeat (500) @(posedge clk);
		enable <= 1;
		
	end

	wire trap;
	wire [7:0] out_byte;
	wire out_byte_en;
	wire [7:0] cathode_array;
	wire [7:0] anode_array;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.enable   (enable   ),
		.out_byte_en(out_byte_en),
		.cathode_array (cathode_array),
		.anode_array (anode_array)
	);

	always @(posedge clk) begin
		if (resetn && out_byte_en) begin
			$write("%c", out_byte);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
