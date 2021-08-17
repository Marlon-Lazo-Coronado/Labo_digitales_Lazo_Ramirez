`timescale 1 ns / 1 ps

`ifndef text_display
`define text_display
module text_display(
    
    input clk,
    input resetn,
    input enable,
    input [3:0] selector,

    output reg disable_text,

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
    parameter G = 8'b11000010;
    parameter H = 8'b10001011;
    parameter I = 8'b11101110;
    parameter J = 8'b11110010;
    parameter K = 8'b10001010;
    parameter L = 8'b11000111;
    parameter M = 8'b10101010;
    parameter N = 8'b10101011;
    parameter O = 8'b10100011;
    parameter P = 8'b10001100;
    parameter Q = 8'b10011000;
    parameter R = 8'b10101111;
    parameter S = 8'b11010010;
    parameter T = 8'b10000111;
    parameter U = 8'b11100011;
    parameter V = 8'b11010101;
    parameter W = 8'b10010101;
    parameter X = 8'b11101011;
    parameter Y = 8'b10010001;
    parameter Z = 8'b11100100;

    parameter AT = 8'b11101000;

    parameter DELAY = 100000;

    reg[31:0] counter, cathode_counter;            
    
    always @ (posedge clk) begin
        if(resetn) begin
            if(enable) begin
                disable_text <= 0;
                counter <= counter + 1;
                case(1)
                    selector == 4'b0000 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= T;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= R;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= A;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= T;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase
                    end
                    selector == 4'b0001 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= AT;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= T;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= C;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= E;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= L;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 5: begin
                                cathode_array <= E;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 6: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                    selector == 4'b0010 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= R;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= E;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= P;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= A;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= P;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                        
                    end
                    selector == 4'b0011 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= R;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 5: begin
                                cathode_array <= I;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 6: begin
                                cathode_array <= C;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 7: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                    selector == 4'b0100 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= K;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= C;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= R;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                    selector == 4'b0101 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= AT;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= L;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= A;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= V;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= I;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 5: begin
                                cathode_array <= R;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                    selector == 4'b0110 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= N;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= W;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= 8'b11111111;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= U;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 5: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 6: begin
                                cathode_array <= Y;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase
                    end
                    selector == 4'b0111 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= T;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= S;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 3: begin
                                cathode_array <= L;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 4: begin
                                cathode_array <= 8'b11111111;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 5: begin
                                cathode_array <= U;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 6: begin
                                cathode_array <= O;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 7: begin
                                cathode_array <= Y;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                    selector == 4'b1000 && counter == DELAY: begin
                        counter <= 0;   // delay counter
                        /* anode_array sequence */
                        if(anode_array == 8'b11111111 || anode_array == 8'b01111111) begin
                            anode_array <= (anode_array << 1);
                        end else begin
                            if(anode_array == 8'b10111111) begin
                                cathode_counter <= 0;
                            end else begin
                                cathode_counter <= cathode_counter;     //warning
                            end
                            anode_array <= (anode_array << 1) + 1;
                        end

                        /* cathode assignment */
                        case(1)
                            cathode_counter == 0: begin
                                cathode_array <= E;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 1: begin
                                cathode_array <= I;
                                cathode_counter <= cathode_counter + 1;
                            end
                            cathode_counter == 2: begin
                                cathode_array <= T;
                                cathode_counter <= cathode_counter + 1;
                            end
                            default:
                                cathode_array <= 8'b11111111;
                        endcase 
                    end
                endcase 
            end else begin
                disable_text <= 1;
                anode_array <= 8'b00000000;
                cathode_array <= 8'b11111111;
            end
        end else begin
            anode_array <= 8'b11111111;
            cathode_array <= 8'b00000000;
            counter <= 0;
            cathode_counter <= 0;
        end
    end
endmodule
`endif