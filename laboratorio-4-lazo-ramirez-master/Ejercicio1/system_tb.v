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
	wire out_byte_en;
	wire [7:0] catodo;
	wire [7:0] anodo;
	wire 		MISO;
	wire 		SCLK;
    	wire		MOSI;
    	wire	 	CS;
	reg [31:0] irq;
	reg [9:0] cont;
	wire [31:0] eoi;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_byte_en(out_byte_en),
		.anodo(anodo),
		.catodo(catodo),
		.MISO(MISO),
		.SCLK(SCLK),
    		.MOSI(MOSI),
    		.CS(CS)
		.irq (irq)
		.eoi (eoi)
	);
		

	always @(posedge clk) begin
	  cont <= cont + 1;
	   if (resetn==0) begin
	       irq <= 32'h11111111;
	       cont <= 0;
	   end
	   else begin
	       if (cont == 1023)
	           irq <= 32'b00000000000000000000000000000100;
	       else
	           irq <= 32'b00000000000000000000000000000000;
	   end
	
		if (resetn && out_byte_en) begin
			$write("%c", out_byte);
			$write("%c", eoi);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
