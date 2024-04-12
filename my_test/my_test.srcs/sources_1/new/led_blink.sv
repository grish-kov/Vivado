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
    parameter G_CLK_FREQUENCY  = 200.0e6, // Гц
    parameter G_BLINK_PERIOD = 1.0, // секунды
    parameter G_dir = 1 
)
(
    input wire i_rst,
    input wire i_clk,
    output logic [3:0] o_led1=4'b0001
);
    
    localparam int C_COUNTER_PERIOD = (G_BLINK_PERIOD * G_CLK_FREQUENCY);
    localparam int C_COUNTER_WIDTH = ($ceil($clog2(C_COUNTER_PERIOD + 1)));
    
    reg [C_COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == C_COUNTER_PERIOD-1) begin
            counter_value <= 0;
           
        end 
        else begin
            counter_value <= counter_value + 1;
        end;
        if (i_rst) o_led1=4'b0001;
        if(counter_value == C_COUNTER_PERIOD/2) begin
            if(G_dir) begin
                o_led1 <= o_led1 <<< 1;
                if(o_led1 == 4'b1000) o_led1 <= 4'b0001;
            end
            else begin 
                o_led1 <= o_led1 >>> 1;
                if(o_led1 == 4'b0001) o_led1 <= 4'b1000;
            end
        end;
        
    end
    
endmodule

module top
#(
    parameter G_CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real G_BLINK_PERIOD[0:1] = {1, 0.5},
    parameter logic G_dir[0:1] =  {1, 0} // секунды
)
(
    (* MARK_DEBUG="true" *) input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    (* MARK_DEBUG="true" *) output logic [7:0] o_led1
    // (* MARK_DEBUG="true" *) output logic [7:4] o_led2
);
    
    buff u_buf(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .i_rst(i_rst),
        .o_clk(o_clk)
    );
    genvar i;
    
    generate for(i = 0; i <= 1; i++) begin
        led_blink1#(
            .G_CLK_FREQUENCY(G_CLK_FREQUENCY),
            .G_BLINK_PERIOD(G_BLINK_PERIOD[i]),
            .G_dir(G_dir[i])
        )
         u_led(
            .i_rst(i_rst[i]),
            .i_clk(o_clk),
            .o_led1(o_led1[4 * (i+1) - 1 : 4 * i])    
        );
        end
    endgenerate
    
endmodule