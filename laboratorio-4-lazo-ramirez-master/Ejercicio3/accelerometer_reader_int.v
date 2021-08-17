module accelerometer_reader_int (
    input clk,
    input resetn,
    input MISO,
    input[31:0] eoi,

    output reg [15:0] Y_n,
    output reg [15:0] Z_n,
    output reg SCLK,
    output reg MOSI,
    output reg CS
);

reg [1:0]cont;
reg [4:0]cont2;
reg [4:0]cont3;
reg [7:0]read = 8'b01101000;
reg [7:0]adress_yl = 8'b00000100;
reg [7:0]adress_yh = 8'b01000100;
reg [7:0]adress_zl = 8'b00100100;
reg [7:0]adress_zh = 8'b01100100;

reg [11:0]Y;
reg [11:0]Z;


reg flag1;
reg flag2;
reg flag_clk;

reg clk2;
reg [31:0]counter;
reg resetn2;

reg[7:0] WRITE_INSTR = 8'b00001010;

reg[7:0] ACT_INACT_REG_ADDRESS = 8'b00100111;
reg[7:0] ACT_INACT_REG_CONFIG = 8'b110101;

reg[7:0] INT_MAP1_REG_ADDRESS = 8'b00101010;
reg[7:0] INT_MAP1_REG_CONFIG = 8'b00010000;

reg[2:0] counter_write;
reg[1:0] counter_act;

reg act_inact_done;
reg int1_done;

reg[3:0] REG_WRITE;

parameter IDLE = 4'b0001;
parameter ACT_INACT = 4'b0010;
parameter INT1 = 4'b0100;
parameter MOSI_DATA = 4'b1000;

//Disminuimos la frecuencia
always @(posedge clk) begin
	if (resetn == 0) begin
		clk2 <= 0;
		counter <= 0;
		resetn2 <= 0;
	end
	else begin
		if(counter == 31) begin //5000
			clk2 <= ~clk2;
			counter <= 0;
		end 
		else begin
			clk2 <= clk2;
			counter <= counter + 1;
		end
    end
end

always @(*) begin
	if (flag_clk) begin
		SCLK = ~clk2;
		CS = 0;
	end
	else begin
		SCLK = 0;
		CS = 1;
	end
end

initial begin
	cont <= 0;
	cont2 <= -1;
	cont3 <= 0;
	MOSI <= 0;
	flag_clk <= 0;
end
//=====================================================================================================================================


always @(posedge clk2) begin
    resetn2 <= 1;
    if(resetn2) begin
        counter_write <= counter_write + 1;
        /* activity state mapping */
        case(REG_WRITE)
            IDLE: begin
                if(eoi == 0) begin
                    if(act_inact_done && int1_done) begin
                        REG_WRITE <= MOSI_DATA;
                    end else begin
                        REG_WRITE <= ACT_INACT;
                    end
                end else begin
                    REG_WRITE <= IDLE;
                end
            end
            ACT_INACT: begin
                if(eoi == 0) begin
                    /* act/inact register configuration */
                    case(1)
                        counter_act == 0: begin
                            MOSI <= WRITE_INSTR[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 1;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                        counter_act == 1: begin
                            MOSI <= ACT_INACT_REG_ADDRESS[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 2;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                        counter_act == 2: begin
                            MOSI <= ACT_INACT_REG_CONFIG[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 0;
                                REG_WRITE <= INT1;
                                act_inact_done <= 1;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                    endcase
                    //REG_WRITE <= INT1;
                end else begin
                    REG_WRITE <= IDLE;
                end
            end
            INT1: begin
                if(eoi == 0) begin
                    /* interrupt 1 pin register configuration */
                    case(1)
                        counter_act == 0: begin
                            MOSI <= WRITE_INSTR[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 1;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                        counter_act == 1: begin
                            MOSI <= INT_MAP1_REG_ADDRESS[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 2;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                        counter_act == 2: begin
                            MOSI <= INT_MAP1_REG_CONFIG[7-counter_write];
                            if(counter_write == 3'b111) begin
                                counter_act <= 0;
                                REG_WRITE <= MOSI_DATA;
                                int1_done <= 1;
                            end else begin
                                counter_act <= counter_act;
                            end
                        end
                    endcase
                    //REG_WRITE <= MOSI_DATA;
                end else begin
                    REG_WRITE <= IDLE;
                end
            end
            MOSI_DATA: begin
                if(eoi == 0) begin
                    if (cont == 0) begin
                        if (cont2 <= 7 && cont2 >= 0)
                            MOSI <= read [cont2];
                        else if (cont2 <= 15 && cont2 > 7)
                            MOSI <= adress_yl [cont2-8];
                        else if (cont2 <= 23 && cont2 > 15) begin
                            Y[cont2-16] <= MISO;
                        end
                        if (cont2 == 24) begin
                            if (cont3 == 23) begin
                                cont2 <= 0;
                                cont <= cont + 1;
                                flag_clk <= 1;
                                cont3 <= 0;
                            end
                            else begin
                                flag_clk <= 0;
                                cont3 <= cont3 +1;
                            end
                        end
                        else
                            cont2 <= cont2 + 1;
                    end
                    // ===================================================================
                    else if (cont == 1) begin
                        if (cont2 <= 7)
                            MOSI <= read [cont2];
                        else if (cont2 <= 15 && cont2 > 7)
                            MOSI <= adress_yh [cont2-8];
                        else if (cont2 <= 23 && cont2 > 19) begin
                            Y[cont2-12] <= MISO;
                        end
                        if (cont2 == 23) begin
                            if (cont3 == 23) begin
                                cont2 <= 0;
                                cont <= cont + 1;
                                flag1 <= 1;
                                flag_clk <= 1;
                                cont3 <= 0;
                            end
                            else begin
                                flag_clk <= 0;
                                cont3 <= cont3 +1;
                            end
                        end
                        else
                            cont2 <= cont2 + 1;
                    end
                    //=====================================================================
                    else if (cont == 2) begin
                        if (cont2 <= 7)
                            MOSI <= read [cont2];
                        else if (cont2 <= 15 && cont2 > 7)
                            MOSI <= adress_zl [cont2-8];
                        else if (cont2 <= 23 && cont2 > 15) begin
                            Z[cont2-16] <= MISO;
                        end
                        if (cont2 == 24) begin
                            if (cont3 == 23) begin
                                cont2 <= 0;
                                cont <= cont + 1;
                                flag_clk <= 1;
                                cont3 <= 0;
                            end
                            else begin
                                flag_clk <= 0;
                                cont3 <= cont3 +1;
                            end
                        end
                        else
                            cont2 <= cont2 + 1;
                    end
                    //======================================================================
                    else if (cont == 3) begin
                        if (cont2 <= 7)
                            MOSI <= read [cont2];
                        else if (cont2 <= 15 && cont2 > 7)
                            MOSI <= adress_zh [cont2-8];
                        else if (cont2 <= 23 && cont2 > 19) begin
                            Z[cont2-12] <= MISO;
                        end
                        if (cont2 == 23) begin
                            if (cont3 == 23) begin
                                cont2 <= 0;
                                cont <= cont + 1;
                                flag2 <= 1;
                                flag_clk <= 1;
                                cont3 <= 0;
                            end
                            else begin
                                flag_clk <= 0;
                                cont3 <= cont3 +1;
                            end
                        end
                        else
                            cont2 <= cont2 + 1;
                    end
                    if (flag1 == 1 && (cont2 == 24)) begin
                        Y_n <= Y;
                        flag1 <= 0;
                    end
                    if (flag2 == 1 && (cont2 == 24)) begin
                        Z_n <= Z;
                        flag2 <= 0;
                    end
                end else begin
                    REG_WRITE <= IDLE;
                end
            end
        endcase
    end else begin
        counter_act <= 0;
        counter_write <= 0;
        REG_WRITE <= 1;
        act_inact_done <= 0;
        int1_done <= 0;
    end	
end

			/*if (cont2 == 23) begin
				cont2 <= 0;
				cont <= cont + 1;
				flag2 <= 1;
			end
			else
				cont2 <= cont2 + 1;*/

endmodule

