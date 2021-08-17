`timescale 1 ns / 1 ps
`include "lut_multiplier_32b_cond.v"

//---------------------------------------------------------------------------------------------------------//
module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	//output reg [31:0] out_mult_0,
	//output reg [31:0] out_mult_1,

	output reg       out_byte_en
	//output reg [31:0] out_fact,

	//output reg[31:0] source_0,
	//output reg[31:0] source_1
);
//---------------------------------------------------------------------------------------------------------//
	//set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;
         
	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

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

	reg[31:0] source_0;
	reg[31:0] source_1;
	reg[31:0] out_mult_0;
	reg[31:0] out_mult_1;
	wire[63:0] result;
//---------------------------------------------------------------------------------------------------------//

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

	lut_multiplier_32b_cond lut_32b(
		.resetn_32b				(resetn),
		.clk_32b					(clk),
		.source_number_32b_0		(source_0),
		.source_number_32b_1		(source_1),
		.result_64b				(result)
	);

//---------------------------------------------------------------------------------------------------------//
	reg [31:0] memory [0:MEM_SIZE-1];

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;
//---------------------------------------------------------------------------------------------------------//

	generate
	if (FAST_MEMORY) 
	begin
		always @(posedge clk) 
		begin
			mem_ready <= 1;
			out_byte_en <= 0;
			//mem_rdata <= memory[mem_la_addr >> 2];

			//Read
			if (mem_la_read && (mem_la_addr >> 2) < MEM_SIZE)
				mem_rdata <= memory[mem_la_addr >> 2];
			else if (mem_la_read && mem_la_addr == 32'hFFFF_FFF8) 
			begin
				mem_rdata <= result[31:0];
		    end
			else if (mem_la_read && mem_la_addr == 32'hFFFF_FFF0) 
			begin
				mem_rdata <= result[63:32];
		    end
			
			//Write
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) 
			begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else 
			begin
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				out_mult_0 <= mem_la_wdata;
				//out_fact <= mem_la_wdata;
			end else if (mem_la_write && mem_la_addr == 32'hFFFF_FFFC) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				out_mult_1 <= mem_la_wdata;
				//out_fact <= mem_la_wdata;
			end else if (mem_la_write && mem_la_addr == 32'h1000_000C) begin
				out_byte_en <= 1;
				source_0 <= mem_la_wdata;
			end else if (mem_la_write && mem_la_addr == 32'h1000_0010) begin
				out_byte_en <= 1;
				source_1 <= mem_la_wdata;
			end
			end
		end
	end 
	else 
	begin
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
					//out_fact <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end 
	endgenerate
endmodule
