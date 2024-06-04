`timescale 1ns / 1ps

module lab5_reg_map # (

    int G_RM_ADDR_W = 4,    // AXIL xADDR bit width
	int G_RM_DATA_B = 4     // AXIL xDATA number of bytes (B)

)(
    input logic     i_err_crc,        
                    i_err_mis_tlast,  
                    i_err_unx_tlast,
                    i_clk,
                    i_rst,

    output reg [(G_RM_DATA_B * 8) - 1 : 0]  o_length,

    if_axil.s   s_axil
    );

    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
	typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

    localparam t_xaddr LEN_ADDR	    = 'h01; 
    localparam t_xaddr LEN1_ADDR	= 'h02;
	localparam t_xaddr ERR_ADDR     = 'h04;
    localparam t_xaddr TST_ADDR	 	= 'h05;   
    t_xaddr WADDR, RADDR, t_addr;  
    
    reg [31 : 0]    RG_LEN = '0,
                    RG_STAT;

    reg [7 : 0]     q_wr_data = '0;
    reg [31 : 0]    q_rd_data;

    logic   q_wena  = 0,
            q_wdena = 0,
            q_rena  = 0,
            q_rdena = 0;

    logic   q_err_crc       = 0, 
            q_err_mis_tlast = 0, 
            q_err_unx_tlast = 0;    
    
    assign o_length = RG_LEN [7 : 0];

    assign RG_STAT = '{ 0       : q_err_crc, 
                        8       : q_err_mis_tlast, 
                        16      : q_err_unx_tlast,
                        default : 0 };

    task t_axil_init; 
        begin

            s_axil.awready  = 0;
            s_axil.wready   = 0;
            s_axil.bvalid   = 0;
            s_axil.arready  = 0;
            s_axil.rvalid   = 0;
            s_axil.bvalid   = 0;
            s_axil.bresp    = 0;
            q_wena          = 0;
            q_wdena         = 0;
            q_rena          = 0;
            q_rdena         = 0;

        end
    endtask : t_axil_init
    
    always_ff @(posedge i_clk) begin

        s_axil.awready <= 1;

        if (s_axil.awready & s_axil.awvalid) begin

            t_addr          <= s_axil.awaddr;
            WADDR           <= s_axil.awaddr;
            q_wena          <= 1;
            s_axil.awready  <= 0;

        end

        s_axil.wready <= 1;

        if (s_axil.wready & s_axil.wvalid &  q_wena) begin

            q_wr_data          <= s_axil.wdata;
            q_wdena         <= 1;
            q_wena          <= 0;
            s_axil.wready   <= 0;

        end 

        if (q_wdena) begin

            case(WADDR)

                LEN_ADDR :

                    RG_LEN [7 : 0] <= q_wr_data;

                LEN1_ADDR : 

                    RG_LEN [31 : 24] <= q_wr_data;

                TST_ADDR : 

                    RG_LEN [15 : 8] <= q_wr_data;

                default : 

                    RG_LEN [23 : 16] <= q_wr_data;

            endcase 

            q_wdena         <= 0;
            s_axil.bvalid   <= 1;

        end

        if (s_axil.bvalid & s_axil.bready) begin

            s_axil.bresp    <= '0;
            s_axil.bvalid   <= 0;

        end 

        s_axil.arready <= 1;

        if (s_axil.arready & s_axil.arvalid) begin

            t_addr          <= s_axil.araddr;
            RADDR           <= s_axil.araddr;
            q_rena          <= 1;
            s_axil.arready  <= 0;

        end 

        if (q_rena) begin

            case (RADDR)

                LEN_ADDR :

                    q_rd_data <= RG_LEN [7 : 0];

                LEN1_ADDR : 

                    q_rd_data <= RG_LEN [31 : 24];

                TST_ADDR : 

                    q_rd_data <= RG_LEN [15 : 8];

                ERR_ADDR :

                    q_rd_data <= RG_STAT;

                default :
                
                    q_rd_data <= '0;

            endcase
            
            q_rena  <= 0;
            q_rdena <= 1;

        end


        if (q_rdena) begin

            s_axil.rdata    <= q_rd_data;
            s_axil.rvalid <= 1;
            q_rdena         <= 0;

        end

        if (s_axil.rvalid & s_axil.rready) 
            s_axil.rvalid <= 0;
        
        if (i_rst) 
            t_axil_init;


        if (i_err_crc       & !s_axil.rready)   q_err_crc       <= 1;
        if (i_err_mis_tlast & !s_axil.rready)   q_err_mis_tlast <= 1;
        if (i_err_unx_tlast & !s_axil.rready)   q_err_unx_tlast <= 1;

        if (s_axil.rready) begin

            q_err_crc       <= i_err_crc;
            q_err_mis_tlast <= i_err_mis_tlast;
            q_err_unx_tlast <= i_err_unx_tlast;

        end

    end

endmodule
