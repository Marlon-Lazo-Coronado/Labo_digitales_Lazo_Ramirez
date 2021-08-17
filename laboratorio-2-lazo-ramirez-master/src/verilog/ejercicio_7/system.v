`timescale 1 ns / 1 ps
`include "lut_factorial_cond.v"
module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg	[7:0] out_byte,
	output reg 	[31:0] out_fact, //Agregado
	output reg     [31:0] num,
	output reg     start,
	output reg     out_byte_en
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;
	//=================================
	parameter n = 32;
	parameter k = 64;
	//=================================

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	//============================
	wire   [k-1:0]Out;
	//reg   [n-1:0]num;
	//reg   start;
	wire   output_ready;
	//============================

	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);

	reg [31:0] memory [0:MEM_SIZE-1];

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			
			//mem_rdata <= memory[mem_la_addr >> 2];
			//Leer
			if (mem_la_read && (mem_la_addr >> 2) < MEM_SIZE) begin
				mem_rdata <= memory[mem_la_addr >> 2]; end
			else if (mem_la_read && mem_la_addr == 32'h0fff_fff8) begin
				mem_rdata <= Out[31:0];
			end
			else if (mem_la_read && mem_la_addr == 32'h0fff_fffC) begin
				mem_rdata[0] <= output_ready;
		     	end
			
			//==========================================================================
			else if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata; //Yo le puse el parentesis!
				out_fact <= mem_la_wdata; //Agregado
			end
			//==========================================================================
			//Escribir
			else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF0) begin
				out_byte_en <= 1;
				num <= mem_la_wdata;
			end
			else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF4) begin
				out_byte_en <= 1;
				start <= mem_la_wdata;
			end
			
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					out_fact <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
//============================================================================
lut_factorial_cond lut_factorial_cond_int(.clk_32b(clk),.resetn_32b(resetn),.start(start),.source_number_32b(num),.output_ready(output_ready),.factorial(Out));
//============================================================================
endmodule










