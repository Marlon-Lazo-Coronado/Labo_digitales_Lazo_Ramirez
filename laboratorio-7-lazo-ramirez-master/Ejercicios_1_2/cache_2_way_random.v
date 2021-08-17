module cache_2_way_random #(parameter CACHE_SIZE=1024, parameter BLOCK_SIZE=4*2, parameter WAY_SIZE=2)(//Ambos Bytes(
    input 	      clk,
    input 	      resetn,
    //Registers
    input mem_valid,
    input mem_intr,
    output reg mem_ready,
    input [31:0] mem_addr,
    input [31:0] mem_wdata,
    input [3:0] mem_wstrb,
    output reg [31:0] mem_rdata,
    //Main Memory
    output reg mem_valid_MP,
    // output mem_instr_MP,
    input mem_ready_MP,
    output reg [31:0] mem_addr_MP,
    output reg [31:0] mem_wdata_MP,
    output reg [3:0]  mem_wstrb_MP,
    input [31:0] mem_rdata_MP,
    output reg [20:0] hits,
    output reg [20:0] miss
);

    //Parametros de cache
    parameter WORD_SIZE = 4;
    parameter WORD_BIT_SIZE = 8*WORD_SIZE;
    parameter NUM_BLOCK  = (CACHE_SIZE/BLOCK_SIZE)/WAY_SIZE; //por ser asociativo
    parameter OFFSET_SIZE = $clog2(BLOCK_SIZE);
    parameter WORDS_BLOCK = BLOCK_SIZE/WORD_SIZE;
    parameter INDEX_SIZE = $clog2(NUM_BLOCK);
    parameter TAG_SIZE = 32-INDEX_SIZE-OFFSET_SIZE;
    parameter CACHE_TAG_SIZE = 1+1+1+TAG_SIZE; // db + valid + LRU + tag
    parameter DISPLACEMENT = NUM_BLOCK;

    //States
    parameter IDLE = 1;
    parameter VALID_MEM = 2;
    parameter READ = 4;
    parameter WRITE = 8;
    parameter READ_MISS = 16;
    parameter WRITE_MISS = 32;
    parameter MEM_ACCESS = 64;
    parameter MEM_WRITE = 128;
    parameter WRITE_BACK = 256;

    //Arreglo de entradas de cache
    //DB+VB+LRU+TAG
    //Direcciones de las vias, solo ensanchamos la memoria, agrandandola verticalmente!
    reg [CACHE_TAG_SIZE-1:0] reg_address[NUM_BLOCK*WAY_SIZE-1:0]; //Para guardar las demas vias

    //DATOS
    //Arreglo de datos en cada entrada
    reg [32-1:0] cache_data[WORDS_BLOCK-1:0][NUM_BLOCK*WAY_SIZE-1:0];//Igual, de reducenlas entradas y de ensanchan los bits.
    wire [TAG_SIZE-1:0] tag;
    wire [INDEX_SIZE-1:0] index;
    wire [OFFSET_SIZE-1:0] offset;
    reg dato0Valid, ReadWrite_Flag, MemoryRW;
    reg [8:0] STATE;
    reg [31:0] temporal_address;
    reg [OFFSET_SIZE-1:0] offset_temp;
    reg [OFFSET_SIZE:0] blockCounter;
    reg read_miss_flag;
    reg [31:0] temporal_address_W;
    reg [OFFSET_SIZE-3:0] offset_temp_w;
    reg [OFFSET_SIZE:0] counter_W;
    reg [WAY_SIZE-1:0]cont; //Contador de vias
    reg [WAY_SIZE-1:0]way_select;
    reg flag;
    reg [$clog2(WAY_SIZE)-1:0]ramdom;
    reg [$clog2(WAY_SIZE)-1:0]ramdom_copy;
    reg hit_flag;
    reg [31:0]reg_ramdom;
    
    assign tag = mem_addr[31:32-TAG_SIZE];
    assign index = mem_addr[INDEX_SIZE+OFFSET_SIZE-1:OFFSET_SIZE];
    assign offset = mem_addr[OFFSET_SIZE-1:0];

    integer i,j;
    always @(posedge clk) begin
        if (resetn == 0) begin
            hits <= 0;
            miss <= 0;
            cont <= 0;
            way_select <= 0;
            reg_ramdom <= 32'h0001_3FFC; //Semilla del circuito aleatorio
            STATE <= IDLE;
            for (i = 0; i < NUM_BLOCK; i = i + 1) begin
                reg_address[i] <= 0;
            end
        end else begin 
        	//Circuito aleatorio para reemplazar, Se selecciona el bit 31 y 29 de la semilla, luego se desplazan al campo
        	// del bit lsb y se hace una xor, luego se agrega a la semilla desplazada, mediante una or.
        	reg_ramdom <= (((reg_ramdom & 32'h8000_0000)>>31) ^ ((reg_ramdom & 32'h2000_0000)>>29)) | (reg_ramdom<<1);
        	//Se pasa el dato aleatorio
        	ramdom <= reg_ramdom[$clog2(WAY_SIZE)-1:0];
        
        	//==========================================================================================================
            case (STATE)
                IDLE: begin
                    mem_ready <= 0;
                    STATE <= VALID_MEM;
                end
                VALID_MEM: begin
                    if (mem_valid)  begin
                        if (|mem_wstrb)  begin
                            STATE <= WRITE;
                        end
                        if (!mem_wstrb) begin
                            STATE <= READ;
                        end
                    end
                end
                //====================================================================================================================
                READ: begin
                read_miss_flag <= 0;
                	
                	if(cont < WAY_SIZE) begin
                		cont <= cont+1;
                		if (reg_address[index+cont*DISPLACEMENT][TAG_SIZE-1:0] == tag && reg_address[index+cont*DISPLACEMENT][CACHE_TAG_SIZE-2]) begin
                			way_select <= cont;
                			hit_flag <= 1;
                		end
                		else
                			way_select <= way_select;
                	end
                    
                    else begin
                    	if(reg_address[index+way_select*DISPLACEMENT][TAG_SIZE-1:0]==
                    	tag && reg_address[index+way_select*DISPLACEMENT][CACHE_TAG_SIZE-2] && hit_flag)begin
                      		mem_ready <= 1;
	             		mem_rdata <= cache_data[offset>>2][index+way_select*DISPLACEMENT];   
                     		reg_address[index+way_select*DISPLACEMENT][CACHE_TAG_SIZE-3] <= 0;
                      		STATE <= IDLE;
                     		hits <= hits +1;
                     		cont <= 0;
                     		hit_flag <= 0;
                    	end
                    else begin //Miss
                        
                        miss <= miss + 1;
                        temporal_address <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
                        offset_temp <= 0;
                        blockCounter <= 0;
                        offset_temp_w <= 0;
                        counter_W <= 0;
                        
                        hit_flag <= 0;
                        cont <= 0;
                        ramdom_copy <= ramdom;
                        
                        if(!reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2])begin
                            
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2] <= 1'b1;
                            reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0] <= tag;
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-3] <= 0;
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1] <= 0;
                            STATE <= READ_MISS;
                        end else begin
                            if (reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1]) begin
                                STATE <= WRITE_BACK;
                                temporal_address_W <= ((reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0]<<(INDEX_SIZE))+index)<<OFFSET_SIZE;
                            end else begin
                                STATE <= READ_MISS;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2] <= 1'b1;
                                reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0] <= tag;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-3] <= 0;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1] <= 0;
                            end
                        end
                    end
                    end
                end
                WRITE: begin
                read_miss_flag <= 1;
                
                if(cont < WAY_SIZE) begin
                	cont <= cont+1;
                	if (reg_address[index+cont*DISPLACEMENT][TAG_SIZE-1:0] == tag && reg_address[index+cont*DISPLACEMENT][CACHE_TAG_SIZE-2]) begin
                		way_select <= cont;
                		hit_flag <= 1;
                	end
              		else
                		way_select <= way_select;
                end
                else begin
                    if(reg_address[index+way_select*DISPLACEMENT][TAG_SIZE-1:0] == 
                    tag && reg_address[index+way_select*DISPLACEMENT][CACHE_TAG_SIZE-2] && hit_flag)begin
                        cache_data[offset>>2][index+way_select*DISPLACEMENT] <= mem_wdata;
                        mem_ready <= 1;
                        reg_address[index+way_select*DISPLACEMENT][CACHE_TAG_SIZE-3] <= 0;
                        reg_address[index+way_select*DISPLACEMENT][CACHE_TAG_SIZE-1] <= 1;
                        STATE <= IDLE;
                        hits <= hits + 1;
                        
                        hit_flag <= 0;
                        cont <= 0;

                    end else begin
                        miss <= miss + 1;
                        
                        temporal_address <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
                        offset_temp <= 0;
                        blockCounter <= 0;
                        offset_temp_w <= 0;
                        counter_W <= 0;
                        
                        hit_flag <= 0;
                        ramdom_copy <= ramdom;
                        cont <= 0;
                        
                        if (!reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2]) begin // valid
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2] <= 1'b1; //valid
                            reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0] <= tag;
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-3] <= 0;
                            reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1] <= 1;
                            STATE <= WRITE_MISS;
                        end else begin //LRU 
                            if (reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1]) begin //db
                                STATE <= WRITE_BACK;
                                temporal_address_W = ((reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0]<<(INDEX_SIZE))+index)<<OFFSET_SIZE;
                            end else begin // db
                                STATE <= WRITE_MISS;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-2] <= 1'b1;
                                reg_address[index+DISPLACEMENT*ramdom][TAG_SIZE-1:0] <= tag;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-3] <= 0;
                                reg_address[index+DISPLACEMENT*ramdom][CACHE_TAG_SIZE-1] <= 1;
                            end
                        end
                    end
                    end
                end
                READ_MISS: begin
                    mem_valid_MP <= 0;
                    if (blockCounter < WORDS_BLOCK) begin
                        STATE <= MEM_ACCESS;
                    end else begin
                        mem_ready <= 1;
                        // reg [31:0] cache_data[WORDS_BLOCK-1:0][NUM_BLOCK-1:0];
                        mem_rdata <= cache_data[offset>>2][index+DISPLACEMENT*ramdom_copy];
                        STATE <= IDLE;
                    end                    
                end
                WRITE_MISS: begin
                    if (blockCounter < WORDS_BLOCK) begin
                        STATE <= MEM_ACCESS;
                    end else begin
                        cache_data[offset>>2][index+DISPLACEMENT*ramdom_copy] <= mem_wdata;
                        mem_ready <= 1;
                        STATE <= IDLE;
                    end
                end
                MEM_ACCESS: begin
                    mem_valid_MP <= 1;
                    mem_addr_MP <= temporal_address;
                    mem_wdata_MP <= mem_wdata;
                    mem_wstrb_MP <= 0;
                    if (mem_ready_MP) begin
                    	mem_valid_MP <= 0;
                        cache_data[offset_temp][index+DISPLACEMENT*ramdom_copy] <= mem_rdata_MP;
                        blockCounter <= blockCounter + 1;
                        offset_temp <= offset_temp + 1;
                        temporal_address <= temporal_address + 4;
                        if (read_miss_flag) begin
                            STATE <= WRITE_MISS;
                        end else begin
                            STATE <= READ_MISS;
                        end
                    end
                end
                MEM_WRITE: begin
                    mem_valid_MP <= 1;
                    mem_addr_MP <= temporal_address_W;
                    mem_wdata_MP <= cache_data[offset_temp_w][index+DISPLACEMENT*ramdom_copy];
                    mem_wstrb_MP <= 4'b1111;
                    if (mem_ready_MP) begin
                    	mem_valid_MP <= 0;
                        counter_W <= counter_W + 1;
                        offset_temp_w <= offset_temp_w + 1;
                        temporal_address_W <= temporal_address_W + 4;
                        STATE <= WRITE_BACK;
                    end                
                end
                WRITE_BACK: begin
                    mem_valid_MP <= 0;
                    if (counter_W < WORDS_BLOCK) begin
                        STATE <= MEM_WRITE;
                    end else if (read_miss_flag) begin
                        STATE <= WRITE;
                        blockCounter <= 0;
                        reg_address[index+DISPLACEMENT*ramdom_copy][CACHE_TAG_SIZE-1] <= 0; // Clean DB
                    end else begin
                        STATE <= READ;
                        blockCounter <= 0;
                        reg_address[index+DISPLACEMENT*ramdom_copy][CACHE_TAG_SIZE-1] <= 0; // Clean DB
                    end
                end
                default: 
                STATE <= IDLE;
            endcase
        end
    end
   
   
   
endmodule

