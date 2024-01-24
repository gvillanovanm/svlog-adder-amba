/**
 * testbench main
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module tb();
    // ----------------------------------------------------
    // localparam
    // ----------------------------------------------------
    localparam C_S_AXI_DATA_WIDTH = 32;
    localparam C_S_AXI_ADDR_WIDTH = 32;

    // ----------------------------------------------------
    // variables
    // ----------------------------------------------------
    logic S_AXI_ACLK     = 1'b0;
    logic S_AXI_ARESETN  = 1'b0;
    logic [C_S_AXI_DATA_WIDTH-1 : 0] data_read_from_axi;

    // aw
    logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR;
    logic [2 : 0] S_AXI_AWPROT;
    logic  S_AXI_AWVALID;
    logic S_AXI_AWREADY;

    // w
    logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA;
    logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB;
    logic  S_AXI_WVALID;
    logic  S_AXI_WREADY;

    // b
    logic [1:0] S_AXI_BRESP;
    logic S_AXI_BVALID;
    logic S_AXI_BREADY;

    // ar
    logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR;
    logic [2 : 0] S_AXI_ARPROT;
    logic S_AXI_ARVALID;
    logic S_AXI_ARREADY;

    // r
    logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA;
    logic [1:0] S_AXI_RRESP;
    logic S_AXI_RVALID;
    logic S_AXI_RREADY;

    // user
    logic [3:0] o_leds;

    // auxiliar
    logic [C_S_AXI_DATA_WIDTH-1 : 0] addr;
    logic [C_S_AXI_DATA_WIDTH-1 : 0] wc_data;
    logic [C_S_AXI_DATA_WIDTH-1 : 0] rc_data;
    logic op;
    logic done = 0;
    logic [C_S_AXI_DATA_WIDTH-1 : 0] r0, r1, r;

    // ----------------------------------------------------
    // clk
    // ----------------------------------------------------
    always #10 S_AXI_ACLK=~S_AXI_ACLK;

    // ----------------------------------------------------
    // instances
    // ----------------------------------------------------
    adder_amba_top uu_adder_amba_top(
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),

        // aw
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWPROT(S_AXI_AWPROT),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),

        // w
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),

        // b
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),

        // ar
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARPROT(S_AXI_ARPROT),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),

        // r
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),

        // user leds...
        .led0_b(o_leds[0]),
        .led0_g(o_leds[1]),
        .led0_r(o_leds[2]),
        .led1_b(o_leds[3])
    );

    // ----------------------------------------------------
    // main
    // ----------------------------------------------------
    initial begin
        $display("Starts the test here...");
        // choose operation to be made
        op = 0; // 1: add ; 0: sub

        // reset routine
        @(posedge S_AXI_ACLK); @(posedge S_AXI_ACLK);
        S_AXI_ARESETN = 1'b0;
        @(posedge S_AXI_ACLK); @(posedge S_AXI_ACLK);
        S_AXI_ARESETN = 1'b1;
        reset();

        // write value in r0
        $display("r0 ---------------------------------\n");
        addr = 32'h0000_0000;
        wc_data = 32'h0000_0002;
        r0 = wc_data;
        data_read_from_axi = 0;
        perform_write_read_and_check(addr, wc_data);
        $display("------------------------------------\n\n");

        // write value in r1
        $display("r1 ---------------------------------\n");
        addr = 32'h0000_0004;
        wc_data = 32'h0000_0001;
        r1 = wc_data;
        data_read_from_axi = 0;
        perform_write_read_and_check(addr, wc_data);
        $display("------------------------------------\n\n");

        // enable computation in ctrl and status
        addr = 32'h0000_000c;
        wc_data = {30'h0,{op,1'b1}};
        data_read_from_axi = 0;
        write_addr_wc(addr, 'h7);
        write_data_wc(wc_data,'hff);

        // read if computation is finished in ctrl and status (polling)
        $display("status -----------------------------\n");
        while(done == 0) begin
            addr = 32'h0000_000c;
            data_read_from_axi = 0;
            write_addr_rc(addr, 'h7);
            wait_data_rc();
            done = data_read_from_axi[31];
            $display("polling: %b, %x", done, data_read_from_axi);
            @(posedge S_AXI_ACLK);
        end
        $display("------------------------------------\n\n");

        // read register r2
        addr = 32'h0000_0008;
        data_read_from_axi = 0;
        write_addr_rc(addr, 'h7);
        wait_data_rc();

        // check result
        r = (op) ? r0+r1 : r0-r1;
        if(r == data_read_from_axi)
            $display("PASS!");
        else
            $display("FAIL!");

        // write value in r5 - for blinky leds
        $display("r5 ---------------------------------\n");
        $display("bef - o_leds is 0b%b\n", o_leds);
        addr = 32'h0000_0010;
        wc_data = 32'h0000_000f;
        perform_write_read_and_check(addr, wc_data);
        $display("\naft - o_leds is 0b%b", o_leds);
        $display("------------------------------------\n\n");
        
        $finish();
    end

    // reset
    task reset;
        S_AXI_AWVALID = 0;
        S_AXI_WVALID = 0;
        S_AXI_BREADY = 0;
    endtask

    // write addr
    task write_addr_wc;
        input logic [31:0] wc_addr;
        input logic [2:0]  wc_prot;
        @(posedge S_AXI_ACLK); @(posedge S_AXI_ACLK);
            S_AXI_AWVALID = 1'b1;
            S_AXI_AWPROT  = wc_prot;
            S_AXI_AWADDR  = wc_addr;
    endtask

    // write data
    task write_data_wc;
        input logic [31:0] wc_data;
        input logic [3:0] wc_strb;

        @(posedge S_AXI_ACLK); 
            while(!S_AXI_AWREADY) @(posedge S_AXI_ACLK);

        @(posedge S_AXI_ACLK);
        S_AXI_AWVALID = 1'b0;
        S_AXI_WDATA   = wc_data;
        S_AXI_WSTRB   = wc_strb;
        S_AXI_WVALID  = 1'b1;
        @(posedge S_AXI_ACLK); 
            while(!S_AXI_WREADY) @(posedge S_AXI_ACLK);

        @(posedge S_AXI_ACLK);
        S_AXI_WVALID = 1'b0;
        S_AXI_BREADY = 1'b1;
        @(posedge S_AXI_ACLK); 
            while(!S_AXI_BVALID) @(posedge S_AXI_ACLK);

        @(posedge S_AXI_ACLK);
        S_AXI_BREADY = 1'b0;
    endtask

    // read channel tasks
    task write_addr_rc;
        input logic [31:0] rc_addr;
        input logic [3:0]  rc_prot;
        S_AXI_ARPROT  = rc_prot;
        S_AXI_ARADDR  = rc_addr;
        S_AXI_ARVALID = 1'b1;
    endtask
    
    task wait_data_rc;
        logic [31:0] aux_data;
        @(posedge S_AXI_ACLK);
            while(!S_AXI_ARREADY) @(posedge S_AXI_ACLK);
        @(posedge S_AXI_ACLK);

        S_AXI_ARVALID = 1'b0;
        S_AXI_RREADY  = 1'b1;
        data_read_from_axi = S_AXI_RDATA;
        @(posedge S_AXI_ACLK);
            while(!S_AXI_RVALID) begin
                @(posedge S_AXI_ACLK); 
            end
        @(posedge S_AXI_ACLK);
        S_AXI_RREADY  = 1'b0;
    endtask

    task perform_write_read_and_check(input logic [31:0] addr, input logic [31:0] wc_data);
        // write
        $display("Write data %x", wc_data);
        $display("      Addr 0x%4x\n", addr);
        write_addr_wc(addr, 'h7);
        write_data_wc(wc_data,'hff);

        // read
        write_addr_rc(addr, 'h7);
        wait_data_rc();
        $display(" Read data %x", data_read_from_axi);

        // check
        assert(wc_data === data_read_from_axi);
    endtask
endmodule
