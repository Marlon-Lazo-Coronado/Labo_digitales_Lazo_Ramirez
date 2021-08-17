`timescale 1 ns / 1 ps
`include "cache_2_way_random.v"
`include "memory.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [31:0] out_byte,
	output reg       out_byte_en
);

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire [31:0] mem_addr_MP;
	wire [31:0] mem_wdata_MP;
	wire [3:0] mem_wstrb_MP;
	wire mem_valid_MP;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	
	wire mem_ready_MP;
	wire [31:0] mem_rdata_MP;

	wire [31:0] out_byte_wire;
	wire out_byte_en_wire;

	wire[20:0] hits, miss;
	
	
	always @ (*) begin
		out_byte <= out_byte_wire;
		out_byte_en <= out_byte_en_wire;
	end

	
	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),

		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),

		.mem_rdata   (mem_rdata),
		.mem_ready   (mem_ready),

		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);


	
	cache_2_way_random #( 
			.CACHE_SIZE(1024*4),
			.BLOCK_SIZE(4*4),
			.WAY_SIZE(2))
			cache_2_way_random_inst
			(
				
			// inputs
			.clk(clk),
			.resetn(resetn),
			.mem_intr(mem_instr), 

			.mem_valid(mem_valid),
			.mem_addr(mem_addr),
			.mem_wstrb(mem_wstrb),
			.mem_wdata(mem_wdata),

			.mem_ready_MP(mem_ready_MP),	
			.mem_rdata_MP(mem_rdata_MP),	

			//outputs
			.mem_ready(mem_ready),
			.mem_rdata(mem_rdata),

			.mem_valid_MP(mem_valid_MP),		
			.mem_addr_MP(mem_addr_MP),		
			.mem_wstrb_MP(mem_wstrb_MP),		
			.mem_wdata_MP(mem_wdata_MP),		

			.hits(hits),
			.miss(miss)
	);

	
	memory memory_inst(
		// inputs
		.clk(clk),
		.resetn(resetn),

		.mem_valid(mem_valid_MP),
		.mem_addr(mem_addr_MP),
		.mem_wdata(mem_wdata_MP),
		.mem_wstrb(mem_wstrb_MP),

		.mem_la_read(mem_la_read),
		.mem_la_write(mem_la_write),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_addr(mem_la_addr),
		.mem_la_wstrb(mem_la_wstrb),

		// outputs 
		.mem_ready(mem_ready_MP),
		.mem_rdata(mem_rdata_MP),
		.out_byte(out_byte_wire),
		.out_byte_en(out_byte_en_wire)
	);


endmodule
