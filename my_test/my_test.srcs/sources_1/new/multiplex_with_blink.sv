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
    parameter CLK_FREQUENCY  = 200.0e6, // Гц
    parameter BLINK_PERIOD = 1.0 // секунды
)
(
    input wire i_clk,
    output logic o_led
);
    
    localparam int COUNTER_PERIOD = (BLINK_PERIOD * CLK_FREQUENCY);
    localparam int COUNTER_WIDTH = ($ceil($clog2(COUNTER_PERIOD + 1)));
    
    reg [COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (counter_value == COUNTER_PERIOD-1)
            counter_value <= 0;
        else
            counter_value <= counter_value + 1;

        if(counter_value == COUNTER_PERIOD/2) 
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

module multiplex_with_blink
#(
    parameter CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real BLINK_PERIOD[3:0] = {1, 0.5, 2, 3}
)
(
    input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    output logic [3:0] o_led_d
);
    wire [3:0] m_led;
    genvar i;
    
    buff BUFF(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .o_clk(o_clk)
    );    
    
    //generate for(i = 0; i <=3; i++) begin
        blink led[3:0](
            .i_clk(o_clk),
            .o_led(m_led)    
        );
            defparam led[0].BLINK_PERIOD = BLINK_PERIOD[0];
            defparam led[1].BLINK_PERIOD = BLINK_PERIOD[1];
            defparam led[2].BLINK_PERIOD = BLINK_PERIOD[2];
            defparam led[3].BLINK_PERIOD = BLINK_PERIOD[3];
            
        
        //end
    //endgenerate
    
    multiplex mpl(
        .i_x(m_led),
        .o_f(w_led),
        .i_sel(i_rst)
    );
    assign o_led_d = '{default: w_led};
endmodule