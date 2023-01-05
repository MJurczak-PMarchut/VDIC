// used to modify the color of the text printed on the terminal

class scoreboard extends uvm_subscriber #(result_transaction);
    `uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


	
	typedef enum bit {
	    TEST_PASSED,
	    TEST_FAILED
	} test_result_t;
	
	
	protected bit           [7:0]  STATUS;
	protected bit 				 parity_check;
		
	protected test_result_t        test_result = TEST_PASSED;
	protected operation_t op_set;
	protected shortint expected = 0;
	protected shortint  result;
	protected byte 				 repeat_no;
		
	uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

	protected function logic [15:0] get_expected(
			bit [9:0][7:0] data,
	        operation_t op_set,
	        byte repetitions
	    );
	    shortint ret;
		bit [7:0] A, B;
		byte iter;
		iter = 1;
		ret = {8'h00, data[0]};
	    repeat(repetitions-1)
		    begin
		    	B = data[iter];
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

	function void print_test_result ();
	    if(test_result == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result();
    endfunction : report_phase


    function void write(result_transaction t);
	    string data_str;
        shortint predicted_result;
        command_transaction cmd;
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.op == RST_ST);
	    op_set = cmd.op;
	    repeat_no = cmd.data_packet_no;
        expected = get_expected(cmd.data, cmd.op, cmd.data_packet_no);
        STATUS = t.status;
		result = t.result;
        SCOREBOARD_CHECK:
        assert (expected == t.result) begin
//	        $display("Test passed for op_set=%s", op_set.name());
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, cmd.A, cmd.B, cmd.op);
            `endif
        end
        else begin
            $display("Test FAILED %s", cmd.convert2string());
            $display("Expected: %d  received: %d", expected, result);
            $display("STATUS: %d  parity: %d", STATUS, parity_check);
            test_result = TEST_FAILED;
        end
    endfunction : write

endclass : scoreboard
