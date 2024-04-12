`timescale 1ns / 1ps
module buff(
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

module blink#(
    parameter G_CLK_FREQUENCY  = 200.0e6, // Гц
    parameter G_BLINK_PERIOD = 1.0 // секунды
)
(
    input wire i_clk,
    output logic o_led
);
    
    localparam int C_COUNTER_PERIOD = (G_BLINK_PERIOD * G_CLK_FREQUENCY);
    localparam int C_COUNTER_WIDTH = ($ceil($clog2(C_COUNTER_PERIOD + 1)));
    
    reg [C_COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (counter_value == C_COUNTER_PERIOD-1)
            counter_value <= 0;
        else
            counter_value <= counter_value + 1;

        if(counter_value == C_COUNTER_PERIOD/2) 
            o_led <= 0;
        else
            o_led <= 1;
    end
    
endmodule

module multiplex(

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

module top_multiplex_with_blink
#(
    parameter G_CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real G_BLINK_PERIOD[3:0] = {1, 0.5, 2, 3}
)
(
    input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    output logic [3:0] o_led_d
);
    wire [3:0] m_led;
    
    buff u_buf(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .o_clk(o_clk)
    );    
    
        blink u_led[3:0](
            .i_clk(o_clk),
            .o_led(m_led)    
        );
            defparam u_led[0].G_BLINK_PERIOD = G_BLINK_PERIOD[0];
            defparam u_led[1].G_BLINK_PERIOD = G_BLINK_PERIOD[1];
            defparam u_led[2].G_BLINK_PERIOD = G_BLINK_PERIOD[2];
            defparam u_led[3].G_BLINK_PERIOD = G_BLINK_PERIOD[3];
    
    multiplex u_mpl(
        .i_x(m_led),
        .o_f(w_led),
        .i_sel(i_rst)
    );
    assign o_led_d = '{default: w_led};
endmodule
