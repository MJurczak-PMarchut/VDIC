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
class ones_sequence_item extends sequence_item;
    `uvm_object_utils(ones_sequence_item)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint ones_only {
        data[0] == 8'hFF;
	    data[1] == 8'hFF;
	    data[2] == 8'hFF;
	    data[3] == 8'hFF;
	    data[4] == 8'hFF;
	    data[5] == 8'hFF;
	    data[6] == 8'hFF;
	    data[7] == 8'hFF;
	    data[8] == 8'hFF;
	    data[9] == 8'hFF;
	}


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "ones_sequence_item");
        super.new(name);
    endfunction : new

endclass : ones_sequence_item


