`timescale 1ns / 1ps

//interface if_axis #(parameter int N = 1) ();
//	localparam W = 8 * N;
	
//	logic         tready;
//	logic         tvalid;
//	logic         tlast;
//	logic [W-1:0] tdata;
	
//	modport m (input tready, output tvalid, tlast, tdata);
//	modport s (output tready, input tvalid, tlast, tdata);
	
//endinterface

module tb_lab4_sink #(
    parameter T_CLK = 1.0,
    parameter N     = 8
) ();

    logic i_clk = 1; 
    logic i_rst = 0;

    int tst_crc_arr[18] = {'h01, 'hd5, 'hde, 'hf7, 'h7a, 'hc3, 'hf3, 'haf, 'h62,
                        //  -     0     1     2     3     4     5     6     7
                           'h6f, 'hb8, 'h62, 'hc1, 'h8a, 'h41, 'he4, 'h51, 'hc9};
                        //  8     9     10    11    12    13    14    15    16  

    if_axis m_axis ();

    reg [3:0] j = 1;

task send_packet;

    input int       i_len;
    input reg [3:0] i_set;
    
    begin

        m_axis.tvalid <= 1;
        
        if (i_set[0]) begin
            
            m_axis.tdata <= 72;
            #(T_CLK);

        end
        
        if (i_set[1]) begin

            m_axis.tdata <= i_len;
            #(T_CLK);

        end
        
        for (int i = 0; i < i_len; i ++) begin

            m_axis.tvalid <= 1;
			m_axis.tdata  <= i;

			#(T_CLK);
        
        end
        
        m_axis.tlast <= 1;

        if (i_set[2]) 
            m_axis.tdata <= tst_crc_arr [i_len];
        else 
            m_axis.tdata <= tst_crc_arr [i_len - 1]; 
        
        #(T_CLK);

        if (m_axis.tlast) 
            m_axis.tvalid <= 0;

        m_axis.tlast <= 0;
        //end packet

        if (i_set[3]) 
            #(T_CLK);

    end

endtask

    lab4_sink #(
        .N(N)
    ) UUT (

        .s_axis     (m_axis),
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .o_err      (o_err)
    
    );

    always #(T_CLK / 2) i_clk = ~i_clk;
    
    initial begin

        m_axis.tvalid   <=  0;
        m_axis.tdata    <= '0;
        m_axis.tlast    <=  0;

            i_rst <= 1;
        #2  i_rst <= 0;
        
        send_packet(10, 4'b1111);   //good  1
        j = j + 1;
        send_packet(12, 4'b0111);   //good  2
        j = j + 1;
        send_packet(8,  4'b1111);   //good  3
        j = j + 1;
        send_packet(10, 4'b1111);   //bad   4
        j = j + 1;
        send_packet(10, 4'b1101);   //bad   5 
        j = j + 1;

        send_packet(4, 4'b0111);    //good  6
        j = j + 1;
        send_packet(6, 4'b0111);    //good  7
        j = j + 1;
    
        send_packet(10, 4'b1011);   //bad   8
        j = j + 1;
        send_packet(10, 4'b1001);   //bad   9
        j = j + 1;
        send_packet(8,  4'b1001);   //bad   10
        j = j + 1;
        send_packet(10, 4'b0111);   //good  11
        j = j + 1;
        send_packet(10, 4'b1111);   //good  12
        j = j + 1; 
        
        // m_axis.tvalid <= 0;

    end
endmodule