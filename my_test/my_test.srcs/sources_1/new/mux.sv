`timescale 1ns / 1ps

module mux(
        input logic [3:0]	i_x,
        input wire [1:0]	i_sel,
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