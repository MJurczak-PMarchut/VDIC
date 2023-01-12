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
class ones_sequence extends uvm_sequence #(ones_sequence_item);
    `uvm_object_utils(ones_sequence)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

// not necessary, req is inherited
//    ones_sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "ones_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_ONES","",UVM_MEDIUM)
        repeat (50) begin
            `uvm_do(req);
//            req.print();
        end
    endtask : body
    
    
endclass : ones_sequence











