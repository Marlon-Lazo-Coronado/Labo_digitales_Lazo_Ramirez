//Modulo que realiza la operacion suma
module Sumador (output out, output carry_out, input a,
    		input b, input carry_in);
assign {carry_out, out } = a + b + carry_in;
endmodule


//Modulo que realiza la operacion multiplicacion
module arr_multiplier_4b #(parameter n=32, k=64)(input reset, input [n-1:0]A,
		input [n-1:0]B, output [k-1:0]Out);
wire T = 0;
//reg temp;
//Los cables se dimensionan diferente, hay que ponerle el valor sin contar el cero
wire [n-1:0]C[n:0];
wire [n-1:0]sum[n-1:0]; //Le quito el bit de a0&b0 y el de carry_out
wire [k-1:0] bits;

assign bits[0] = A[0]&B[0];

assign Out = (~reset)? 'h00000000 : bits;

genvar i, j;
generate

for (i=0; i <= n-2; i=i+1) begin
	for (j=0; j <= n-1; j=j+1) begin
		//PRIMERA FILA
		if (i == 0) begin
			//matris [0:0] primera esquina
			if (j == 0) begin
				Sumador celda (.a(A[j]&B[i+1]), .b(B[0]&A[j+1]), .carry_in(T), .out(bits[i+1]), .carry_out(C[i][j]));
			end
			//matris [0:n-1]
			else if (j == n-1)
				Sumador celda (.a(A[j]&B[i+1]), .b(T), .carry_in(C[i][j-1]), .out(sum[i][j]), .carry_out(C[i][j]));
			else
				Sumador celda(.a(A[j]&B[i+1]),.b(B[0]&A[j+1]),.carry_in(C[i][j-1]),.out(sum[i][j]),.carry_out(C[i][j]));
		end
		//ULTIMA FILA
		else if (i == n-2) begin
			//matris [n-2:0]
			if (j == 0)
				//Ultima esquina el primer bit es para el cable con la and
				Sumador celda (.a(A[j]&B[i+1]),.b(sum[i-1][j+1]),.carry_in(T),.out(bits[i+1]),.carry_out(C[i][j]));
			else if (j == n-1)
				//Ultima esquina el primer bit es para el cable con la and
				Sumador celda (.a(A[j]&B[i+1]),.b(C[i-1][j]),.carry_in(C[i][j-1]),.out(bits[j+n-1]), .carry_out(bits[k-1]));
			else
				//Ultima fila
				Sumador celda(.a(A[j]&B[i+1]),.b(sum[i-1][j+1]),.carry_in(C[i][j-1]),.out(bits[j+n-1]),.carry_out(C[i][j]));
		end
		else if ((j == n-1) && (i != 0) && (i != n-2))
			//Esquinas derechas
			Sumador celda (.a(A[j]&B[i+1]),.b(C[i-1][j]),.carry_in(C[i][j-1]),.out(sum[i][j]),.carry_out(C[i][j]));
		else if ((j == 0) && (i != 0) && (i != n-2))
			//Esquinas izquierdas
			Sumador celda (.a(A[j]&B[i+1]),.b(sum[i-1][j+1]),.carry_in(T),.out(bits[i+1]),.carry_out(C[i][j]));
		else
			Sumador celda(.a(A[j]&B[i+1]),.b(sum[i-1][j+1]),.carry_in(C[i][j-1]),.out(sum[i][j]),.carry_out(C[i][j]));
	end
end
endgenerate
endmodule
