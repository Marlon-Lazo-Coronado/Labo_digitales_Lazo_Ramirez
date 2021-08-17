module accelerometer_reader (
    input clk,
    input resetn,
    input MISO,

    output reg [15:0] Y_n,
    output reg [15:0] Z_n,
    output reg SCLK,
    output reg	MOSI,
    output reg	 CS
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
end

			/*if (cont2 == 23) begin
				cont2 <= 0;
				cont <= cont + 1;
				flag2 <= 1;
			end
			else
				cont2 <= cont2 + 1;*/

endmodule

