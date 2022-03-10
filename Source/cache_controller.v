module cache_controller(
    input   clk,
    input   reset,
    input   ld, st,
    input   [1:0]   ref,
    input   [31:0]  addr,
    input   [20:0]  tag_loaded1, tag_loaded2, 
    input   valid1, dirty1, valid2, dirty2,
    input   l2_ack,
    output  reg     hit, miss,
    output  reg     tag_en1,tag_en2,valid_en1,valid_en2,dirty_en1,dirty_en2,//tag、valid、dirty使能信号
    output  reg     load_ready, 
    output  reg     [1:0] write_l1,
    output  reg     read_l2, write_l2,
    output  reg     [1:0] ref_new,        //更改后的reference
    output  reg     ref_en,
    output  reg     dirty,
    output  reg [3:0]   state,   
    output  reg [3:0]   next_state,
    output  reg [3:0]   count,
    output  reg count_en                  //计数器使能
    );
    
    localparam      IDLE            = 0,
                    READ            = 1,
                    WRITE           = 2,
                    WRITEBACK_L2    = 3,
                    ALLOCATE        = 4,
                    UPDATE_L1       = 5,
                    READ_L1         = 6,
                    WRITE_L1        = 7,
                    WRITE_L2        = 8;
   
    wire        hit1, hit2;
    assign hit1 = valid1 & (tag_loaded1 == addr[31:11]);      //block0 hit
    assign hit2 = valid2 & (tag_loaded2 == addr[31:11]);      //block1 hit
    
    always@(*)                              //状态转移逻辑
    begin
        case(state)
                IDLE:
                       if(ld)
                       begin
                            next_state = READ;
	                   end
	                   else if(st)
	                   begin
	                        next_state = WRITE;
	                   end
	                   else
	                   begin
	                        next_state = IDLE;
	                   end

                READ:
                       if(hit1 | hit2)      // Read hit
                       begin
                            next_state = READ_L1;
	                   end
	                   else if((!ref[1] & valid1 & dirty1) | (!ref[0] & valid2 & dirty2)) 
	                   //Read miss & dirty =1
	                   begin
	                        next_state = WRITEBACK_L2;
	                   end
	                   else      //Read miss & dirty =0
	                   begin
	                        next_state = ALLOCATE;
	                   end	  
	                   
                WRITE:
                       if(hit1 | hit2)    //Write hit
                       begin
                            next_state = WRITE_L1;
	                   end
	                   else              //Write miss
	                   begin
	                        next_state = WRITE_L2;
	                   end

                WRITEBACK_L2:
                       if(count == 6)        //数据发送8次
                       begin
                            next_state = ALLOCATE;
                       end 
                       else 
                       begin
                            next_state = WRITEBACK_L2;
                       end    
                       
                ALLOCATE:
                       if(l2_ack)        //L2数据到达
                       begin
                       next_state = UPDATE_L1;
                       end
                       else
                       begin
                       next_state = ALLOCATE;
                       end
                
                UPDATE_L1:
                       next_state = READ_L1;
                       
                READ_L1:
                       next_state = IDLE;
                
                WRITE_L1:
                       next_state = IDLE;
                   
                WRITE_L2:
                       if(count == 6)
                       begin
                            next_state = IDLE;
                       end 
                       else 
                       begin
                            next_state = WRITE_L2;
                       end                                                                                  
        endcase     
    end
    
    
    always@(posedge clk or negedge reset)  //状态寄存器
    begin
        if(reset) begin  //复位
        state <= IDLE;
        end
        else begin
        state <= next_state;
        end
    end
    
    always@(posedge clk)    //计数器模块
    begin
        if(count_en == 1)
        begin
            count <= count + 1;
        end
        else
        begin
            count <= 0;
        end
    end
    
    always@(posedge clk or negedge reset)  //输出逻辑
    begin
        if(reset) begin
                hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 0;  
                ref_en      <= 0;
                ref_new     <= 0;
                count_en    <= 0;
                dirty       <= 0;
        end
        case(state)
            IDLE:
            begin
	            hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 0;  
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 0;
                dirty       <= 0;
            end
            
            READ:
            begin
	            hit         <= hit1 | hit2;
                miss        <= !(hit1 | hit2);
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 0; 
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 0;
                dirty       <= 0;
            end                 
 
            WRITE:
            begin
	            hit         <= hit1 | hit2;
                miss        <= !(hit1 | hit2);
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 0; 
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 0;
                dirty       <= 0;                 
            end
            
            WRITEBACK_L2:
            begin
	            hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= !ref[1] & valid1 & dirty1;
                dirty_en2   <= !ref[0] & valid2 & dirty2;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 1;
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 1;
                dirty       <= 0 ^ (count == 7);
            end
            
            ALLOCATE:
            begin
               	hit         <= 0;
                miss        <= 0;
                tag_en1     <= ref ? !ref[1] : 0;
                tag_en2     <= ref ? !ref[0] : 1;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 1;
                write_l2    <= 0; 
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 0;
                dirty       <= 0;
            end
            
            UPDATE_L1:
            begin
               	hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= ref ? !ref[1] : 0;
                valid_en2   <= ref ? !ref[0] : 1;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= ref ? ~ref : 2'b01;
                read_l2     <= 0;
                write_l2    <= 0; 
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 0;
                dirty       <= 0;
            end
            
            READ_L1:
            begin
               	hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 1;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 0; 
                ref_en      <= 1;
                ref_new     <= (hit1 | hit2) ? {hit1, hit2} : (ref ? ~ref : 2'b01);
                count_en    <= 0;
                dirty       <= 0;
            end
            
            WRITE_L1:
            begin
               	hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= hit1;
                dirty_en2   <= hit2;
                load_ready  <= 0;
                write_l1    <= {hit1, hit2};
                read_l2     <= 0;
                write_l2    <= 0; 
                ref_en      <= 1;
                ref_new     <= {hit1, hit2};
                count_en    <= 0;
                dirty       <= 1;
            end
           
            WRITE_L2:
            begin
               	hit         <= 0;
                miss        <= 0;
                tag_en1     <= 0;
                tag_en2     <= 0;
                valid_en1   <= 0;
                valid_en2   <= 0;
                dirty_en1   <= 0;
                dirty_en2   <= 0;
                load_ready  <= 0;
                write_l1    <= 0;
                read_l2     <= 0;
                write_l2    <= 1; 
                ref_en      <= 0;
                ref_new     <= ref_new;
                count_en    <= 1;
                dirty       <= 0;
            end
        endcase
    end  
endmodule
