`timescale 1ns / 1ps

module lab3_top (
	input wire i_clk, 
	input wire i_rst,
	input wire i_dA,
	input wire i_dB,
	output logic [1:0] o_lA = '0,
	output logic [1:0] o_lB = '0
);

/*
    S0 0001 La - green,     Lb - red;       00 - nothing
    S1 0010 La - yellow,    Lb - red;       01 - red
    S2 0100 La - red,       Lb - green;     10 - green
    S3 1000 La - red,       Lb - yellow;    11 - yellow
*/
    logic [3:0] q_timeout_cnt = '0;

   parameter S0 = 4'b0001;
   parameter S1 = 4'b0010;
   parameter S2 = 4'b0100;
   parameter S3 = 4'b1000;

    reg [3:0] q_crnt_s = S0;
    reg [3:0] w_nxt_s;
    
    always @(posedge i_clk) begin
        if (q_crnt_s == S0 | q_crnt_s == S2)
             q_timeout_cnt = (q_timeout_cnt < 4'b1111) ? q_timeout_cnt + 1 : q_timeout_cnt;
        else
            q_timeout_cnt = '0;
        if (i_rst) begin
            q_crnt_s <= S0;
            o_lA <= '1;
            o_lB <= '1;
            q_timeout_cnt <= '0;
		end else begin
        	w_nxt_s = q_crnt_s;
            case (q_crnt_s)
                S0: begin
                    if ( (~i_dA | q_timeout_cnt == 4'b1111) & i_dB)
                        q_crnt_s <= S1;
                        o_lA <= 2'b10;
                        o_lB <= 2'b01;
                    end
                S1: begin
                    q_crnt_s <= S2;
                    o_lA <= 2'b11;
                    o_lB <= 2'b01;
                    end
                S2: begin
                    if ( (~i_dB | q_timeout_cnt == 4'b1111) & i_dA)
                        q_crnt_s <= S3;
                        o_lB <= 2'b10;
                        o_lA <= 2'b01;
                    end
                S3: begin
                    q_crnt_s <= S0;
                    o_lB <= 2'b11;
                    o_lA <= 2'b01;
                    end
                default: q_crnt_s <= S0;
            endcase
        end
    end
endmodule