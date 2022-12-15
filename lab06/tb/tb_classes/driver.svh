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
 */
class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_get_port #(command_s) command_port;
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        command_port = new("command_port",this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        command_s command;
        byte iter;
        shortint result;
        forever begin : command_loop
            command_port.get(command);
	        if(command.op == RST_ST)
		        wait(bfm.reset_allowed)
		        	@(posedge bfm.clk)
		        	@(posedge bfm.clk)
		        		bfm.reset_alu();
	        else begin
		        iter = 0;
		        bfm.op_set = command.op;
		        bfm.repeat_no = command.data_packet_no;
	            repeat(command.data_packet_no) begin
	                bfm.data_in_ext_2[iter] = {1'b0, command.data[iter], 1'b0};
	                bfm.data_in_ext_2[iter][9] = ^bfm.data_in_ext_2[iter];
		            iter++;
	            end
	            bfm.data_in_ext_2[iter] = {1'b1, command.op, 1'b0};
	            bfm.data_in_ext_2[iter][9] = ^bfm.data_in_ext_2[iter];
	            bfm.send_to_DUT(command.data_packet_no+1);
	            bfm.done = 1'b1;
            end
        end : command_loop
    endtask : run_phase
    

endclass : driver

