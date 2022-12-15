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
virtual class base_tester extends uvm_component;

// The macro is not there as we never instantiate/use the base_tester
//    `uvm_component_utils(base_tester)
    uvm_put_port #(command_s) command_port;
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
   	protected command_s command;
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function operation_t get_op();
    pure virtual protected function byte get_data();
	pure virtual protected function byte get_op_no();
	protected task fill_data_in_regs();
		begin
			automatic bit [7:0]  data_counter;
			data_counter = 0;
			command.op = get_op();
			command.data_packet_no = get_op_no();
			repeat(command.data_packet_no) begin
				command.data[data_counter] = get_data();
				data_counter = data_counter+1;
			end
		end
	endtask
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
        command_port = new("command_port", this);
    endfunction : build_phase


//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
	    phase.raise_objection(this);
		begin : tester
			repeat(30) begin
        		command.op = RST_ST;
        		command_port.put(command);
				repeat (200) begin : tester_main_blk
					fill_data_in_regs();
					command_port.put(command);
				end : tester_main_blk
			end
			#1000;
			phase.drop_objection(this);
		end : tester
    endtask : run_phase


endclass : base_tester