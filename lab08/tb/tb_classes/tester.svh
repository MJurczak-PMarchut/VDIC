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
class tester extends uvm_component;
    `uvm_component_utils (tester)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        command_transaction command;
	    zeros_transaction z_command;
	    ones_transaction o_command;

        phase.raise_objection(this);

	    repeat(40) begin
		    
		    command    = new("command");
    		command.op = RST_ST;
    		command_port.put(command);
		    command    = command_transaction::type_id::create("command");
		    
	        repeat (100) begin
	            assert(command.randomize());
	            command_port.put(command);
	        end
	    end
	    
	    repeat(40) begin
		    
		    z_command    = new("z_command");
    		z_command.op = RST_ST;
    		command_port.put(z_command);
		    z_command    = zeros_transaction::type_id::create("z_command");
		    
	        repeat (100) begin
	            assert(z_command.randomize());
	            command_port.put(z_command);
	        end
	    end
	    
	    repeat(40) begin
		    
		    o_command    = new("command");
    		o_command.op = RST_ST;
    		command_port.put(command);
		    o_command    = ones_transaction::type_id::create("o_command");
		    
	        repeat (100) begin
	            assert(o_command.randomize());
	            command_port.put(o_command);
	        end
        end
        #500;
        phase.drop_objection(this);
    endtask : run_phase


endclass : tester






