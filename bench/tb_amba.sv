module tb();
    // ----------------------------------------------------
    // variables
    // ----------------------------------------------------
    logic ACLK        = 1'b0;
    logic ARSTn       = 1'b0;
    
    logic i_is_busy;
    amba_axi4_lite_if uu_amba_axi4_lite_if(
        .ACLK(ACLK),
        .ARSTn(ARSTn)
    );

    // amba write channel
    logic [31:0] w_addr_wc;
    logic [31:0] w_data_wc;

    // amba read channel
    logic [31:0] w_addr_rc;
    logic [31:0] w_data_rc;

    // amba ctrl
    logic w_en_amba_write;

    // datapath
    logic i_enable_ctrl_write = 0;
    logic i_start;
    logic [31:0] i_busr;
    logic [31:0] o_r0;
    logic [31:0] o_r1;
    logic [3:0] o_strb;

    // ----------------------------------------------------
    // instances
    // ----------------------------------------------------
    amba_axi4_lite uu_amba_axi4_lite(
        .amba(uu_amba_axi4_lite_if),
        .i_is_busy(i_is_busy),
        .o_en_amba_write(w_en_amba_write),
        .o_data_wc(w_data_wc),
        .o_addr_wc(w_addr_wc),
        .o_strb(o_strb),
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
    
        // datapath
        .i_enable_ctrl_write(i_enable_ctrl_write),
        .o_start(o_start),
        .i_busr(i_busr),
        .o_r0(o_r0), 
        .o_r1(o_r1)
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
        write_addr_wc('h0, 'h7);
        write_data_wc('haaaa,'hff);
        
        write_addr_wc('h1, 'h7);
        write_data_wc('hbbbb,'hff);

        write_addr_wc('h2, 'h7);
        write_data_wc('hcccc,'hff);

        write_addr_wc('h3, 'h7);
        write_data_wc('hdddd,'hff);

        repeat(3) begin
            write_addr_wc('h4, 'h7); // illegal
            write_data_wc('heeee,'hff);
        end

        // read channel
        write_addr_rc('h0, 'hf);
        wait_data_rc();

        write_addr_rc('h1, 'hf);
        wait_data_rc();

        write_addr_rc('h2, 'hf);
        wait_data_rc();

        write_addr_rc('h3, 'hf);
        wait_data_rc();

        write_addr_rc('h4, 'hf);
        wait_data_rc();

        // finish
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