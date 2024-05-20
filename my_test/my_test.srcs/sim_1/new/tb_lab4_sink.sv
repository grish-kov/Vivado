`timescale 1ns / 1ps

module tb_lab4_sink #(
    parameter T_CLK = 1.0,
    parameter N     = 8
) ();

    logic i_clk = 1; 
    logic i_rst = 0;

    int tst_crc_arr[24] = { 'h1 , 'h0 , 'h7f, 'hbc, 'h30, 'hdd, 'ha3, 'hb5, 
                        //  -     01    02    03    04    05    06    07
                        //  0     1     2     3     4     5     6     7
                            'h1b, 'h2d, 'hf0, 'h7 , 'h83, 'h47, 'h61, 'h91,    
                        //   08    09     0a   0b    0c    0d    0e    0f 
                        //   8     9      10   11    12    13    14    15
                            'h3a, 'h27 , 'hdd, 'hda, 'hda, 'hf , 'hae, 'he5}; 
                        //  10     11    12    13    14    15    16    17
                        //  16     17    18    19    20    21    22    23

    if_axis#(.N(1)) m_axis ();

    reg [3:0] j = 1;

task send_packet;

    input int       i_len;
    input reg [6:0] i_set;
    /*
        0 - send header
        1 - lower tvalid after header
        2 - send length
        3 - lower tvalid after length
        4 - lower tvalid before crc
        5 - send fake crc
        6 - make tlast
    */
    
    begin

        m_axis.tvalid <= 1;
        
        if (i_set[0]) begin
            
            m_axis.tdata <= 72;

            #(T_CLK);

            if (i_set[1]) begin
                m_axis.tvalid <= 0;
                #(T_CLK);
            end
        end
        
        m_axis.tvalid <= 1;

        if (i_set[2]) begin

            m_axis.tdata <= i_len;
            #(T_CLK);

            if (i_set[3]) begin
                m_axis.tvalid <= 0;
                #(T_CLK);
            end
        end

        m_axis.tvalid <= 1;

        for (int i = 1; i < i_len + 1; i ++) begin

            m_axis.tvalid <= 1;
			m_axis.tdata  <= i;

			#(T_CLK);
        
        end
        if (i_set[4]) begin
                m_axis.tvalid <= 0;
                #(T_CLK);
            end

        if (i_set[6]) 
            m_axis.tlast <= 1;

        if (i_set[5]) 
            m_axis.tdata <= tst_crc_arr [i_len - 1];
        else 
            m_axis.tdata <= tst_crc_arr [i_len]; 

        m_axis.tvalid <= 1;
        #(T_CLK);

        if (m_axis.tlast) 
            m_axis.tvalid <= 0;

        m_axis.tlast <= 0;
        
        #(T_CLK);

    end

endtask

    lab4_sink UUT (

        .s_axis     (m_axis),
        .i_clk      (i_clk),
        .i_rst      (i_rst)
    
    );

    always #(T_CLK / 2) i_clk = ~i_clk;
    
    initial begin

        m_axis.tvalid   <=  0;
        m_axis.tdata    <= '0;
        m_axis.tlast    <=  0;

            i_rst <= 1;
        #2  i_rst <= 0;
        
        #(T_CLK);
        send_packet(8, 7'b1000101); // true crc, no breaks

        #(T_CLK * 5);
        send_packet(8, 7'b1111111); // fake crc, with breaks

        #(T_CLK * 5);
        send_packet(12, 7'b0000101); // true crc, no breaks

        #(T_CLK * 5);
        send_packet(12, 7'b1011111); // true crc, with breaks

        #(T_CLK * 5);
        send_packet(10, 7'b1000000); // true crc, no header, no length, no breaks

        #(T_CLK * 5);
        send_packet(5, 7'b1111101); // fake crc, header without break, length & crc with breaks

        #(T_CLK * 5);
        send_packet(19, 7'b1110101);

        #(T_CLK * 5);
        send_packet(20, 7'b1110101);

        #(T_CLK * 5);
        send_packet(3, 7'b1000101);

    end
endmodule