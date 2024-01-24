/**
 * testbench main
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module adder_amba_top #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 5
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
    output wire [3:0] o_leds
	);
    
    logic i_is_busy;
    
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

    // ----------------------------------------------------
    // instances
    // ----------------------------------------------------
    amba_axi4_lite uu_amba_axi4_lite(
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWPROT(S_AXI_AWPROT),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARPROT(S_AXI_ARPROT),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),
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