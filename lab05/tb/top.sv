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
module top;
import alu_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

vdic_dut_2022 u_vdic_dut_2022 (
	.clk       (bfm.clk),
	.din       (bfm.din),
	.dout      (bfm.dout),
	.dout_valid(bfm.dout_valid),
	.enable_n  (bfm.enable_n),
	.rst_n     (bfm.reset_n)
);
alu_bfm bfm();

initial begin
    uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
    run_test();
end

endmodule : top
