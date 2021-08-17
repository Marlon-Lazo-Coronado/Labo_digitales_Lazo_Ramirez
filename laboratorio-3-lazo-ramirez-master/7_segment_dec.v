module segmentdec (	input clk,
			input resetn,
			input [31:0] num_bit,
			output reg [7:0]anodo,
			output reg [7:0]catodo
			);


reg clk12;
reg [31:0]counter;


always @(posedge clk) begin

	if (resetn == 0)
		clk12 <= 0;
	else begin

            if(counter == 5000) begin
                clk12 <= ~clk12;
                counter <= 0;
            end 
            else begin
                clk12 <= clk12;
                counter <= counter + 1;
            end
       end
end

parameter R7 = 10000000;
parameter R6 = 1000000;
parameter R5 = 100000;
parameter R4 = 10000;
parameter R3 = 1000;
parameter R2 = 100;
parameter R1 = 10;


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


reg [7:0] cont0;
reg [7:0] cont1;
reg [7:0] cont2;
reg [7:0] cont3;
reg [7:0] cont4;
reg [7:0] cont5;
reg [7:0] cont6;
reg [7:0] cont7;

reg [7:0] cont0_Aux;
reg [7:0] cont1_Aux;
reg [7:0] cont2_Aux;
reg [7:0] cont3_Aux;
reg [7:0] cont4_Aux;
reg [7:0] cont5_Aux;
reg [7:0] cont6_Aux;
reg [7:0] cont7_Aux;

reg [31:0] num6;
reg [31:0] num5;
reg [31:0] num4;
reg [31:0] num3;
reg [31:0] num2;
reg [31:0] num1;
reg [31:0] num0;

reg [31:0] res7;
reg [31:0] res6;
reg [31:0] res5;
reg [31:0] res4;
reg [31:0] res3;
reg [31:0] res2;
reg [31:0] res1;
reg [31:0] res0;

reg flag1;reg flag2;reg flag3;reg flag4;reg flag5;reg flag6;reg flag7;


reg [31:0] catodo_Aux;
reg [2:0] anodo_Aux;


always @(*) begin

	if (resetn==0) begin
		anodo = 0;
		catodo = 0;
	end
	else begin
	
	if (anodo_Aux == 7)
			anodo = 8'b01111111;
		else begin
			if (anodo_Aux == 6)
				anodo = 8'b10111111;
			else begin
				if (anodo_Aux == 5)
					anodo = 8'b11011111;
				else begin
					if (anodo_Aux == 4)
						anodo = 8'b11101111;
					else begin
						if (anodo_Aux == 3)
							anodo = 8'b11110111;
						else begin
							if (anodo_Aux == 2)
								anodo = 8'b11111011;
							else begin
								if (anodo_Aux == 1)
									anodo = 8'b11111101;
								else
									anodo = 8'b11111110;
							end
						end
					end
				end
			end
		end
	
	

if (catodo_Aux == 9)
	catodo = NINE;
else begin
	if (catodo_Aux == 8)
		catodo = EIGHT;
	else begin
		if (catodo_Aux == 7)
			catodo = SEVEN;
		else begin
			if (catodo_Aux == 6)
				catodo = SIX;
			else begin
				if (catodo_Aux == 5)
					catodo = FIVE;
				else begin
					if (catodo_Aux == 4)
						catodo = FOUR;
					else begin
						if (catodo_Aux == 3)
							catodo = THREE;
						else begin
							if (catodo_Aux == 2)
								catodo = TWO;
							else begin
								if (catodo_Aux == 1)
									catodo = ONE;
								else
									catodo = ZERO;
							end
						end
					end
				end
			end
		end
	end
end

end
end

always @(posedge clk12) begin

	if (resetn == 0) begin

		cont0 <= 0; cont1 <= 0; cont2 <= 0; cont3 <= 0; cont4 <= 0; cont5 <= 0; cont6 <= 0; cont7 <= 0;
		
		cont7_Aux <= 0;cont6_Aux <= 0;cont5_Aux <= 0;cont4_Aux <= 0;cont3_Aux <= 0;cont2_Aux <= 0;cont1_Aux <= 0;cont0_Aux <= 0;
		
		res7 <= 0; res6 <= 0; res5 <= 0; res4 <= 0; res3 <= 0; res2 <= 0; res1 <= 0; res0 <= 0;
		
		num6 <= 0; num5 <= 0; num4 <= 0; num3 <= 0; num2 <= 0; num1 <= 0; num0 <= 0;
		
		anodo_Aux <= 0; catodo_Aux <= 0;
		
		flag1 <= 0;flag2 <= 0;flag3 <= 0;flag4 <= 0;flag5 <= 0;flag6 <= 0;flag7 <= 0;
	end

	else begin
	
		if (num_bit > 99999999) begin
			
			anodo_Aux <= anodo_Aux + 1; catodo_Aux <= 9;
			
		cont0 <= 0; cont1 <= 0; cont2 <= 0; cont3 <= 0; cont4 <= 0; cont5 <= 0; cont6 <= 0; cont7 <= 0;
		cont7_Aux <= 0;cont6_Aux <= 0;cont5_Aux <= 0;cont4_Aux <= 0;cont3_Aux <= 0;cont2_Aux <= 0;cont1_Aux <= 0;cont0_Aux <= 0;
		res7 <= 0; res6 <= 0; res5 <= 0; res4 <= 0; res3 <= 0; res2 <= 0; res1 <= 0; res0 <= 0;
		num6 <= 0; num5 <= 0; num4 <= 0; num3 <= 0; num2 <= 0; num1 <= 0; num0 <= 0;
		flag1 <= 0;flag2 <= 0;flag3 <= 0;flag4 <= 0;flag5 <= 0;flag6 <= 0;flag7 <= 0;
		
		end
		
		else begin
		//=============================D7=============================
		if (num_bit >= R7) begin
		if (flag7 == 0) begin
			res7 <= num_bit - R7*cont7;
			cont7 <= cont7 + 1;
			if (R7 > res7)
				flag7 <= 1;
			else
				flag7 <= 0;
		end
		else begin
			num6 <= res7;
			res7 <= 0;
			cont7 <= 0;
			flag7 <= 0;
			cont7_Aux <= cont7;
		end
		end
		else begin num6 <= num_bit; end
		//=============================D6=============================
		if (num6 >= R6) begin
		if (flag6 == 0) begin
			res6 <= num6 - R6*cont6;
			cont6 <= cont6 + 1;
			if (R6 > res6)
				flag6 <= 1;
			else
				flag6 <= 0;
		end
		else begin
			num5 <= res6;
			res6 <= 0;
			cont6 <= 0;
			flag6 <= 0;
			cont6_Aux <= cont6;
		end
		end
		else begin num5 <= num6; end
		//=============================D5=============================
		if (num5 >= R5) begin
		if (flag5 == 0) begin
			res5 <= num5 - R5*cont5;
			cont5 <= cont5 + 1;	
			if (R5 > res5)
				flag5 <= 1;
			else
				flag5 <= 0;
		end
		else begin
			num4 <= res5;
			res5 <= 0;
			cont5 <= 0;
			flag5 <= 0;
			cont5_Aux <= cont5;
		end
		end
		else begin num4 <= num5; end
		
		//=============================D4=============================
		if (num4 >= R4) begin
		if (flag4 == 0) begin
			res4 <= num4 - R4*cont4;
			cont4 <= cont4 + 1;
			if (R4 > res4)
				flag4 <= 1;
			else
				flag4 <= 0;
		end
		else begin
			num3 <= res4;
			res4 <= 0;
			cont4 <= 0;
			flag4 <= 0;
			cont4_Aux <= cont4;
		end
		end
		else begin num3 <= num4; end
		//=============================D3=============================
		if (num3 >= R3) begin
		if (flag3 == 0) begin
			res3 <= num3 - R3*cont3;
			cont3 <= cont3 + 1;
			if (R3 > res3)
				flag3 <= 1;
			else
				flag3 <= 0;
		end
		else begin
			num2 <= res3;
			res3 <= 0;
			cont3 <= 0;
			flag3 <= 0;
			cont3_Aux <= cont3;
		end
		end
		else begin num2 <= num3; end
		//=============================D2=============================
		if (num2 >= R2) begin
		if (flag2 == 0) begin
			res2 <= num2 - R2*cont2;
			cont2 <= cont2 + 1;
			if (R2 > res2)
				flag2 <= 1;
			else
				flag2 <= 0;
		end
		else begin
			num1 <= res2;
			res2 <= 0;
			cont2 <= 0;
			flag2 <= 0;
			cont2_Aux <= cont2;
		end
		end
		else begin num1 <= num2; end
		//=============================D1=============================
		if (num1 >= R1) begin
		if (flag1 == 0) begin
			res1 <= num1 - R1*cont1;
			cont1 <= cont1 + 1;
			if (R1 > res1)
				flag1 <= 1;
			else
				flag1 <= 0;	
		end
		else begin
			num0 <= res1;
			res1 <= 0;
			cont1 <= 0;
			flag1 <= 0;
			cont1_Aux <= cont1;
		end
		end
		else begin num0 <= num1; end
		//=============================D0=============================
		
		cont7_Aux <= num0;
		
		anodo_Aux <= anodo_Aux + 1;
		
		if (anodo_Aux == 0)
			catodo_Aux <= cont0_Aux;
		else begin
			if (anodo_Aux == 1)
				catodo_Aux <= cont1_Aux;
			else begin
				if (anodo_Aux == 2)
					catodo_Aux <= cont2_Aux;
				else begin
					if (anodo_Aux == 3)
						catodo_Aux <= cont3_Aux;
					else begin
						if (anodo_Aux == 4)
							catodo_Aux <= cont4_Aux;
						else begin
							if (anodo_Aux == 5)
								catodo_Aux <= cont5_Aux;
							else begin
								if (anodo_Aux == 6)
									catodo_Aux <= cont6_Aux;
								else
									catodo_Aux <= cont7_Aux;
							end
						end
					end
				end
			end
		end	
		
		
		end
	end

end
endmodule
