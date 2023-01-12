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
		
	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;

	local function result_transaction get_expected(
			sequence_item cmd
		);
		result_transaction predicted;
	    shortint ret;
		bit [7:0] A, B;
		byte iter;
        predicted = new("predicted");
		iter = 1;
		ret = {8'h00, cmd.data[0]};
	    repeat(cmd.data_packet_no-1)
		    begin
		    	B = cmd.data[iter];
			    case(op_set)
			        CMD_AND : ret    = ret & B;
			        CMD_ADD : ret    = ret + B;
			        CMD_SUB : ret    = ret - B;
			        CMD_XOR : ret    = ret ^ B;
			        CMD_OR : ret    = ret | B;
				    CMD_NOP : ret    = 0;
				    INV_CMD : ret    = 0;
			    endcase
			    iter = iter + 1;
		    end
		predicted.result = ret;
		predicted.status = (cmd.op == INV_CMD)? S_INVALID_COMMAND : 0 ; 
	    return(predicted);
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
	    result_transaction predicted;
        sequence_item cmd;
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.op == RST_ST);
	    op_set = cmd.op;
	    repeat_no = cmd.data_packet_no;
        predicted = get_expected(cmd);
        STATUS = t.status;
		result = t.result;
        SCOREBOARD_CHECK:
        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            test_result = TEST_FAILED;
        end
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

endclass : scoreboard
