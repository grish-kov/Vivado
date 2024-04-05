`timescale 1ns / 1ps
module tb_test
    #(parameter T_CLK = 20)
    ();
    logic [3:0] x;
    logic [1:0] a;
    logic f;

    test
    UUT(
        .x(x),
        .a(a),
        .f(f)
    );
    
    initial begin
        
        x[0] = T_CLK;
        x[1] = (3 * T_CLK)/2;
        x[2] = T_CLK - 5;
        x[3] = (2*2*2*2 * T_CLK)/20;
        
    end

endmodule
