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
class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

		rand bit 	 	[9:0][7:0] data;
        rand byte 		unsigned data_packet_no;
        rand 			operation_t op;
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
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        data  = copied_transaction_h.data;
        data_packet_no  = copied_transaction_h.data_packet_no;
        op = copied_transaction_h.op;

    endfunction : do_copy


    function command_transaction clone_me();
        
        command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        command_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.data == data) &&
            (compared_transaction_h.data_packet_no == data_packet_no) &&
            (compared_transaction_h.op == op);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("[0]: %2h  [1]: %2h  [2]: %2h  [3]: %2h  [4]: %2h  [5]: %2h  [6]: %2h  [7]: %2h  [8]: %2h  [9]: %2h op: %s data_packet_no: %d",
	        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],op.name(), data_packet_no);
        return s;
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : command_transaction
