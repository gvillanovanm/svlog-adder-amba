/**
 * testbench main
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module adder_amba_top #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)(
    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,

    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire  S_AXI_AWVALID,
    output wire  S_AXI_AWREADY,

    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WVALID,
    output wire  S_AXI_WREADY,

    output wire [1 : 0] S_AXI_BRESP,
    output wire  S_AXI_BVALID,
    input wire  S_AXI_BREADY,

    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire  S_AXI_ARVALID,
    output wire  S_AXI_ARREADY,

    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire  S_AXI_RVALID,
    input wire  S_AXI_RREADY,

    // user 
    output wire led0_b,
    output wire led0_g,
    output wire led0_r,
    output wire led1_b
	);
    
    amba_axi4_lite_if uu_amba_axi4_lite_if(
        .ACLK(S_AXI_ACLK),
        .ARSTn(S_AXI_ARESETN)
    );

    logic i_is_busy;
    logic [3:0] o_leds;

    // amba / reg
    logic [3:0] w_strb;
    logic [31:0] w_addr_wc;
    logic [31:0] w_data_wc;
    logic [31:0] w_addr_rc;
    logic [31:0] w_data_rc;
    logic w_en_amba_write;

    // datapath / reg / ctrl
    logic [31:0] w_r0;
    logic [31:0] w_r1;
    logic [31:0] w_busr;
    logic w_reg2ctrl;
    logic w_ctrl2dp;
    logic w_en_ctrl_write;
    logic w_start;
    logic w_is_busy;
    logic w_rst_start;
    logic w_result_is_done;

    assign uu_amba_axi4_lite_if.AW.ADDR = S_AXI_AWADDR;
    assign uu_amba_axi4_lite_if.AW.VALID = S_AXI_AWVALID;
    assign S_AXI_AWREADY = uu_amba_axi4_lite_if.AW.READY;
    assign uu_amba_axi4_lite_if.AW.PROT = S_AXI_AWPROT;

    assign uu_amba_axi4_lite_if.W.VALID = S_AXI_WVALID;
    assign S_AXI_WREADY = uu_amba_axi4_lite_if.W.READY;
    assign uu_amba_axi4_lite_if.W.DATA = S_AXI_WDATA;
    assign uu_amba_axi4_lite_if.W.STRB = S_AXI_WSTRB;

    assign uu_amba_axi4_lite_if.B.READY = S_AXI_BREADY;
    assign S_AXI_BVALID = uu_amba_axi4_lite_if.B.VALID;
    assign S_AXI_BRESP = uu_amba_axi4_lite_if.B.RESP;
    
    assign uu_amba_axi4_lite_if.AR.VALID = S_AXI_ARVALID;
    assign S_AXI_ARREADY = uu_amba_axi4_lite_if.AR.READY;
    assign uu_amba_axi4_lite_if.AR.ADDR = S_AXI_ARADDR;
    assign uu_amba_axi4_lite_if.AR.PROT = S_AXI_ARPROT;

    assign uu_amba_axi4_lite_if.R.READY = S_AXI_RREADY;
    assign S_AXI_RVALID = uu_amba_axi4_lite_if.R.VALID;
    assign S_AXI_RDATA = uu_amba_axi4_lite_if.R.DATA;
    assign S_AXI_RRESP = uu_amba_axi4_lite_if.R.RESP;

    assign led0_b = o_leds[0];
    assign led0_g = o_leds[1];
    assign led0_r = o_leds[2];
    assign led1_b = o_leds[3];

    // ----------------------------------------------------
    // instances
    // ----------------------------------------------------
    amba_axi4_lite uu_amba_axi4_lite(
        .amba(uu_amba_axi4_lite_if),
        .i_is_busy(w_is_busy),
        .o_en_amba_write(w_en_amba_write),
        .o_data_wc(w_data_wc),
        .o_addr_wc(w_addr_wc),
        .o_strb(w_strb),
        .i_data_rc(w_data_rc),
        .o_addr_rc(w_addr_rc)
    );

    regfile uu_regfile(
        .ACLK(S_AXI_ACLK),
        .ARSTn(S_AXI_ARESETN),

        // amba write channel
        .i_addr_wc(w_addr_wc),
        .i_data_wc(w_data_wc),
    
        // amba read channel
        .i_addr_rc(w_addr_rc),
        .o_data_rc(w_data_rc),
    
        // amba ctrl
        .i_en_amba_write(w_en_amba_write),
        .i_rst_start(w_rst_start),
        .i_result_is_done(w_result_is_done),

        // datapath
        .i_enable_ctrl_write(w_en_ctrl_write),
        .o_start(w_start),
        .o_op(w_reg2ctrl),
        .i_busr(w_busr),
        .o_r0(w_r0), 
        .o_r1(w_r1),
        .o_leds(o_leds)
    );

    datapath uu_datapath(
        .i_busa(w_r0),
        .i_busb(w_r1),
        .i_op(w_ctrl2dp),
        .o_busr(w_busr)
    );

    control uu_control(
        .ACLK(S_AXI_ACLK),
        .ARSTn(S_AXI_ARESETN),

        .i_start(w_start),
        .i_ip(w_reg2ctrl),
        
        .o_is_busy(w_is_busy),
        .o_op(w_ctrl2dp),
        .o_en_ctrl_write(w_en_ctrl_write),
        .o_rst_start(w_rst_start),
        .o_result_is_done(w_result_is_done)
    );
endmodule