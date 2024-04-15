`timescale 1ns / 1ps

/*
   parameter S0 = 4'b0001;
   parameter S1 = 4'b0010;
   parameter S2 = 4'b0100;
   parameter S3 = 4'b1000;

   reg [3:0] q_crnt_state;

   always @(posedge i_clk)
      if (i_rst) begin
         q_crnt_state <= S0;
         o_lght <= '0;
      end
      else
         case (q_crnt_state)
            S0 : begin
               if (<condition>)
                  <state> <= <next_state>;
               else if (<condition>)
                  <state> <= <next_state>;
               else
                  <state> <= <next_state>;
               <outputs> <= <values>;
            end
            S1 : begin
               if (<condition>)
                  <state> <= <next_state>;
               else if (<condition>)
                  <state> <= <next_state>;
               else
                  <state> <= <next_state>;
               <outputs> <= <values>;
            end
            S2 : begin
               if (<condition>)
                  <state> <= <next_state>;
               else if (<condition>)
                  <state> <= <next_state>;
               else
                  <state> <= <next_state>;
               <outputs> <= <values>;
            end
            S3 : begin
               if (<condition>)
                  <state> <= <next_state>;
               else if (<condition>)
                  <state> <= <next_state>;
               else
                  <state> <= <next_state>;
               <outputs> <= <values>;
            end
         endcase
*/

module lab3_top #(
	parameter int G_NUM = 4 
)(
	input wire i_clk, 
	input wire i_rst,
	input wire [G_NUM - 1:0] i_data, // data from sensors
	output logic [G_NUM - 1:0] o_lght = '0 // traffic lights control signals
);

typedef enum logic [3:0] {
    S0 = 4'b0001,      // La - green, Lb - red;
    S1 = 4'b0010,     // La - yellow, Lb - red;
    S2 = 4'b0100,     // La - red, Lb - green;
    S3 = 4'b1000       // La - red, Lb - yellow;    
} t_state;

t_state w_nxt_s, q_crnt_s;

localparam C_CNT_WID = 4;
logic [C_CNT_WID-1:0] q_timeout_cnt = '1;

// FSM next state decode
	always_comb begin
		w_next_state = q_crnt_state;
		case (q_crnt_state)
			S0: w_next_state = (i_snsr_val == 1)    ? S1_BUSY  : S0_READY;
			S1: w_next_state = (q_timeout_cnt == 0) ? S0_READY : S1_BUSY;
            // S2: w_next_state = (i_snsr_val == 1)    ? S1_BUSY  : S0_READY;
            // S3: w_next_state = (i_snsr_val == 1)    ? S1_BUSY  : S0_READY;
            // default: w_next_state = '0;
		endcase
	end

// FSM current state sync
	always_ff @(posedge i_clk)
		q_crnt_state <= (i_rst_p) ? S0_READY : w_next_state;

// timeout counter
	always_ff @(posedge i_clk)
		if (q_crnt_state == S1_BUSY)
			q_timeout_cnt <= q_timeout_cnt - 1;
		else
			q_timeout_cnt <= '1;

// FSM output decode
	always_ff @(posedge i_clk)
		o_trfl_val[0] <= (q_crnt_state == S1_BUSY);

endmodule