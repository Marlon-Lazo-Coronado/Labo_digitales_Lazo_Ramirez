`timescale 1 ns / 1 ps
`include "segment_hexz.v"
`include "segment_hexy.v"
`include "accelerometer_reader.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en,
	output reg [7:0] anodo,
	output reg [7:0] catodo,
	
	input 		MISO,
	output reg 	SCLK,
    	output reg	MOSI,
    	output reg	 CS
	//input 	       [31:0] irq
	//output reg 	   [31:0] eoi
);
	// set this to 0 for better timing but less performance/MHz
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
	
	wire SCLK_w;
	wire MOSI_w;
	wire CS_w;
	wire [7:0]anodo_w;
	wire [7:0]catodo_w;
	reg [31:0] num_bit;
	wire [15:0]Y_n;
	wire [15:0]Z_n;

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
		//.irq(irq),
		//.eoi(eoi)
	);

	segment_hexy Y_dec(.clk(clk), .resetn(resetn), .hex_input(num_bit), .cathode_array(catodo_w), .anode_array(anodo_w) );
	
	accelerometer_reader acel_int(.clk(clk),.resetn(resetn),.MISO(MISO),.Y_n(Y_n), .Z_n(Z_n),.SCLK(SCLK_w),.MOSI(MOSI_w),.CS(CS_w));

	reg [31:0] memory [0:MEM_SIZE-1];
	
	//wire [31:0] eoi;
	

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
			MOSI <= MOSI_w;
			SCLK <= SCLK_w;
			CS <= CS_w;
			anodo <= anodo_w;
			catodo <= catodo_w;
			
			if (mem_la_read && mem_la_addr == 32'h2000_0000) begin
				mem_rdata[15:0] <= Y_n;
				mem_rdata[31:16] <= 0;
			end
			else begin
				if (mem_la_read && mem_la_addr == 32'h3000_0000) begin
					mem_rdata[15:0] <= Z_n;
					mem_rdata[31:16] <= 0;
		     		end
		     		else
		     			mem_rdata <= memory[mem_la_addr >> 2];
			end
			
			
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				num_bit <= mem_la_wdata[31: 0];
			end
			/*if (mem_la_write && mem_la_addr == 32'h1000_0004) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
			end*/
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
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
endmodule
