module cache_4_way_lru #(parameter CACHE_SIZE=1024, parameter BLOCK_SIZE=8)(//Ambos Bytes(
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

    //cache size = sets * associativity * block size
    //Parametros de cache
    parameter ASSOCIATIVITY = 4;
    parameter WORD_SIZE = 4;
    parameter WORD_BIT_SIZE = 8*WORD_SIZE;
    parameter NUM_BLOCK  = CACHE_SIZE/(BLOCK_SIZE*ASSOCIATIVITY);
    parameter OFFSET_SIZE = $clog2(BLOCK_SIZE);
    parameter WORDS_BLOCK = BLOCK_SIZE/WORD_SIZE;
    parameter INDEX_SIZE = $clog2(NUM_BLOCK);
    parameter TAG_SIZE = 32-INDEX_SIZE-OFFSET_SIZE;
    parameter CACHE_TAG_SIZE = 1+1+1+1+TAG_SIZE; // db(-1) + valid(-2) + LRU(-3) + LRU(-4)+ tag

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
    reg [CACHE_TAG_SIZE-1:0] reg_address[NUM_BLOCK*ASSOCIATIVITY-1:0];


    //DATOS
    //Arreglo de datos en cada entrada
    reg [31:0] cache_data[WORDS_BLOCK-1:0][NUM_BLOCK*ASSOCIATIVITY-1:0];
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
    // PONERLOS EN RESETN
    reg [1:0] hit_way, eviction_way;
    //reg hit_exist_0, hit_exist_1;
    //reg hit_exist_2, hit_exist_3;
    reg hit_exist;


    assign tag = mem_addr[31:32-TAG_SIZE];
    assign index = mem_addr[INDEX_SIZE+OFFSET_SIZE-1:OFFSET_SIZE];
    assign offset = mem_addr[OFFSET_SIZE-1:0];

    integer i,j;
    always @(posedge clk) begin
        if (resetn == 0) begin
            hits <= 0;
            miss <= 0;
            hit_way <= 0;
            hit_exist <= 0;
            //hit_exist_1 <= 0;
            //hit_exist_2 <= 0;
            //hit_exist_3 <= 0;
            STATE <= IDLE;
            for (i = 0; i < NUM_BLOCK*ASSOCIATIVITY; i = i + 1) begin
                reg_address[i] <= 0;
                reg_address[i][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 3;
            end
        end else begin 
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
                READ: begin
                read_miss_flag <= 0;
                    // get hit way (if exists)
                    case (1)
                        reg_address[index*ASSOCIATIVITY+0][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+0][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 0;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+1][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+1][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 1;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+2][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+2][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 2;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+3][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+3][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 3;
                            hit_exist <= 1;
                        end
                    endcase
                    if (hit_exist) begin //hit
                        // reg [31:0] cache_data[WORDS_BLOCK-1:0][NUM_BLOCK-1:0];
                        mem_ready <= 1;
	                    mem_rdata <= cache_data[offset>>2][index*ASSOCIATIVITY+hit_way];   
                        // LRU bit actualize.
                        //reg_address[index*ASSOCIATIVITY+hit_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                        // LRU bit actualize
                        
                        
                        for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                            if(j != hit_way) begin
                                if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                end else begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                end                        
                            end else begin
                                reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                            end
                        end 

                        STATE <= IDLE;
                        hits <= hits + 1;
                        // hit buses reset
                        //hit_way <= 0;
                        hit_exist <= 0;
                        //hit_exist_0 <= 0;
                        //hit_exist_1 <= 0;
                       // hit_exist_2 <= 0;
                        //hit_exist_3 <= 0;
                    end
                    else begin //Miss
                        // eviction way
                        case (1)
                            reg_address[index*ASSOCIATIVITY+0][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 0;
                            end
                            reg_address[index*ASSOCIATIVITY+1][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 1;
                            end
                            reg_address[index*ASSOCIATIVITY+2][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 2;
                            end
                            reg_address[index*ASSOCIATIVITY+3][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 3;
                            end
                        endcase

                        miss <= miss + 1;
                        temporal_address <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
                        offset_temp <= 0;
                        blockCounter <= 0;
                        offset_temp_w <= 0;
                        counter_W <= 0;

                        if(!reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2])begin
                            reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2] <= 1'b1;                // valid
                            reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0] <= tag;                     // tag

                            // LRU bit actualize (Same for)
                            //reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;  // LRU bit
                            
                            
                            for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                                if(j != eviction_way) begin
                                    if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                    end else begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                    end                        
                                end else begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                                end
                            end 

                            reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 0;                   // dirty
                            STATE <= READ_MISS;
                        end else begin  // valid
                            if (reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1]) begin  // dirty block
                                STATE <= WRITE_BACK;
                                temporal_address_W <= ((reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0]<<(INDEX_SIZE))+index*ASSOCIATIVITY+eviction_way)<<OFFSET_SIZE;
                            end else begin
                                STATE <= READ_MISS;
                                reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2] <= 1'b1;                // valid
                                reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0] <= tag;                     // tag

                                // LRU bit actualize (same for)
                                //reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;  // LRU bit

                                
                                for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                                    if(j != eviction_way) begin
                                        if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                            reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                        end else begin
                                            reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                        end                        
                                    end else begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                                    end
                                end     

                                reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 0;                   // dirty
                            end
                        end
                    end
                end
                WRITE: begin
                read_miss_flag <= 1;
                    // get hit way (if exists)
                    case (1)
                        reg_address[index*ASSOCIATIVITY+0][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+0][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 0;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+1][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+1][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 1;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+2][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+2][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 2;
                            hit_exist <= 1;
                        end
                        reg_address[index*ASSOCIATIVITY+3][TAG_SIZE-1:0] == tag && reg_address[index*ASSOCIATIVITY+3][CACHE_TAG_SIZE-2]: begin
                            hit_way <= 3;
                            hit_exist <= 1;
                        end
                    endcase

                    if(hit_exist) begin   // hit
                        cache_data[offset>>2][index*ASSOCIATIVITY+hit_way] <= mem_wdata;    // cache write
                        mem_ready <= 1;
                        // LRU bit actualize
                        //reg_address[index*ASSOCIATIVITY+hit_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0; 
                        
                        for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                            if(j != hit_way) begin
                                if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                end else begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                end                        
                            end else begin
                                reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0; // LRU bit
                            end
                        end     

                        reg_address[index*ASSOCIATIVITY+hit_way][CACHE_TAG_SIZE-1] <= 1;    // dirty bit
                        STATE <= IDLE;
                        hits <= hits + 1;
                        // hit_way <= 0;
                        // hit buses reset
                        hit_exist <= 0;
                        //hit_exist_0 <= 0;
                        //hit_exist_1 <= 0;
                        //hit_exist_2 <= 0;
                        //hit_exist_3 <= 0;
                    end else begin
                        miss <= miss + 1;
                        
                        // we need eviction
                        case (1)
                            reg_address[index*ASSOCIATIVITY+0][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 0;
                            end
                            reg_address[index*ASSOCIATIVITY+1][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 1;
                            end
                            reg_address[index*ASSOCIATIVITY+2][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 2;
                            end
                            reg_address[index*ASSOCIATIVITY+3][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1: begin
                                eviction_way <= 3;
                            end
                        endcase

                        temporal_address <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
                        offset_temp <= 0;
                        blockCounter <= 0;
                        offset_temp_w <= 0;
                        counter_W <= 0;
                        if (!reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2]) begin // valid
                            reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2] <= 1'b1;                // valid
                            reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0] <= tag;                     // tag   
                            // LRU bit actualize
                            //reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;  // LRU bit
                            
                            
                            for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                                if(j != eviction_way) begin
                                    if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                    end else begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                    end                        
                                end else begin
                                    reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                                end
                            end     


                            reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 1;                   // dirty 
                            STATE <= WRITE_MISS;
                        end else begin //LRU 
                            if (reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1]) begin // dirty 
                                STATE <= WRITE_BACK;
                                temporal_address_W = ((reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0]<<(INDEX_SIZE))+index*ASSOCIATIVITY+eviction_way)<<OFFSET_SIZE;
                            end else begin
                                STATE <= WRITE_MISS;
                                reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-2] <= 1'b1;                // valid
                                reg_address[index*ASSOCIATIVITY+eviction_way][TAG_SIZE-1:0] <= tag;                     // tag
                                // LRU bit actualize
                                //reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;  // LRU bit
                                
                                
                                
                                for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                                    if(j != eviction_way) begin
                                        if(reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] == ASSOCIATIVITY-1) begin
                                            reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= ASSOCIATIVITY-1;
                                        end else begin
                                            reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4]+1;
                                        end                        
                                    end else begin
                                        reg_address[index*ASSOCIATIVITY+j][CACHE_TAG_SIZE-3:CACHE_TAG_SIZE-4] <= 0;
                                    end
                                end
                                
                                reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 1;                   // dirty
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
                        mem_rdata <= cache_data[offset>>2][index*ASSOCIATIVITY+eviction_way];  // victim index
                        STATE <= IDLE;
                    end                    
                end
                WRITE_MISS: begin
                    if (blockCounter < WORDS_BLOCK) begin
                        STATE <= MEM_ACCESS;
                    end else begin
                        cache_data[offset>>2][index*ASSOCIATIVITY+eviction_way] <= mem_wdata;   // victim index
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
                        cache_data[offset_temp][index*ASSOCIATIVITY+eviction_way] <= mem_rdata_MP;
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
                    mem_wdata_MP <= cache_data[offset_temp_w][index*ASSOCIATIVITY+eviction_way]; // victim index
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
                        reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 0; // Clean DB. Victim index
                    end else begin
                        STATE <= READ;
                        blockCounter <= 0;
                        reg_address[index*ASSOCIATIVITY+eviction_way][CACHE_TAG_SIZE-1] <= 0; // Clean DB
                    end
                end
                default: 
                STATE <= IDLE;
            endcase
        end
    end
endmodule

