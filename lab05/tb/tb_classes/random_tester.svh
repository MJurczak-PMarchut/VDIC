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
class random_tester extends base_tester;
    `uvm_component_utils (random_tester)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tester
//------------------------------------------------------------------------------
	protected function byte get_data();

		bit [1:0] zero_ones;

		zero_ones = 2'($random);

		if (zero_ones == 2'b00)
			return 8'h00;
		else if (zero_ones == 2'b11)
			return 8'hFF;
		else
			return 8'($random);
	endfunction : get_data

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tester
//------------------------------------------------------------------------------
	protected function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000 : return CMD_NOP;
			3'b001 : return CMD_ADD;
			3'b010 : return CMD_AND;
			3'b011 : return CMD_XOR;
			3'b100 : return CMD_SUB;
			3'b101 : return CMD_XOR;
			3'b110 : return CMD_OR;
			3'b110 : return CMD_AND;
			3'b111 : return INV_CMD;
		endcase // case (op_choice)
	endfunction : get_op

//---------------------------------


protected function byte get_op_no();
		byte op_count;
		op_count = 3'($random) + 2'b10;
        return (op_count <= 9)?op_count:9; //At least two operandst two operands
endfunction : get_op_no

endclass : random_tester





