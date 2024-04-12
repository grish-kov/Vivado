`timescale 1ns / 1ps
module tb_test
    #(parameter G_T_CLK = 20)
    ();
    logic [3:0] i_x;
    logic [1:0] i_a;
    logic o_f;
    
    test
    UUT(
        .i_x(i_x),
        .i_a(i_a),
        .o_f(o_f)
    );
       
    always#(G_T_CLK) i_x[0] = !i_x[0];
    always#(3 * G_T_CLK / 2) i_x[1] = !i_x[1];
    always#(G_T_CLK - 5) i_x[2] = !i_x[2];
    always#(2*2*2*2 * G_T_CLK / 20) i_x[3] = !i_x[3];
    always#(300) i_a = i_a + 1;
    initial begin
        i_x='0;
        i_a = 2'b00;
       
    end

endmodule
