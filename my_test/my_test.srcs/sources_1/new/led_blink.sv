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

module led_blink1
#(
    parameter CLK_FREQUENCY = 200.0e6, // Гц
    parameter BLINK_PERIOD = 1.0 // секунды
)
(
    input wire i_rst,
    input wire i_clk,
    output logic [3:0] o_led1=4'b0001
);

    localparam int COUNTER_PERIOD = (BLINK_PERIOD * CLK_FREQUENCY);
    localparam int COUNTER_WIDTH = ($ceil($clog2(COUNTER_PERIOD + 1)));
    
    reg [COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == COUNTER_PERIOD-1) begin
            counter_value <= 0;
           
        end 
        else begin
            counter_value <= counter_value + 1;
        end;
        if (i_rst) o_led1=4'b0001;
        if(counter_value == COUNTER_PERIOD/2) begin
            o_led1 <= o_led1 <<< 1;
            if(o_led1 == 4'b1000) o_led1 <= 4'b0001;
//            o_led <= () ? : ;
        end;
        
    end
    
endmodule

module led_blink2
#(
    parameter CLK_FREQUENCY = 50.0e6, // Гц
    parameter BLINK_PERIOD = 1.0 // секунды
)
(

    input wire i_rst,
    input wire i_clk,
    output logic [7:4] o_led2=4'b0001
);

    localparam int COUNTER_PERIOD = (BLINK_PERIOD * CLK_FREQUENCY);
    localparam int COUNTER_WIDTH = ($ceil($clog2(COUNTER_PERIOD + 1)));

    
    reg [COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == COUNTER_PERIOD-1) begin
            counter_value <= 0;
           
        end 
        else begin
            counter_value <= counter_value + 1;
        end;
        if (i_rst) o_led2=4'b0001;
        if(counter_value == COUNTER_PERIOD/2) begin
            o_led2 <= o_led2 <<< 1;
            if(o_led2 == 4'b1000) o_led2 <= 4'b0001;
//            o_led <= () ? : ;
        end;
        
    end
    
endmodule

module top(
    input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    output logic [3:0] o_led1,
    output logic [7:4] o_led2
);
    
    buff BUFF(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .i_rst(i_rst),
        .o_clk(o_clk)
    );
    
    led_blink1 led1(
        .i_rst(i_rst[0]),
        .i_clk(o_clk),
        .o_led1(o_led1)    
    );
    
    led_blink2 led2(
        .i_rst(i_rst[1]),
        .i_clk(o_clk),
        .o_led2(o_led2)    
    );
    
endmodule