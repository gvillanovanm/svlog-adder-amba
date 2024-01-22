/**
 * testbench main
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module tb();
    // ----------------------------------------------------
    // variables
    // ----------------------------------------------------
    logic ACLK        = 1'b0;
    logic ARSTn       = 1'b0;
    
    amba_axi4_lite_if uu_amba_axi4_lite_if(
        .ACLK(ACLK),
        .ARSTn(ARSTn)
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
        .ACLK(ACLK),
        .ARSTn(ARSTn),
        
        // amba write channel
        .i_addr_wc(w_addr_wc),
        .i_data_wc(w_data_wc),
    
        // amba read channel
        .i_addr_rc(w_addr_rc),
        .o_data_rc(w_data_rc),
    
        // amba ctrl
        .i_en_amba_write(w_en_amba_write),
        .i_rst_start(w_rst_start),
    
        // datapath
        .i_enable_ctrl_write(w_en_ctrl_write),
        .o_start(w_start),
        .o_op(w_reg2ctrl),
        .i_busr(w_busr),
        .o_r0(w_r0), 
        .o_r1(w_r1)
    );

    datapath uu_datapath(
        .i_busa(w_r0),
        .i_busb(w_r1),
        .i_op(w_ctrl2dp),
        .o_busr(w_busr)
    );

    control uu_control(
        .ACLK(ACLK),
        .ARSTn(ARSTn),

        .i_start(w_start),
        .i_ip(w_reg2ctrl),
        
        .o_is_busy(w_is_busy),
        .o_op(w_ctrl2dp),
        .o_en_ctrl_write(w_en_ctrl_write),
        .o_rst_start(w_rst_start)
    );

    // ----------------------------------------------------
    // clk
    // ----------------------------------------------------
    always #10 ACLK=~ACLK;

    // ----------------------------------------------------
    // main
    // ----------------------------------------------------
    initial begin
        $display("Starts the test here...");

        // reset routine
        @(posedge ACLK); #1;
        ARSTn = 1'b0;
        @(posedge ACLK); #1;
        ARSTn = 1'b1;
        reset();
        i_is_busy = 1'b0;

        // write channel

        // r0
        write_addr_wc('h0, 'h7);
        write_data_wc('h0000_aaaa,'hff);
        
        // r1
        write_addr_wc('h1, 'h7);
        write_data_wc('hbbbb_0000,'hff);

        // ctrl: op = 1; enable = 1;
        write_addr_wc('h3, 'h7);
        write_data_wc('h0000_0003,'hff);

        // delay
        repeat(10) 
            @(posedge ACLK);

        // read channel r2 that should be 0xbbbb_aaaa
        write_addr_rc('h2, 'hf);
        wait_data_rc();

        // delay
        repeat(10) 
            @(posedge ACLK);
        $finish();
    end

    // reset
    task reset;
        uu_amba_axi4_lite_if.AW.VALID=0;
        uu_amba_axi4_lite_if.W.VALID=0;
        uu_amba_axi4_lite_if.B.READY=0;
    endtask

    // ----------------------------------------------------
    // write channel tasks
    // ----------------------------------------------------
    // write addr
    task write_addr_wc;
        input logic [31:0]    wc_addr;
        input logic [2:0]     wc_prot;
        @(posedge ACLK); #1;
            uu_amba_axi4_lite_if.AW.VALID = 1'b1;
            uu_amba_axi4_lite_if.AW.PROT  = wc_prot;
            uu_amba_axi4_lite_if.AW.ADDR  = wc_addr;
    endtask

    // write data
    task write_data_wc;
        input logic [31:0] wc_data;
        input logic [3:0] wc_strb;
    
        @(posedge ACLK); 
            while(!uu_amba_axi4_lite_if.AW.READY) //@(posedge ACLK);
        #1;
        uu_amba_axi4_lite_if.AW.VALID = 1'b0;
        uu_amba_axi4_lite_if.W.DATA   = wc_data;
        uu_amba_axi4_lite_if.W.STRB   = wc_strb;
        uu_amba_axi4_lite_if.W.VALID  = 1'b1;
        @(posedge ACLK); 
            while(!uu_amba_axi4_lite_if.W.READY) @(posedge ACLK);
        #1;
        uu_amba_axi4_lite_if.W.VALID = 1'b0;
        uu_amba_axi4_lite_if.B.READY = 1'b1;
        @(posedge ACLK); 
            while(!uu_amba_axi4_lite_if.B.VALID) @(posedge ACLK);
        #1;
        uu_amba_axi4_lite_if.B.READY = 1'b0;
    endtask

    // ----------------------------------------------------
    // read channel tasks
    // ----------------------------------------------------
    task write_addr_rc;
        input logic [31:0] rc_addr;
        input logic [3:0] rc_prot;
        uu_amba_axi4_lite_if.AR.PROT  = rc_prot;
        uu_amba_axi4_lite_if.AR.ADDR  = rc_addr;
        uu_amba_axi4_lite_if.AR.VALID = 1'b1;
    endtask
    
    task wait_data_rc;
        @(posedge ACLK);
            while(!uu_amba_axi4_lite_if.AR.READY) @(posedge ACLK);
        #1;
        uu_amba_axi4_lite_if.AR.VALID = 1'b0;
        uu_amba_axi4_lite_if.R.READY  = 1'b1;
        @(posedge ACLK);
            while(!uu_amba_axi4_lite_if.R.VALID) @(posedge ACLK); 
        #1;
        uu_amba_axi4_lite_if.R.READY  = 1'b0;
    endtask
endmodule