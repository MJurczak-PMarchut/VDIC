
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
		byte 	 data [10];
        byte unsigned data_packet_no;
        operation_t op;
    } command_s;


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
// testbench classes
//------------------------------------------------------------------------------
`include "coverage.svh"
`include "scoreboard.svh"
`include "base_tester.svh"
`include "random_tester.svh"
`include "zeros_tester.svh"
`include "ones_tester.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
`include "random_test.svh"
`include "zeros_test.svh"
`include "ones_test.svh"
 endpackage