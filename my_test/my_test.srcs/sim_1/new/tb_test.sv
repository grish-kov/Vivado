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
       
    always#(T_CLK) x[0] = !x[0];
    always#(3 * T_CLK / 2) x[1] = !x[1];
    always#(T_CLK - 5) x[2] = !x[2];
    always#(2*2*2*2 * T_CLK / 20) x[3] = !x[3];
    always#(300) a = a + 1;
    initial begin
        x='0;
        a = 2'b00;
       
    end

endmodule
