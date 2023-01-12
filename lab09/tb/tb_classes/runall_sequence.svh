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
class runall_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(runall_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    local sequencer sequencer_h;
    local uvm_component uvm_component_h;

//------------------------------------------------------------------------------
// sequences to run
//------------------------------------------------------------------------------

    local reset_sequence reset;
    local zeros_sequence zeros;
    local random_sequence random;
    local ones_sequence ones;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "runall_sequence");
        super.new(name);

        // runall_sequence is called with null sequencer; another way to
        // define the sequence is to use find function;
        uvm_component_h = uvm_top.find("*.env_h.sequencer_h");

        if (uvm_component_h == null)
            `uvm_fatal("RUNALL_SEQUENCE", "Failed to get the sequencer")

        // find function returns uvm_component, needs casting
        if (!$cast(sequencer_h, uvm_component_h))
            `uvm_fatal("RUNALL_SEQUENCE", "Failed to cast from uvm_component_h.")

        reset           = reset_sequence::type_id::create("reset");
        max         	= ones_sequence::type_id::create("ones");
        random          = random_sequence::type_id::create("random");
        zeros             = add_sequence::type_id::create("zeros");
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
		repeat(30)
			begin
				`uvm_info("SEQ_RUNALL","",UVM_MEDIUM)
				reset.start(sequencer_h);
				max.start(sequencer_h);
				random.start(sequencer_h);
				zeros.start(sequencer_h);
			end
    endtask : body


endclass : runall_sequence



