/**
 * testbench template
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */

module tb;
    // localparams
    localparam CLK_PERIOD = 10;

    // signals
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic a, b, r;

	logic [31:0] addr_in;
	logic [31:0] data_in;
	logic [31:0] data_out;
	logic rw; // r: 0, w: 1
	logic [31:0] r0; 
	logic [31:0] r1; 
	logic [31:0] r2;

    // dut instantiation
    regfile uu_regfile(
        .ACLK(clk),
        .ARSTn(rst_n),
        .addr_in(addr_in),
        .data_in(data_in),
        .rw(rw), // r: 0, w: 1
        .data_out(data_out),
        .r0(r0),
        .r1(r1),
        .r2(r2)
    );

    // clk generator
    always #(CLK_PERIOD/2) clk=~clk;

    // main block
    initial begin

        // codes here ...
        $display("Starting simulation...");

        // nothing
        rst_n = 1; 
        #0.2;
        @(posedge clk);

        // apply reset and wait a clk
        rst_n = 0;
        #0.2;
        @(posedge clk);

        // remove rst
        rst_n = 1;
        #0.2;
        @(posedge clk);

        // add a value
        data_in = 'hdeadbeef;
        addr_in = 1;
        rw      = 1;
        #0.2;
        @(posedge clk);

        // write a cycle
        #0.2;
        @(posedge clk);

        $display("r0 = 0x%x", r0);
        $display("r1 = 0x%x", r1);
        $display("r2 = 0x%x", r2);

        $finish();
    end


endmodule