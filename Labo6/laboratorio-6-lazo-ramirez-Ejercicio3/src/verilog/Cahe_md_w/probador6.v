module probador6(
	output reg mem_valid,
	output reg resetn,
	output reg mem_ready,
	output reg [32-1:0]mem_addr,
	output reg [3:0]mem_wstrb,
	output reg [32-1:0]mem_wdata,
	output reg [32-1:0]mem_rdata,

	input out_mem_valid,
	input out_mem_ready,
	input [32-1:0]out_mem_addr,
	input [3:0]out_mem_wstrb,
	input [32-1:0]out_mem_wdata,
	input [32-1:0]out_mem_rdata,
	//Estructural
	input out_mem_valid_estruc,
	input out_mem_ready_estruc,
	input [32-1:0]out_mem_addr_estruc,
	input [3:0]out_mem_wstrb_estruc,
	input [32-1:0]out_mem_wdata_estruc,
	input [32-1:0]out_mem_rdata_estruc,
	//
	output reg	clk
	);
	
	initial begin
		$dumpfile("cache.vcd");
		$dumpvars;
		//$display ("\t\t\tclok,\tA,\tB,\treset, \tOut,\tOut_Estruc");
		//$monitor($time,"\t%b\t%b\t\t%b\t%b", clok, A,B,reset,Out,Out_Estruc);
		
		// Valores iniciales de las señales.
		repeat (10) begin
		resetn <= 0;
		end
		mem_valid <= 0;
		mem_ready <= 0;
		mem_addr <= 0;
		mem_wstrb <= 0;
		mem_wdata <= 0;
		mem_rdata <= 0;            
		
		
		repeat (6) begin
		repeat (500) begin				
        		@(posedge clk);
        		
        		resetn <= 1;
        		mem_valid <= 1;
			mem_ready <= 1;
			mem_addr <= mem_addr+4;
			mem_wstrb <= 4'b1111;
			mem_wdata <= mem_wdata+3;
			mem_rdata <= mem_rdata+3;  
			
		end
		
		repeat (500) begin				
        		@(posedge clk);
        		
        		resetn <= 1;
        		mem_valid <= 1;
			mem_ready <= 1;
			mem_addr <= mem_addr+4;
			mem_wstrb <= 4'b0000;
			mem_wdata <= mem_wdata+3;
			mem_rdata <= mem_rdata+3;  
			
		end
		end
		mem_valid <= 0;
		mem_ready <= 0;
		mem_addr <= 0;
		mem_wstrb <= 0;
		mem_wdata <= 0;
		mem_rdata <= 0; 
		$finish;
		
	end
	// Reloj
	initial	clk 	<= 0;			// Valor inicial al reloj, sino siempre será indeterminado
	always	#1 clk 	<= ~clk;		// Hace "toggle" cada 4 segundos
endmodule
