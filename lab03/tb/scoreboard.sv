// used to modify the color of the text printed on the terminal
module scoreboard(alu_bfm bfm);
import alu_pkg::*;

bit           [7:0]  STATUS;
bit 				 parity_check;
	
typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

test_result_t        test_result = TEST_PASSED;
operation_t op_set;
shortint expected = 0;
shortint  result;
byte 				 repeat_no;
	
typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

function logic [15:0] get_expected(
		bit [0:9] data [10],
        operation_t op_set,
        byte repetitions
    );
    bit [15:0] ret;
	bit [7:0] A, B;
	byte iter;
	iter = 1;
	ret = {8'h00, data[0][1:8]};
    repeat(repetitions-1)
	    begin
	    	B = data[iter][1:8];
		    case(op_set)
		        CMD_AND : ret    = ret & B;
		        CMD_ADD : ret    = ret + B;
		        CMD_SUB : ret    = ret - B;
		        CMD_XOR : ret    = ret ^ B;
		        CMD_OR : ret    = ret | B;
			    CMD_NOP : ret    = 0;
			    INV_CMD : ret    = 0;
		        default: begin
		            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set.name());
		            test_result = TEST_FAILED;
		            return -1;
		        end
		    endcase
		    iter = iter + 1;
	    end
    return(ret);
endfunction : get_expected

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

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
//`define DEBUG

initial forever @(negedge bfm.clk) begin : scoreboard
    if(bfm.done && bfm.dout_valid) begin:verify_result
	    bfm.reset_allowed = 0;
        expected = get_expected(bfm.data_in_ext_2, bfm.op_set, bfm.repeat_no);
	    op_set = bfm.op_set;
	    repeat_no = bfm.repeat_no;
    	bfm.done  = 1'b0;
		bfm.receive_from_DUT(30);
	    bfm.reset_allowed = 1;
        STATUS = bfm.data_out_ext[1:8];
		result = {bfm.data_out_ext[11:18],bfm.data_out_ext[21:28]};
		parity_check = ^bfm.data_out_ext[0:9] | ^bfm.data_out_ext[10:19] | ^bfm.data_out_ext[20:29];
        if(op_set != INV_CMD)
            assert((result == expected) && (STATUS == 0) && (parity_check == 0)) begin
                `ifdef DEBUG
                $display("Test passed for op_set=%s", op_set.name());
                `endif
            end
            else begin
                `ifdef DEBUG
                $display("Test FAILED for op_set=%s and %d operands", op_set.name(), repeat_no);
                $display("Expected: %d  received: %d", expected, result);
                $display("STATUS: %d  parity: %d", STATUS, parity_check);
                `endif
                test_result <= TEST_FAILED;
            end
        else
            assert((STATUS == S_INVALID_COMMAND) && (result == expected) && (parity_check == 0)) begin
                `ifdef DEBUG
                $display("Test passed for op_set=%s", op_set.name());
                `endif
            end
            else begin
                `ifdef DEBUG
                $display("Test FAILED for op_set=%s and %d operands", op_set.name(), repeat_no);
                $display("Expected: %d  received: %d", expected, result);
                $display("STATUS: %d  parity: %d", STATUS, parity_check);
                `endif
                test_result <= TEST_FAILED;
            end;
    end
end

final begin : finish_of_the_test
    print_test_result(test_result);
end

endmodule : scoreboard
