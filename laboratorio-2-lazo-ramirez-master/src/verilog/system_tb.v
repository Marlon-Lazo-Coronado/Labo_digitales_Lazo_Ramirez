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
	wire [31:0] out_fact; //Agregado
	wire [31:0] A;
	wire [31:0] B;
	//wire [31:0]resto_bits;
	wire out_byte_en;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_fact   (out_fact   ), //Agregado
		.A		(A   ),
		.B		(B   ),
		//.resto_bits	(resto_bits),
		.out_byte_en(out_byte_en)
	);

	always @(posedge clk) begin
		if (resetn && out_byte_en) begin
			$write("%c", out_byte);
			$write("%c", out_fact); //Agregado
			$write("%c", A);
			$write("%c", B);
			//$write("%c", resto_bits);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
