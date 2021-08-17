`timescale 1 ns / 1 ps
`include "memory.v"

module system(
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
	wire [31:0] mem_rdata;
	wire [3:0] mem_wstrb;
	
	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	wire [31:0] out_byte_w;
	wire out_byte_en_w;

	always @ (*) begin
		out_byte = out_byte_w;
		out_byte_en = out_byte_en_w;	
	end

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

	memory memory_inst (
    	.clk			(clk),
    	.resetn			(resetn),

    	.mem_valid		(mem_valid),
    	.mem_addr		(mem_addr),
    	.mem_wdata		(mem_wdata),
    	.mem_wstrb		(mem_wstrb),

    	.mem_la_read	(mem_la_read),
    	.mem_la_write	(mem_la_write),
    	.mem_la_wdata	(mem_la_wdata),
    	.mem_la_addr	(mem_la_addr),
    	.mem_la_wstrb	(mem_la_wstrb),	

    	.mem_ready		(mem_ready),
    	.mem_rdata		(mem_rdata),
    	.out_byte		(out_byte_w),
    	.out_byte_en	(out_byte_en_w)	
	);

endmodule
