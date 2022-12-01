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

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function operation_t get_op();
    pure virtual protected function byte get_data();
	pure virtual protected function byte get_op_no();
	protected task fill_data_in_regs(input byte repeat_number);
		begin
			automatic bit [7:0]  data_counter;
			data_counter = 2;
			bfm.A = get_data();
			bfm.B = get_data();
			bfm.data_in_ext_2[0] = {1'b0,bfm.A,1'b0};
			bfm.data_in_ext_2[0][9] = ^bfm.data_in_ext_2[0];
			bfm.data_in_ext_2[1] = {1'b0,bfm.B,1'b0};
			bfm.data_in_ext_2[1][9] = ^bfm.data_in_ext_2[1];
			repeat(repeat_number - 2) begin
				bfm.A_ext = {1'b0,get_data(),1'b0};
				bfm.A_ext[0] = ^bfm.A_ext;
				bfm.data_in_ext_2[data_counter] = bfm.A_ext;
				data_counter = data_counter+1;
			end
		end
	endtask
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
	    phase.raise_objection(this);
		begin : tester
			@(negedge bfm.clk)
			repeat(30) begin
				wait(bfm.done == 0)
				bfm.reset_alu();
				repeat (200) begin : tester_main_blk
					wait(bfm.done == 0)
					bfm.op_set = get_op();
					bfm.op_set_ext = {1'b1, bfm.op_set, 1'b0};
					bfm.op_set_ext[0] = ~^bfm.op_set_ext;
					bfm.repeat_no = get_op_no();
					fill_data_in_regs(bfm.repeat_no);
					bfm.data_in_ext_2[bfm.repeat_no] = bfm.op_set_ext;
					case (bfm.op_set) // handle the start signal
						default: begin : case_default_blk
							bfm.send_to_DUT(bfm.repeat_no+1);
							bfm.done = 1;
						end : case_default_blk
					endcase // case (op_set)
				end : tester_main_blk
			end
			bfm.finished = 1;
			#1;
			phase.drop_objection(this);
		end : tester
    endtask : run_phase


endclass : base_tester
