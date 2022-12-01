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
class coverage extends uvm_component;
    `uvm_component_utils(coverage)
	protected virtual alu_bfm bfm;
	
	protected operation_t op_set;
	protected byte 				 repeat_no;
	protected bit           [0:8]  zeros;
	protected bit           [0:8]  ones;
	protected byte 			iter;
	protected bit           [0:8]  tmp_zeros;
	protected bit           [0:8]  tmp_ones;
	
	//------------------------------------------------------------------------------
	// Coverage
	//------------------------------------------------------------------------------
	
	covergroup op_cov;
	
	    option.name = "cg_op_cov";
	
	    coverpoint op_set {
	        // #A1 test all operations
	        bins A1_single_cycle[] = {[CMD_NOP:CMD_SUB]};
	
	        // #A2 test all operations after reset
	        bins A2_rst_opn[]      = (RST_ST => [CMD_NOP:CMD_SUB]);
	
	        // #A3 test reset after all operations
	        bins A3_opn_rst[]      = ([CMD_NOP:CMD_SUB] => RST_ST);
	
	    }
	
	endgroup
	
	// Covergroup checking for min and max arguments of the ALU
	covergroup zeros_or_ones_on_ops;
	
	    option.name = "cg_zeros_or_ones_on_ops";
	
	    all_ops : coverpoint op_set {
	        ignore_bins not_ops = {CMD_NOP, RST_ST, INV_CMD};
	    }
	
	    a_leg: coverpoint zeros {
		    bins others = {['h0:'h1FE]};
	        bins ones  = {'h1FF};
	    }
	   
	    b_leg: coverpoint ones {
		    bins others = {['h0:'h1FE]};
	        bins ones  = {'h1FF};
	    }
	    op_no_leg: coverpoint repeat_no {
		    bins range[] = {[2:2]};
	    }
	    
	    B_op_00_FF: cross a_leg, b_leg, all_ops, op_no_leg {
		   	bins add_00             = binsof (all_ops) intersect {CMD_ADD} && (binsof (a_leg.ones) && binsof(op_no_leg.range));
	      	bins add_11             = binsof (all_ops) intersect {CMD_ADD} && (binsof (b_leg.ones) && binsof(op_no_leg.range));
		    
		   	bins sub_00             = binsof (all_ops) intersect {CMD_SUB} && (binsof (a_leg.ones) && binsof(op_no_leg.range));
	      	bins sub_11             = binsof (all_ops) intersect {CMD_SUB} && (binsof (b_leg.ones) && binsof(op_no_leg.range));
		    
		   	bins and_00             = binsof (all_ops) intersect {CMD_AND} && (binsof (a_leg.ones) && binsof(op_no_leg.range));
	      	bins and_11             = binsof (all_ops) intersect {CMD_AND} && (binsof (b_leg.ones) && binsof(op_no_leg.range));
		    
		   	bins or_00             = binsof (all_ops) intersect {CMD_OR} && (binsof (a_leg.ones) && binsof(op_no_leg.range));
	      	bins or_11             = binsof (all_ops) intersect {CMD_OR} && (binsof (b_leg.ones) && binsof(op_no_leg.range));
		    
		    bins xor_00             = binsof (all_ops) intersect {CMD_XOR} && (binsof (a_leg.ones) && binsof(op_no_leg.range));
	      	bins xor_11             = binsof (all_ops) intersect {CMD_XOR} && (binsof (b_leg.ones) && binsof(op_no_leg.range));
		    
           ignore_bins others_only =
        	binsof(a_leg.others) && binsof(b_leg.others);
	    }
	
	
	endgroup

	
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
    endfunction : new
	
	
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase
	
task run_phase(uvm_phase phase);

    forever begin : sample_cov
        @(posedge bfm.clk);
	    begin
		    tmp_zeros = 9'h1FF;
		    tmp_ones = 9'h1FF;;
		    iter = 0;
		    repeat(bfm.repeat_no)
			    begin
				    tmp_zeros[iter] = (bfm.data_in_ext_2[iter][1:8] == 8'h00)?1'b1:1'b0;
				    tmp_ones[iter] = (bfm.data_in_ext_2[iter][1:8] == 8'hFF)?1'b1:1'b0;
				    iter++;
			    end
			ones = tmp_ones;
		    zeros = tmp_zeros;
		    repeat_no = bfm.repeat_no;
		    #1 op_set = bfm.op_set; 
            op_cov.sample();
            zeros_or_ones_on_ops.sample();
	    end
    end : sample_cov
endtask


endclass : coverage
