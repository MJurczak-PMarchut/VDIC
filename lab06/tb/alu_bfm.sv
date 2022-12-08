/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
import alu_pkg::*;
interface alu_bfm;
    
//------------------------------------------------------------------------------
// variables
//------------------------------------------------------------------------------

bit           [7:0]  packet_counter;
bit           [9:0]  A_ext;
bit           [7:0]  A;
bit           [7:0]  B;
bit					 reset_allowed = 1;
bit                  clk;
bit                  reset_n;
bit 				 enable_n;
bit          [0:29]  data_out_ext;
bit          [0:9] 	 data_in_ext_2 [10];
bit					 done;
bit					 finished = 0;
byte 				 repeat_no;

operation_t          op_set;
bit [9:0] op_set_ext;
	
bit din;
wire dout;
wire dout_valid;

command_monitor command_monitor_h;
result_monitor result_monitor_h;

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
	done = 0;
	enable_n = 1;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset_alu();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_alu", $time);
    `endif
    wait(reset_allowed);
    op_set = RST_ST;
    reset_n = 1'b0;
    @(negedge clk);
    reset_n = 1'b1;
endtask : reset_alu


task send_to_DUT(input integer packets);
	begin
		automatic bit [7:0]  data_counter;
		data_counter = 0;
		packet_counter = 0;
	    repeat(packets*10)
		    begin
	            @(negedge(clk))
	            	begin
		            	enable_n = 1'b0;
			            din = data_in_ext_2[packet_counter][data_counter%10];
			            data_counter = data_counter+1;
		            	packet_counter = data_counter/10;
	            	end
	    	end
	    @(negedge clk)
    		enable_n <= 1'b1;
	end
endtask

task receive_from_DUT(input integer bits);
	begin
		automatic bit [7:0]  data_counter;
		data_counter = 0;
	    repeat(bits) begin
            @(posedge(clk))
            	begin
		            data_out_ext[data_counter] = dout;
		            data_counter = data_counter+1;
            	end
	    end
	end
endtask


//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
	byte iter;
    command_s command;
    if (enable_n) begin : start_high
        if (!in_command) begin : new_command
			iter = 0;
			repeat(repeat_no) begin
				command.data = bfm.data_in_ext_2[iter][1:8];
			end
			command.data_packet_no = repeat_no;
            command.op = op_set;
            command_monitor_h.write_to_monitor(command);
            in_command = (command.op != no_op);
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor

always @(negedge reset_n) begin : rst_monitor
    command_s command;
    command.op = RST_ST;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor


//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (done)
            result_monitor_h.write_to_monitor(result);
    end
end : result_monitor_thread


endinterface : alu_bfm
