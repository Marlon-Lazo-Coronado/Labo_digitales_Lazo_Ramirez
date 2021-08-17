module cache_md_wb #(  parameter n = 32, 
			CACHE_SIZE = 1024,
			BLOCK_SIZE=2,
			MEM_SIZE = 4096)
			(input clk,
			input resetn,
			input mem_valid,
			input mem_ready,
			input [n-1:0]mem_addr,
			input [3:0]mem_wstrb,
			input [n-1:0]mem_wdata,
			input [n-1:0]mem_rdata,
			output reg out_mem_valid,
			output reg out_mem_ready,
			output reg [n-1:0]out_mem_addr,
			output reg [3:0]out_mem_wstrb,
			output reg [n-1:0]out_mem_wdata,
			output reg [n-1:0]out_mem_rdata
			);
//n nùmero de bits
//BLOCK_SIZE cantidad de palabras del bloque
//MEN_SIZE tamaño del cache
//=========================================calculos======================================
parameter ENTRIES = CACHE_SIZE/(BLOCK_SIZE*(n/8)); //cantidad de entradas del cachè
parameter OFFSET = $clog2(BLOCK_SIZE*4); //calculo de los bits para el byte offset
parameter INDEX = $clog2(ENTRIES); //calculo de los bits para el indice
parameter TAG = n-OFFSET-$clog2(ENTRIES); //calculo de los bits para el tag

//=======================================================================================
//=============================definicion de la memoria==================================
reg [n-1:0] memory_blocks [0:(ENTRIES*BLOCK_SIZE)-1];
reg [TAG-1:0] memory_tag [0:ENTRIES-1];
reg [0:0] memory_valid [0:ENTRIES-1];
reg [0:0] memory_dirty [0:ENTRIES-1];
//=======================================================================================

wire [TAG-1:0]cpu_tag;
wire [INDEX-1:0]index;
wire [OFFSET-1-2:0]index_word;//Se resta 2 porque son los que controlan los 4 bytes de la palabra.
wire [n-1:0]index_block_memp;

reg [TAG-1:0]tag;
reg valid;
reg dirty;

reg hit;


reg [n-1:0]hit_cont;
reg [n-1:0]miss_cont;

reg [31:0]debug; //Para debugear
//reg m_read_en;

reg [BLOCK_SIZE-1:0]cont;//Ocupamos que el contador pueda contar mas que los bloques
reg [BLOCK_SIZE-1:0]cont2;
reg hold;

integer i,j;


assign cpu_tag = mem_addr[n-1:INDEX+OFFSET];   //se obtiene el tag de la direcciòn
assign index = mem_addr[INDEX+OFFSET-1:OFFSET];    //se obtiene el indice para indexar la memoria
assign index_word = mem_addr[OFFSET-1:2];    //Se obtiene el indice de la palabra
assign index_block_memp[n-1:OFFSET] = mem_addr[n-1:OFFSET];   //se obtiene el indice del bloque a reemplazar en memoria principal.
assign index_block_memp[OFFSET-1:0] = 0;

//inicializacion de las memorias
initial begin
	for (i = 0; i < ENTRIES; i = i + 1) begin
		memory_tag[i] = 0;
		memory_valid[i] = 0;
		memory_dirty[i] = 0;
    	end
    	for (j=0; j < ENTRIES*BLOCK_SIZE; j=j+1) begin
		memory_blocks[j] = 32'h0000_0000;
    	end
    	cont = 0;
    	cont2 = 0;
    	hold =0;
end


always @(*) begin
	if (resetn == 0) begin
		hit = 0;
		tag = 0;
		valid = 0;
		dirty = 0;
	end
	else begin
		tag = memory_tag [index];
		valid = memory_valid [index];
		dirty = memory_dirty [index];
		
		if ((tag == cpu_tag) && valid) begin
			hit = 1;
		end
		else begin 
			hit = 0;
		end
	end
end

always @(posedge clk) begin
		
if (resetn == 0) begin
	out_mem_rdata <= 0;
	out_mem_ready <= 0;
	out_mem_valid <= 0;
	out_mem_wstrb <= 0;		
	out_mem_addr <= 0;
	out_mem_wdata <= 0;
	hit_cont <= 0;
	miss_cont <= 0;
end	

else begin
	if ((tag == cpu_tag) && valid) begin
		hit_cont <= hit_cont + 1;
		miss_cont <= miss_cont;
	end
	else begin 
		hit_cont <= hit_cont;
		miss_cont <= miss_cont + 1;
	end

	if (out_mem_ready == 1)
		out_mem_ready <= 0;
	else 
		out_mem_ready <= out_mem_ready;
	if(mem_valid==0) begin
		out_mem_ready <= 0;
		out_mem_valid <= 0;
	end
		
	else begin if (mem_valid && !out_mem_ready && (mem_wstrb==0) /*&& ((mem_addr >> 2) < MEM_SIZE)*/) begin
		if (hit) begin
			//me muevo cantidad de bloques multiplicado por la cantidad de palabras que contiene mas el indice de palabra
			out_mem_rdata <= memory_blocks [index*BLOCK_SIZE+index_word]; //((index-1)*BLOCK_SIZE)+index_word-1
			debug <= index*BLOCK_SIZE+index_word;
			out_mem_ready <= 1;
			out_mem_valid <= 0;
			out_mem_wdata <= 0; //para no dejar sin valor
		end
		else begin//miss
			if (dirty==0) begin //Solo traemos el bloque de memoria
				if(cont<BLOCK_SIZE) begin
					out_mem_wstrb <= 0;  //Le decimos a MP que queremos leer
					out_mem_ready <= 1'b0; //Le decimos al CPU que espere
					//out_mem_rdata <= 0;
					if (mem_ready) begin
						out_mem_addr <= index_block_memp+(cont+1)*4; //direccion base màs cada 4. (cont+1) por t
						memory_blocks [index*BLOCK_SIZE+cont] <= mem_rdata;//((index-1)*BLOCK_SIZE)+cont-1
						cont <= cont + 1;
						if (cont==BLOCK_SIZE-1)
							out_mem_valid <= 0;
						else
							out_mem_valid <= 1; //mantenemos solicitud
					end
					else begin
						out_mem_addr <= index_block_memp+cont*4; //cont no cambia con el reloj
						//para no dejarlo sin asignar
						memory_blocks[index*BLOCK_SIZE+cont]<=memory_blocks[index*BLOCK_SIZE+cont];
						cont <= cont;
						out_mem_valid <= 1;
					end
				end
				else begin
					cont <= 0; //reseteamos
					out_mem_wstrb <= 4'b0000; //Para no dejarlo implicito
					//enviamos el dato al cpu
					out_mem_rdata <= memory_blocks [index*BLOCK_SIZE+index_word];
					out_mem_ready <= 1;
					memory_valid [index] <= 1;
					//memory_dirty [index] <= 0;
					out_mem_wdata <= 0; //para no dejar sin valor
					out_mem_valid <= 0;
					memory_tag [index] <= cpu_tag; //reemplazamos el tag para el caso de dirty = 1
					debug <= index*BLOCK_SIZE+index_word;
				end
			end
			else begin //hay que guardar el bloque en MP
				if((cont<BLOCK_SIZE)/* && hold!=1*/) begin
					out_mem_wstrb <= 4'b1111;   //Le decimos a MP que queremos escribir
					out_mem_ready <= 1'b0; //Le decimos al CPU que espere
					out_mem_valid <= 1'b1;
					//out_mem_rdata <= 0;
					if (mem_ready) begin
						out_mem_addr <= {tag,index,index_block_memp[OFFSET-1:0]}+(cont+1)*4; //index_block_memp=0
						out_mem_wdata <= memory_blocks [index*BLOCK_SIZE+cont];
						cont <= cont + 1;
						if (cont==BLOCK_SIZE-1) begin
							out_mem_valid <= 1'b0;
							//hold <= 1;
						end
						else begin
							out_mem_valid <= 1'b1; //mantenemos solicitud
							//hold <= 0;
						end
					end
					else begin
						out_mem_addr <= {tag,index,index_block_memp[OFFSET-1:0]}+cont*4;
						//para no dejarlo sin asignar, cont no aumenta con el clock
						out_mem_wdata <= memory_blocks [index*BLOCK_SIZE+cont];
						cont <= cont;
					end
				end
				else begin
				//===============================traemos el bloque, no se si esta parte del codigo redunde==============
				if((cont2<BLOCK_SIZE)/* || hold==1*/) begin
					out_mem_wstrb <= 0;  //Le decimos a MP que queremos leer
					out_mem_ready <= 1'b0; //Le decimos al CPU que espere
					out_mem_rdata <= 0;
					if (mem_ready) begin
						out_mem_addr <= index_block_memp+(cont2+1)*4; //direccion base màs cada 4.
						memory_blocks [index*BLOCK_SIZE+cont2] <= mem_rdata;//suma i al bloque de mp.
						cont2 <= cont2 + 1;
						if (cont2==BLOCK_SIZE-1)
							out_mem_valid <= 0;
						else
							out_mem_valid <= 1; //mantenemos solicitud
					end
					else begin
						out_mem_addr <= index_block_memp+cont2*4; //cont no cambia con el reloj
						//para no dejarlo sin asignar
						memory_blocks[index*BLOCK_SIZE+cont2]<=memory_blocks[index*BLOCK_SIZE+cont2];
						cont2 <= cont2;
						out_mem_valid <= 1;
					end
				end
				else begin
					//hold <= 0;
					cont <= 0; //reseteamos
					cont2 <= 0;
					out_mem_wstrb <= 4'b0000; //Para no dejarlo implicito
					//enviamos el dato al cpu
					out_mem_rdata <= memory_blocks [index*BLOCK_SIZE+index_word];
					out_mem_ready <= 1'b1;
					out_mem_valid <= 0;
					memory_valid [index] <= 1'b1; //no se por que pero el ejemplo lo puso en cero.
					memory_tag [index] <= cpu_tag; //reemplazamos el tag para el caso de dirty = 1
					memory_dirty [index] <= 0;  //Los datos que trajimos estan en MP
					out_mem_wdata <= 1'b0; //para no dejar sin valor
				end
				//=================================================================================================	
				end
			end
		end
	end
	
	else if(mem_valid && !out_mem_ready && (mem_wstrb!=0) /*&& (mem_addr >> 2) < MEM_SIZE*/) begin
	
	//m_read_en <= 1;
	
	if (hit) begin //No hay que guardar el bloque porque aunque este sucio, si se escribe queda el dato màs actualizado en el cachè
			memory_blocks [index*BLOCK_SIZE+index_word] <= mem_wdata;
			memory_dirty [index] <= 1;
			out_mem_ready <= 1'b1;
			memory_valid [index] <= 1;
			out_mem_rdata <= 0; //para no dejar sin valor
			out_mem_wdata <= 0;
			out_mem_valid <= 0;
			cont <= 0;
			cont2 <= 0;
	end
	else begin //escribimos de una vez en MP y en cache, hay que preguntar si esta sucio, pero de momento probemos asi.
		
		if (dirty == 0) begin //Si el dato es invalido, lo reemplamos de una
			if(cont<BLOCK_SIZE) begin
				out_mem_wstrb <= 0;  //Le decimos a MP que queremos leer
				out_mem_ready <= 1'b0; //Le decimos al CPU que espere
				//out_mem_rdata <= 0;
				if (mem_ready) begin
					out_mem_addr <= index_block_memp+(cont+1)*4; //direccion base màs cada 4. (cont+1) por t
					memory_blocks [index*BLOCK_SIZE+cont] <= mem_rdata;//((index-1)*BLOCK_SIZE)+cont-1
					cont <= cont + 1;
					if (cont==BLOCK_SIZE-1)
						out_mem_valid <= 0;
					else
						out_mem_valid <= 1; //mantenemos solicitud
				end
				else begin
					out_mem_addr <= index_block_memp+cont*4; //cont no cambia con el reloj
					//para no dejarlo sin asignar
					memory_blocks[index*BLOCK_SIZE+cont]<=memory_blocks[index*BLOCK_SIZE+cont];
					cont <= cont;
					out_mem_valid <= 1;
				end
			end
			else begin
				cont <= 0; //reestablecemos
				out_mem_ready <= 1'b1;
				out_mem_wstrb <= 4'b0000; //dejamos de escribir
				memory_dirty [index] <= 1; //seguimos con miss pero el dirty en 0, va a la condicion de lectura
				memory_valid [index] <= 1; //<<<<<No entiendo bien este valid>>>>>>>
				memory_tag [index] <= cpu_tag; //reemplazamos el tag para el caso de dirty = 1
				memory_blocks [index*BLOCK_SIZE+index_word] <= mem_wdata;
				out_mem_rdata <= 0; //para no dejar sin valor
				out_mem_wdata <= 0;
				out_mem_valid <= 0;
			end
		end
		else begin if(cont<BLOCK_SIZE) begin
			out_mem_wstrb <= 4'b1111;   //Le decimos a MP que queremos escribir
			out_mem_ready <= 1'b0; //Le decimos al CPU que espere
			out_mem_valid <= 1'b1;
			if (mem_ready) begin
				out_mem_addr <= {tag,index,index_block_memp[OFFSET-1:0]}+(cont+1)*4;
				out_mem_wdata <= memory_blocks [index*BLOCK_SIZE+cont];
				cont <= cont + 1;
			end
			else begin
				out_mem_addr <= {tag,index,index_block_memp[OFFSET-1:0]}+cont*4;
				//para no dejarlo sin asignar, cont no aumenta con el clock
				out_mem_wdata <= memory_blocks [index*BLOCK_SIZE+cont];
				cont <= cont;
			end
		end
		else begin
			//Ahora se trae el bloque que correponde de MP para el dato que se quiere escribir
			if(cont2<BLOCK_SIZE) begin
				out_mem_wstrb <= 0;  //Le decimos a MP que queremos leer
				out_mem_ready <= 0; //Le decimos al CPU que espere
				out_mem_valid <= 1;
				if (mem_ready) begin
					out_mem_addr <= index_block_memp+((cont2+1)*4); //direccion base màs cada 4.
					memory_blocks [index*BLOCK_SIZE+cont2] <= mem_rdata;
					cont2 <= cont2 + 1;
					if (cont2==BLOCK_SIZE-1)
						out_mem_valid <= 1'b0;
					else
						out_mem_valid <= 1'b1; //mantenemos solicitud
				end
				else begin
					out_mem_addr <= index_block_memp+(cont2*4); //cont no cambia con el reloj
					//para no dejarlo sin asignar
				memory_blocks[index*BLOCK_SIZE+cont2]<=memory_blocks[index*BLOCK_SIZE+cont2];
					cont2 <= cont2;
					out_mem_valid <= 1;
				end
			end
			else begin
			cont <= 0; //reestablecemos
			cont2 <= 0;
			out_mem_ready <= 1'b1;
			out_mem_wstrb <= 4'b0000; //dejamos de escribir
			memory_dirty [index] <= 1'b1; //seguimos con miss pero el dirty en 0, va a la condicion de lectura
			memory_valid [index] <= 1'b1; //<<<<<No entiendo bien este valid>>>>>>>
			memory_tag [index] <= cpu_tag; //reemplazamos el tag para el caso de dirty = 1
			memory_blocks [index*BLOCK_SIZE+index_word] <= mem_wdata;
			out_mem_rdata <= 0; //para no dejar sin valor
			out_mem_wdata <= 0;
			out_mem_valid <= 0;
			end	
		end
		end
	end
	end	
	end
//endcase
end //else del (!resen)

end// del always






endmodule
