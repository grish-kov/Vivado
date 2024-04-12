`timescale 1ns / 1ps

module mux#(
        parameter int G_DAT_WIDTH = 4,
        parameter int G_SEL_WIDTH = $ceil($clog2(G_DAT_WIDTH))
)(
        input logic [G_DAT_WIDTH - 1:0]	i_x,
        input wire [G_SEL_WIDTH - 1:0]	i_sel,
        output logic o_f 
        );
     
    always @ (*) begin
        case(i_sel)
            0       :  o_f = i_x[0];
            1       :  o_f = i_x[1];
            2       :  o_f = i_x[2];
            3       :  o_f = i_x[3];      
            default :  o_f = 0;
        endcase
    end

endmodule