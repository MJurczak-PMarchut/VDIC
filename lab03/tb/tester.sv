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
module tester(alu_bfm bfm);
    
import alu_pkg::*;




//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions
//---------------------------------

function operation_t get_op();
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
function byte get_data();

    bit [1:0] zero_ones;

    zero_ones = 2'($random);

    if (zero_ones == 2'b00)
        return 8'h00;
    else if (zero_ones == 2'b11)
        return 8'hFF;
    else
        return 8'($random);
endfunction : get_data

function byte get_op_no();
		byte op_count;
		op_count = 3'($random) + 2'b10;
        return (op_count <= 9)?op_count:9; //At least two operandst two operands
endfunction : get_op_no

task fill_data_in_regs(input byte repeat_number);
	begin
		automatic bit [7:0]  data_counter;
		data_counter = 2;
		bfm.A = get_data();
		bfm.B = get_data();
	    bfm.data_in_ext_2[0] = {1'b0,bfm.A,1'b0};
	    bfm.data_in_ext_2[0][9] = ~^bfm.data_in_ext_2[0];
	    bfm.data_in_ext_2[1] = {1'b0,bfm.B,1'b0};
	    bfm.data_in_ext_2[1][9] = ~^bfm.data_in_ext_2[1];
	    repeat(repeat_number - 2) begin
		    bfm.A_ext = {1'b0,get_data(),1'b0};
		    bfm.A_ext[0] = ~^bfm.A_ext;
            bfm.data_in_ext_2[data_counter] = bfm.A_ext;
            data_counter = data_counter+1;
    	end
	end
endtask


//------------------------
// Tester main



initial begin : tester
	@(negedge bfm.clk)
	repeat(30) begin
		wait(bfm.done == 0)
	    bfm.reset_alu();
	    repeat (1000) begin : tester_main_blk
		    wait(bfm.done == 0)
		    bfm.op_set = get_op();
	        bfm.op_set_ext = {1'b1, bfm.op_set, 1'b0};
		    bfm.op_set_ext[0] = ~^bfm.op_set_ext;
		    bfm.repeat_no = get_op_no();
		    fill_data_in_regs(bfm.repeat_no);
		    bfm.data_in_ext_2[bfm.repeat_no] = bfm.op_set_ext;
	        case (bfm.op_set) // handle the start signal
//	            CMD_NOP: begin : case_no_op_blk
//		            data_in_ext_2[0] = op_set_ext;
//	                send_to_DUT(1);
//		            wait(dout_valid);
//					receive_from_DUT(30);
//		            STATUS = data_out_ext[1:8];
//    				result = {data_out_ext[11:18],data_out_ext[21:28]};
//        			parity_check = ^data_out_ext[0:9] | ^data_out_ext[10:19] | ^data_out_ext[20:29];
//		            done = 1'b1;
//	            end
	            default: begin : case_default_blk
					bfm.send_to_DUT(bfm.repeat_no+1);
		            bfm.done = 1;
	            end : case_default_blk
	        endcase // case (op_set)
	    end : tester_main_blk
    end
    $finish;
end : tester


endmodule : tester
