
 package alu_pkg;
	 
    import uvm_pkg::*;
    `include "uvm_macros.svh"
	//------------------------------------------------------------------------------
	// Type definitions
	//------------------------------------------------------------------------------

	// ALU op codes
	typedef enum bit[7:0] {
	    CMD_NOP  = 8'b00000000,
	    CMD_AND = 8'b00000001,
	    CMD_OR = 8'b00000010,
	    CMD_XOR = 8'b00000011,
	    CMD_ADD = 8'b00010000,
	    CMD_SUB = 8'b00100000,
	    INV_CMD = 8'b10110011,
	    RST_ST = 8'b11111111
	} operation_t;
	 
	 typedef enum bit[7:0] {
	    S_NO_ERROR  = 8'b00000000,
	    S_MISSING_DATA = 8'b00000001,
	    S_DATA_STACK_OVERFLOW = 8'b00000010,
	    S_OUTPUT_FIFO_OVERFLOW = 8'b00000100,
	    S_DATA_PARITY_ERROR = 8'b00100000,
	    S_COMMAND_PARITY_ERROR = 8'b01000000,
	    S_INVALID_COMMAND = 8'b10000000
	 } status_t;
	 
 	typedef enum {
	    COLOR_BOLD_BLACK_ON_GREEN,
	    COLOR_BOLD_BLACK_ON_RED,
	    COLOR_BOLD_BLACK_ON_YELLOW,
	    COLOR_BOLD_BLUE_ON_WHITE,
	    COLOR_BLUE_ON_WHITE,
	    COLOR_DEFAULT
	} print_color_t;
	 

    // ALU data packet
    typedef struct packed {
		bit 	 [3:0][7:0] data;
        byte unsigned data_packet_no;
        operation_t op;
    } command_s;
	 
 	typedef struct packed {
		bit 	 [15:0] result;
        bit      [7:0] 	status;
    } alu_out;


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

//------------------------------------------------------------------------------
// sequence items
//------------------------------------------------------------------------------

`include "sequence_item.svh"
`include "zeros_sequence_item.svh"
`include "ones_sequence_item.svh"

// to be converted into sequence items
`include "result_transaction.svh"

//------------------------------------------------------------------------------
// sequencer
//------------------------------------------------------------------------------

//`include "sequencer.svh"

// we can use typedef instead of the sequencer class
    typedef uvm_sequencer #(sequence_item) sequencer;


//------------------------------------------------------------------------------
// sequences
//------------------------------------------------------------------------------

`include "random_sequence.svh"
`include "ones_sequence.svh"
`include "reset_sequence.svh"
`include "zeros_sequence.svh"
	 
	 
//------------------------------------------------------------------------------
// virtual sequences
//------------------------------------------------------------------------------

`include "runall_sequence.svh"
	 
//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
`include "coverage.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// tests
//------------------------------------------------------------------------------

`include "alu_base_test.svh"
`include "full_test.svh"

 endpackage