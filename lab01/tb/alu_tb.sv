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
    
//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit[7:0] {
    CMD_NOP  = 8'b00000000,
    CMD_AND = 8'b00000001,
    CMD_OR = 8'b00000010,
    CMD_XOR = 8'b00000011,
    CMD_ADD = 8'b00010000,
    CMD_SUB = 8'b00100000
} operation_t;


typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

bit           [7:0]  data_counter;
bit           [7:0]  A;
bit           [7:0]  B;
bit           [7:0]  STATUS;
bit           [9:0]  A_ext;
bit           [9:0]  B_ext;
bit                  clk;
bit                  reset_n;
wire          [2:0]  op;
bit                  start;
bit 				 enable_n;
wire                 done;
bit          [15:0] result;
bit          [0:29] data_in_ext;
bit          [0:29] data_out_ext;

operation_t          op_set;
bit [9:0] op_set_ext;
assign op = op_set;

test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

bit din;
wire dout;
wire dout_valid;

vdic_dut_2022 u_vdic_dut_2022 (
	.clk       (clk),
	.din       (din),
	.dout      (dout),
	.dout_valid(dout_valid),
	.enable_n  (enable_n),
	.rst_n     (reset_n)
);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
	enable_n = 1;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

function operation_t get_op();
    bit [2:0] op_choice;
    op_choice = 3'($random);
    case (op_choice)
        3'b000 : return CMD_NOP;
        3'b001 : return CMD_ADD;
        3'b010 : return CMD_AND;
        3'b011 : return CMD_XOR;
        3'b100 : return CMD_SUB;
        3'b101 : return CMD_NOP;
        3'b110 : return CMD_OR;
        3'b111 : return CMD_OR;
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

//------------------------
// Tester main

initial begin : tester
    reset_alu();
    repeat (2) begin : tester_main_blk
        @(negedge clk);
	    op_set = CMD_ADD;
        op_set_ext = {1'b1, op_set, 1'b0};
	    op_set_ext[0] = ~^op_set_ext;
        A      = 00000010;
        B      = 00000001;
	    A_ext = {1'b0,A,1'b0};
	    A_ext[0] = ~^A_ext;
	    B_ext = {1'b0,B,1'b0};
	    B_ext[0] = ~^B_ext;
        start  = 1'b1;
	    data_counter = 0;
	    data_in_ext = {A_ext, B_ext, op_set_ext};
        case (op_set) // handle the start signal
            CMD_NOP: begin : case_no_op_blk
                @(negedge clk);
                enable_n                             = 1'b0;
            end
            default: begin : case_default_blk
	            //TODO send data
            	enable_n                             = 1'b0;
	            repeat(30) begin
		            @(posedge(clk))
		            	begin
				            din = data_in_ext[data_counter];
				            data_counter = data_counter+1;
		            	end
		            end
                wait(dout_valid);
	            begin
		            data_counter =0;
	            end
	            repeat(30) begin
		            @(posedge(clk))
		            	begin
				            data_out_ext[data_counter] = dout;
				            data_counter = data_counter+1;
		            	end
	            end
	            begin
                	enable_n                             = 1'b1;
	            	STATUS = data_out_ext[1:8];
	            	result = {data_out_ext[11:18],data_out_ext[21:28]};
	            end
	            
                //------------------------------------------------------------------------------
                // temporary data check - scoreboard will do the job later
                begin
                    automatic bit [15:0] expected = get_expected(A, B, CMD_ADD);
                    assert(result === expected) begin
                        `ifdef DEBUG
                        $display("Test passed for A=%0d B=%0d op_set=%s", A, B, op_set);
                        `endif
                    end
                    else begin
                        $display("Test FAILED for A=%0d B=%0d op_set=%s", A, B, op_set.name());
                        $display("Expected: %d  received: %d", expected, result);
	                    $display("STATUS: %d ", STATUS);
                        test_result = TEST_FAILED;
                    end;
                end

            end : case_default_blk
        endcase // case (op_set)
    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
    end : tester_main_blk
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset_alu();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_alu", $time);
    `endif
    start   = 1'b0;
    reset_n = 1'b0;
    @(negedge clk);
    reset_n = 1'b1;
endtask : reset_alu

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function logic [15:0] get_expected(
        bit [7:0] A,
        bit [7:0] B,
        operation_t op_set
    );
    bit [15:0] ret;
    `ifdef DEBUG
    $display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, A, B, op_set);
    `endif
    case(op_set)
        CMD_AND : ret    = A & B;
        CMD_ADD : ret    = A + B;
        CMD_SUB : ret    = A - B;
        CMD_XOR : ret    = A ^ B;
        default: begin
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
            test_result = TEST_FAILED;
            return -1;
        end
    endcase
    return(ret);
endfunction : get_expected

//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction


endmodule : top
