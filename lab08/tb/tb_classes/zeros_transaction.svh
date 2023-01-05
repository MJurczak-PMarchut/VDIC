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
class zeros_transaction extends command_transaction;
    `uvm_object_utils(zeros_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint zeros_only {
        data[0] == 8'h00;
	    data[1] == 8'h00;
	    data[2] == 8'h00;
	    data[3] == 8'h00;
	    data[4] == 8'h00;
	    data[5] == 8'h00;
	    data[6] == 8'h00;
	    data[7] == 8'h00;
	    data[8] == 8'h00;
	    data[9] == 8'h00;
        data_packet_no dist {[8'h00:8'h01]:=0, [8'h02 : 8'h09]:=1, [8'h0A : 8'hFF]:=0};
	    op dist {CMD_NOP:=1, CMD_AND:=1, CMD_OR:=1, CMD_XOR:=1, CMD_ADD:=1, CMD_SUB:=1, INV_CMD:=1};}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : zeros_transaction


