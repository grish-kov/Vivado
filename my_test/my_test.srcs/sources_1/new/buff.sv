`timescale 1ns / 1ps
module buff(
    input wire [1:0] i_rst,
    input wire i_clk_n,
    input wire i_clk_p,
    output wire o_clk    
);
    IBUFDS #(
      .DIFF_TERM("FALSE"),
      .IBUF_LOW_PWR("TRUE"),
      .IOSTANDARD("DEFAULT")
    ) IBUFDS_inst (
      .O(w_clk_in),
      .I(i_clk_p),
      .IB(i_clk_n)
    );
    
    BUFG BUFG_inst (
      .O(o_clk),
      .I(w_clk_in)
    );
endmodule 
