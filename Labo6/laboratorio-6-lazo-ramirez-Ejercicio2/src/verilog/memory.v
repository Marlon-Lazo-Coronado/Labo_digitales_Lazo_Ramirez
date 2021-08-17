`timescale 1 ns / 1 ps

module memory(
    input clk,
    input resetn,

    input mem_valid,
    input[31:0] mem_addr,
    input[31:0] mem_wdata,
    input[3:0] mem_wstrb,

    input mem_la_read,
    input mem_la_write,
    input[31:0] mem_la_wdata,
    input[31:0] mem_la_addr,
    input[3:0] mem_la_wstrb,

    output reg mem_ready,
    output reg[31:0] mem_rdata,
    output reg[31:0] out_byte,
    output reg out_byte_en
);

	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 16384 32bit words = 64kB memory
	parameter MEM_SIZE = 16384;

    // memory register
	reg[31:0] memory [0:MEM_SIZE-1];

    // delay counter registers
    reg[3:0] read_delay_counter;
    reg[3:0] write_delay_counter;
    
    `ifdef SYNTHESIS
        initial $readmemh("../firmware/firmware.hex", memory);
    `else
        initial $readmemh("firmware.hex", memory);
    `endif
    

	reg [31:0] m_read_data;
	reg m_read_en;

	generate 
		if (FAST_MEMORY) begin
		always @(posedge clk) begin

			if(resetn) begin
				read_delay_counter <= read_delay_counter;
				write_delay_counter <= write_delay_counter;
			end else begin
				write_delay_counter <= 0;
				read_delay_counter <= 0;
			end
		
			case (1)
				read_delay_counter == 10 && resetn && !mem_wstrb: begin
					read_delay_counter <= 0;
					/* Valid assignment */
					mem_ready <= 1;

					/* Memory data assignment */
					m_read_en <= 0;
					mem_rdata <= memory[mem_la_addr >> 2];
				end
				read_delay_counter < 10 && resetn && !mem_wstrb && mem_valid: begin
					mem_ready <= 0;
					mem_rdata <= mem_rdata;
					read_delay_counter <= read_delay_counter + 1;
				end
				
				write_delay_counter == 15 && resetn && |mem_wstrb: begin
					write_delay_counter <= 0;
				end
				write_delay_counter < 15 && resetn && |mem_wstrb && mem_valid: begin
					mem_ready <= 0;
					//mem_rdata <= 0;
					write_delay_counter <= write_delay_counter + 1;
				end
			endcase

			out_byte_en <= 0;

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
			end
		end
	end else begin
		always @(posedge clk) begin

			if(resetn) begin
				read_delay_counter <= read_delay_counter;
				write_delay_counter <= write_delay_counter;
			end else begin
				write_delay_counter <= 0;
				read_delay_counter <= 0;
			end
		
			case (1)
				read_delay_counter == 10 && resetn && !mem_wstrb: begin
					read_delay_counter <= 0;
					/* Valid assignment */
					mem_ready <= mem_valid && !mem_ready && m_read_en;

					/* Memory data assignment */
					m_read_en <= 0;
					mem_rdata <= m_read_data;
				end
				read_delay_counter < 10 && resetn && !mem_wstrb && mem_valid: begin
					mem_ready <= 0;
					if(read_delay_counter == 9) begin
						m_read_data <= memory[mem_addr >> 2];
					end else begin
						m_read_data <=m_read_data;
					end
					mem_rdata <= mem_rdata;
					read_delay_counter <= read_delay_counter + 1;
				end
				
				write_delay_counter == 15 && resetn && |mem_wstrb: begin
					write_delay_counter <= 0;
				end
				write_delay_counter < 15 && resetn && |mem_wstrb && mem_valid: begin
					mem_ready <= 0;
					//mem_rdata <= 0;
					write_delay_counter <= write_delay_counter + 1;
				end
			endcase

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
					if(write_delay_counter == 15) begin
						mem_ready <= 1;
					end else begin
						mem_ready <= 0;
					end
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					if(write_delay_counter == 15) begin
						mem_ready <= 1;
					end else begin
						mem_ready <= 0;
					end
				end
			endcase
		end
	end
	endgenerate
endmodule
