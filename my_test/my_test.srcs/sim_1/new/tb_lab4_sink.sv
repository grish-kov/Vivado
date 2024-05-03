`timescale 1ns / 1ps

interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N;
	
	logic         tready;
	logic         tvalid;
	logic         tlast;
	logic [W-1:0] tdata;
	
	modport m (input tready, output tvalid, tlast, tdata);
	modport s (output tready, input tvalid, tlast, tdata);
	
endinterface

module tb_lab4_sink #(
    parameter T_CLK   = 1.0
) ();

    logic i_clk='1; reg [0:1] i_rst='0;

    int tst_crc_arr[18] = {'h01, 'hd5, 'hde, 'hf7, 'h7a, 'hc3, 'hf3, 'haf, 'h62, 'h6f, 'hb8, 'h83, 'h47, 'h61, 'h91, 'h3A, 'h27, 'hdd};

    if_axis m_axis ();

task send_packet;

    input int       i_len;
    input reg [3:0] i_set;
    
    begin

        m_axis.tvalid <= 1;
        
        if (i_set[0]) begin
            
            m_axis.tdata <= 72; //send header
            #(T_CLK);

        end
        
        if (i_set[1]) begin

            m_axis.tdata <= i_len; //send length
            #(T_CLK);

        end
        
        for (int i = 0; i < i_len; i ++) begin //send packet

            m_axis.tvalid <= 1;
			m_axis.tdata  <= i;
			#(T_CLK);
        
        end
        m_axis.tlast <= 1;

        if (i_set[2]) 
            m_axis.tdata<=tst_crc_arr[i_len - 1]; //send real precalculated CRC
        else 
            m_axis.tdata<=tst_crc_arr[i_len]; //send fake CRC
        
        #(T_CLK);
        
        m_axis.tlast <= 0;
        m_axis.tvalid <= 0; //end packet

        if (i_set[3]) 
            #(T_CLK);

    end

endtask

    lab4_sink
    UUT (
        .s_axis     (m_axis),
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .o_err      (o_err)
    );
    

    initial begin

        // i_rst = '1;
        // #2;
        // i_rst = '0;
        m_axis.tlast <= '0;

        send_packet(10, 4'b1111);   //good
        send_packet(12, 4'b0111);   //good
        send_packet(8,  4'b1111);   //good
        send_packet(10, 4'b1111);   //bad
        send_packet(10, 4'b1101);   //bad
    
        send_packet(4, 4'b0111);    //good
        send_packet(6, 4'b0111);    //good
    
        send_packet(10, 4'b1011);   //bad
        send_packet(10, 4'b1001);   //bad
        send_packet(8,  4'b1001);   //bad
        send_packet(10, 4'b0111);   //good
        send_packet(10, 4'b1111);   //good
        
        #500;
        i_rst = '1;
        #590;
        i_rst = '0;
        
        send_packet(10,3'b111);
        m_axis.tvalid <= '0;


    end
endmodule