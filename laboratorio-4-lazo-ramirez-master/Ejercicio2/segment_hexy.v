`timescale 1 ns / 1 ps

`ifndef segment_hexy
`define segment_hexy
module segment_hexy(
    
    input clk,
    input resetn,
    input [31:0] hex_input,

    output reg [7:0] cathode_array,
    output reg [7:0] anode_array
);

    parameter ZERO = 8'b11000000;
    parameter ONE = 8'b11111001;
    parameter TWO = 8'b10100100;
    parameter THREE = 8'b10110000;
    parameter FOUR = 8'b10011001;
    parameter FIVE = 8'b10010010;
    parameter SIX = 8'b10000010;
    parameter SEVEN = 8'b11111000;
    parameter EIGHT = 8'b10000000;
    parameter NINE = 8'b10010000;

    parameter A = 8'b10001000;
    parameter B = 8'b10000011;
    parameter C = 8'b11000110;
    parameter D = 8'b10100001;
    parameter E = 8'b10000110;
    parameter F = 8'b10001110;

    parameter DELAY = 5000;

    reg[7:0] anode_array_output;
    reg[31:0] hex_input_bank;
    reg[31:0] counter; 
    reg[4:0] shift;         
    reg[3:0] word_compare;       
    reg[2:0] iter;
    
    always @ (posedge clk) begin
        if(resetn) begin
            counter <= counter + 1;
            word_compare <= (hex_input>>shift)&4'b1111;
            case(1)
                word_compare == 4'b0000 && counter == DELAY: begin
                    cathode_array <= ZERO;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0001 && counter == DELAY: begin
                    cathode_array <= ONE;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0010 && counter == DELAY: begin
                    cathode_array <= TWO;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0011 && counter == DELAY: begin
                    cathode_array <= THREE;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0100 && counter == DELAY: begin
                    cathode_array <= FOUR;
                    shift <= shift + 4;
                    counter <= 0;
                     if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0101 && counter == DELAY: begin
                    cathode_array <= FIVE;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0110 && counter == DELAY: begin
                    cathode_array <= SIX;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b0111 && counter == DELAY: begin
                    cathode_array <= SEVEN;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1000 && counter == DELAY: begin
                    cathode_array <= EIGHT;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1001 && counter == DELAY: begin
                    cathode_array <= NINE;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1010 && counter == DELAY: begin
                    cathode_array <= A;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1011 && counter == DELAY: begin
                    cathode_array <= B;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1100 && counter == DELAY: begin
                    cathode_array <= C;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1101 && counter == DELAY: begin
                    cathode_array <= D;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1110 && counter == DELAY: begin
                    cathode_array <= E;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                word_compare == 4'b1111 && counter == DELAY: begin
                    cathode_array <= F;
                    shift <= shift + 4;
                    counter <= 0;
                    if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                        anode_array <= (anode_array << 1);
                    end else begin
                        anode_array <= (anode_array << 1) + 1;
                    end
                end
                
            endcase 
        end else begin
            anode_array <= 8'b11111111;
            cathode_array <= 8'b00000000;
            counter <= 0;
            shift <= 0;
            word_compare <= 0;
            iter <= 0;
        end
    end
endmodule
`endif
