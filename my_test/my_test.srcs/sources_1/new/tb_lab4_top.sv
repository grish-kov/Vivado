`timescale 1ns / 1ps

module tb_lab4_top #(
    parameter C_T_CLK = 1.0
) ();
    logic       i_clk = 1;
    logic [2:0] i_rst = 3'b000;
    
    lab4_top UUT (
        .i_clk      (i_clk),
        .i_rst      (i_rst)
    );
    
    always #(C_T_CLK / 2) i_clk = ~i_clk;

    initial begin

        i_rst = 3'b101;
        #10 i_rst = 3'b010;

    end
    // always #(C_T_CLK * 130) begin

    //         i_rst[2] = 1;
    //         #1 i_rst[2] = 0;
    // end
    // always #(C_T_CLK * 323)begin

    //         i_rst[1] = 0;
    //         #1 i_rst[1] = 1;
    // end
    // always #(C_T_CLK * 48)begin

    //         i_rst[0] = 1;
    //         #1 i_rst[0] = 0;
    // end

endmodule