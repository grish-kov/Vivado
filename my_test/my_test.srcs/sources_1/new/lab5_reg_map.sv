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
                                            o_err,

    if_axil.s   s_axil
    );

    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
	typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

    localparam t_xaddr LEN_ADDR	    = 'h00; 
    localparam t_xaddr LEN1_ADDR	= 'h02;
	localparam t_xaddr ERR_ADDR     = 'h04;
    t_xaddr ADDR;  
    
    reg [31 : 0]    RG_LEN,
                    RG_STAT;

    reg [7 : 0] w_len = '0;

    assign o_length = w_len;

    assign RG_STAT = '{ 0       : i_err_crc, 
                        8       : i_err_mis_tlast, 
                        16      : i_err_unx_tlast,
                        default : 0 };

    task t_axil_init; 
        begin

            s_axil.awready = 0;
            s_axil.wready  = 0;
            s_axil.bvalid  = 0;
            s_axil.arready = 0;
            s_axil.rvalid  = 0;
            s_axil.bvalid  = 0;
            s_axil.bresp   = 0;

        end
    endtask : t_axil_init
    
    always_ff @(posedge i_clk) begin

        s_axil.awready <= 1;

        if (s_axil.awready & s_axil.awvalid) begin

            ADDR            <= s_axil.awaddr;
            s_axil.awready  <= 0;

        end

        s_axil.wready <= 1;

        if (s_axil.wready & s_axil.wvalid) begin

            w_len           <= s_axil.wdata;
            s_axil.wready   <= 0;

        end 

        s_axil.bvalid <= 1;

        if (s_axil.bvalid & s_axil.bready) begin

            s_axil.bresp    <= '0;
            s_axil.bvalid   <=  0;

        end 

        case(ADDR)

            LEN_ADDR :

                RG_LEN [7 : 0] = w_len;

            LEN1_ADDR : 

                RG_LEN [31 : 24] = w_len;

        endcase

        s_axil.arready <= 1;

        if (s_axil.arready & s_axil.arvalid) begin

            ADDR            <= s_axil.araddr;
            s_axil.arready  <= 0;

        end 

        s_axil.rvalid <= 0;

        if (!s_axil.rvalid & s_axil.rready) begin

            case(ADDR)

                LEN_ADDR :

                    s_axil.rdata <= RG_LEN [7 : 0];

                LEN1_ADDR :

                    s_axil.rdata <= RG_LEN [31 : 24];

                ERR_ADDR :

                    s_axil.rdata <= RG_STAT;

                default : 

                    s_axil.rdata <= '1;

            endcase

            s_axil.rvalid <= 1;

        end

        if (i_rst) 
            t_axil_init;
    
    end

endmodule
