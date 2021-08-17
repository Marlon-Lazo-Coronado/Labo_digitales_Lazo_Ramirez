`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;

	reg [4:0]cont;
	reg resetn;
	reg MISO;
	reg INT1;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
		MISO <= 0;
		cont <= 0;
		repeat (10) begin
		@(posedge clk);
		
		cont <= -2;
		resetn <= 0;

		end 


		repeat (23) begin
		@(posedge clk);
		
		//resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			MISO <= 1;
		else
			MISO <= 0;
		end  

		repeat (23+4) begin
		@(posedge clk);
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				MISO <= 1;
			else
				MISO <= 0;
		end   
		
		repeat (23) begin
		@(posedge clk);
	
		
		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			MISO <= 1;
		else
			MISO <= 0;
		end  
		
		repeat (23+4) begin
		@(posedge clk);
		
			resetn <= 1;

			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				MISO <= 1;
			else
				MISO <= 0;
		end 
   		
   		repeat (23) begin
		@(posedge clk);
		INT1 <= 0;
		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			MISO <= 1;
		else
			MISO <= 0;
		end  
		
		repeat (23+4) begin
		@(posedge clk);
		
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				MISO <= 1;
			else
				MISO <= 0;
		end   

		
		repeat (23*100) begin
		@(posedge clk);
		INT1 <= 1;
		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			MISO <= 1;
		else
			MISO <= 0;
		end  
		
		repeat ((23+4)*10000) begin
		@(posedge clk);
			INT1 <= 0;
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				MISO <= 1;
			else
				MISO <= 0;
		end

		INT1 <= 1;
		repeat (50) begin
		@(posedge clk);
			INT1 <= 0;
		end
		
		repeat ((23+4)*10000) begin
		@(posedge clk);
		
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				MISO <= 1;
			else
				MISO <= 0;
		end
	
	end
	wire trap;
	wire [7:0] out_byte;
	wire out_byte_en;
	wire[7:0] anode_array, cathode_array;
	wire SCLK;
	wire MOSI;
	wire CS;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.MISO		(MISO		),
		.INT1		(INT1		),
		.out_byte   (out_byte   ),
		.out_byte_en (out_byte_en),
		.anode_array (anode_array),
		.cathode_array (cathode_array),
		.SCLK (SCLK),
		.MOSI (MOSI),
		.CS (CS)
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

