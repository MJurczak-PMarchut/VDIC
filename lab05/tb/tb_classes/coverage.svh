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
	protected bit           [7:0]  A;
	protected bit           [7:0]  B;
	
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
	
	    a_leg: coverpoint A {
	        bins zeros = {'h00};
	        bins others= {['h01:'hFE]};
	        bins ones  = {'hFF};
	    }
	
	    b_leg: coverpoint B {
	        bins zeros = {'h00};
	        bins others= {['h01:'hFE]};
	        bins ones  = {'hFF};
	    }
	    
	    op_no_leg: coverpoint bfm.repeat_no {
		    bins range[] = {[2:9]};
	    }
	    
	    B_op_00_FF: cross a_leg, b_leg, all_ops, op_no_leg ;
	
	
	endgroup

	
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
        bfm                  = b;
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
		    A = bfm.A;
		    B = bfm.B;
		    #1 op_set = bfm.op_set; 
            op_cov.sample();
            zeros_or_ones_on_ops.sample();
	    end
    end : sample_cov
endtask


endclass : coverage