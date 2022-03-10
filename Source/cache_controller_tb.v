module cache_controller_tb(

    );
    reg     clk;
    reg     reset;
    reg     ld, st;
    reg     [1:0]   ref;
    reg     [31:0]  addr;
    reg     [20:0]  tag_loaded1, tag_loaded2;
    reg     valid1, dirty1, valid2, dirty2;
    reg     l2_ack;
    wire    hit, miss;
    wire    tag_en1,tag_en2,valid_en1,valid_en2,dirty_en1,dirty_en2;
    wire    load_ready;
    wire    [1:0] write_l1;
    wire    read_l2, write_l2;
    wire    [1:0] ref_new;
    wire    ref_en;
    wire    dirty;
    wire    [3:0]state, next_state;
    wire    [3:0] count;
    wire    count_en;
    
    cache_controller c1(
        .clk(clk),
        .reset(reset),
        .ld(ld),
        .st(st),
        .ref(ref),
        .addr(addr),
        .tag_loaded1(tag_loaded1),
        .tag_loaded2(tag_loaded2),
        .valid1(valid1),
        .valid2(valid2),
        .dirty1(dirty1),
        .dirty2(dirty2),
        .l2_ack(l2_ack),
        .hit(hit),
        .miss(miss),
        .tag_en1(tag_en1),
        .tag_en2(tag_en2),
        .valid_en1(valid_en1),
        .valid_en2(valid_en2),
        .dirty_en1(dirty_en1),
        .dirty_en2(dirty_en2),
        .load_ready(load_ready),
        .write_l1(write_l1),
        .read_l2(read_l2),
        .write_l2(write_l2),
        .ref_new(ref_new),
        .ref_en(ref_en),
        .dirty(dirty),
        .state(state),
        .next_state(next_state),
        .count(count),
        .count_en(count_en)
    );
    
    initial begin
	clk = 1'd0;
	forever
	#10 clk = ~clk;
	end
	
    initial begin
    //reset
    reset=1;         
    ld=0; st=0;
    ref=2'b00;
    addr=0;
    tag_loaded1=0; tag_loaded2=0;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #80
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b00000000000000000000_00000000000;
    tag_loaded1=0; tag_loaded2=0;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0;
    
    //ld
    #20
    reset=0;
    ld=1; st=0;
    ref=2'b00;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=0;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0;
    
    // ld miss, turn to ALLOCATE and wait for l2_ack
    repeat(8)
    begin
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=0;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0;
    end
    
    //l2_ack = 1, turn to UPDATE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=0;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=1;
    
    //UPDATE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0;
    
    //READ_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //ld
    #20
    reset=0;
    ld=1; st=0;
    ref=2'b01;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //ld hit, READ_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //ld
    #20
    reset=0;
    ld=1; st=0;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //ld miss, turn to ALLOCATE and wait for l2_ack  
    repeat(8)
    begin
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    end
    
    //l2_ack = 1, turn to UPDATE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=0; tag_loaded2=21'b111111111111111111111;
    valid1=0; dirty1=0; valid2=1; dirty2=0;
    l2_ack=1;
    
    //READ_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //st
    #20
    reset=0;
    ld=0; st=1;
    ref=2'b10;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //write hit, so WRITE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111111_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0;
   
    //st
    #20
    reset=0;
    ld=0; st=1;
    ref=2'b01;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0;
    
    //write miss, so WRITE_L2
    repeat(8)
    begin
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0;
    end
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0; 
    
    //st
    #20
    reset=0;
    ld=0; st=1;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0;
    
    //write hit, so WRITE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=0; valid2=1; dirty2=1;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111110_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=1; valid2=1; dirty2=1;
    l2_ack=0;
    
    //ld
    #20
    reset=0;
    ld=1; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=1; valid2=1; dirty2=1;
    l2_ack=0; 
    
    //read miss, and dirty==1, turn to WRITE_BACK
    repeat(8)
    begin
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=1; valid2=1; dirty2=1;
    l2_ack=0; 
    end
    
    //WRITE_BACK OVER, turn to ALLOCATE and wait for l2_ack
    repeat(8)
    begin
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=1; valid2=1; dirty2=0;
    l2_ack=0; 
    end
    
    //l2_ack=1, turn to UPDATE_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111111;
    valid1=1; dirty1=1; valid2=1; dirty2=0;
    l2_ack=1;
    
    //UPDATE_L1 
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111101;
    valid1=1; dirty1=1; valid2=1; dirty2=0;
    l2_ack=0;
    
    //READ_L1
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b10;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111101;
    valid1=1; dirty1=1; valid2=1; dirty2=0;
    l2_ack=0;
    
    //IDLE
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b01;
    addr=32'b111111111111111111101_11111111111;
    tag_loaded1=21'b111111111111111111110; tag_loaded2=21'b111111111111111111101;
    valid1=1; dirty1=1; valid2=1; dirty2=0;
    l2_ack=0;   
    
    #20
    reset=0;
    ld=0; st=0;
    ref=2'b00;
    addr=32'b000000000000000000000_00000000000;
    tag_loaded1=21'b000000000000000000000; tag_loaded2=21'b000000000000000000000;
    valid1=0; dirty1=0; valid2=0; dirty2=0;
    l2_ack=0; 
    
    $stop;
    end
    
endmodule
