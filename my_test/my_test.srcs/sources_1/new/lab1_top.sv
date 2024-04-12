`timescale 1ns / 1ps

module lab1_top(
        input	[3:0]	i_x,
        input	[1:0]	i_a,
        output		o_f 
    );
    mux u_mux(
        .i_x(i_x),
        .i_a(i_a),
        .o_f(o_f)
    );
endmodule
