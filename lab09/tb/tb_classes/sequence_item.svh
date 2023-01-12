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
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

		rand bit 	 	[9:0][7:0] data;
        rand byte 		unsigned data_packet_no;
        rand 			operation_t op;
//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(data[0], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[1], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[2], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[3], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[4], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[5], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[6], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[7], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[8], UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data[9], UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint ALU_data {
        data[0] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[1] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[2] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[3] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[4] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[5] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[6] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[7] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[8] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
	    data[9] dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
        data_packet_no dist {[8'h00:8'h01]:=0, [8'h02 : 8'h09]:=1, [8'h0A : 8'hFF]:=0};
	    op dist {CMD_NOP:=1, CMD_AND:=1, CMD_OR:=1, CMD_XOR:=1, CMD_ADD:=1, CMD_SUB:=1, INV_CMD:=1};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        string s;
        s = $sformatf("[0]: %2h  [1]: %2h  [2]: %2h  [3]: %2h  [4]: %2h  [5]: %2h  [6]: %2h  [7]: %2h  [8]: %2h  [9]: %2h op: %s data_packet_no: %d",
	        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],op.name(), data_packet_no);
        return s;
    endfunction : convert2string

endclass : sequence_item


