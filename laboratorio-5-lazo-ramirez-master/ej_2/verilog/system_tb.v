`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	reg ps2_clk = 0;
	always #5 clk = ~clk;
	always #20 ps2_clk = ~ps2_clk;
	reg enable = 0;

	reg resetn = 0;
	reg ps2_data = 0;
	reg [4:0] cont;

	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
		repeat (100) @(posedge clk);
		resetn <= 1;
		enable <= 1;
		cont <= 0;

		@(posedge clk);
		
		cont <= -2;
		resetn <= 0;


		repeat (23) begin
		@(posedge clk);
		
		//resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			ps2_data <= 1;
		else
			ps2_data <= 1;
		end  

		repeat (23+4) begin
		@(posedge clk);
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				ps2_data <= 1;
			else
				ps2_data <= 1;
		end   
		
		repeat (23) begin
		@(posedge clk);
	
		
		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			ps2_data <= 1;
		else
			ps2_data <= 0;
		end  
		
		repeat (23+4) begin
		@(posedge clk);
		
			resetn <= 1;

			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				ps2_data <= 1;
			else
				ps2_data <= 0;
		end 
   		
   		repeat (23) begin
		@(posedge clk);

		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			ps2_data <= 0;
		else
			ps2_data <= 1;
		end  
		
		repeat (23+4) begin
		@(posedge clk);
		
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				ps2_data <= 1;
			else
				ps2_data <= 0;
		end   

		
		repeat (23*100) begin
		@(posedge clk);
		resetn <= 1;
		if (cont == 23)
			cont <= 0;
		else
			cont <= cont + 1;
		if ((cont >= 15) && (cont < 23))
			ps2_data <= 0;
		else
			ps2_data <= 1;
		end  
		
		repeat ((23+4)*10000) begin
		@(posedge clk);
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				ps2_data <= 1;
			else
				ps2_data <= 0;
		end
		
		repeat ((23+4)*10000) begin
		@(posedge clk);
		
			resetn <= 1;
			if (cont == 23)
				cont <= 0;
			else
				cont <= cont + 1;
			if ((cont >= 19) && (cont < 23))
				ps2_data <= 1;
			else
				ps2_data <= 0;
		end

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
		.PS2_DATA (ps2_data),
		.PS2_CLK (ps2_clk),
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
