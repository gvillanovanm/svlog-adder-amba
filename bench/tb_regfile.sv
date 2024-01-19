/**
 * testbench template
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module tb;
    // localparams
    localparam CLK_PERIOD = 10;

    // clk and rst
    logic clk = 1'b0;
    logic rst_n = 1'b0;

	// amba write channel
	logic [31:0] i_addr_wc;
	logic [31:0] i_data_wc;

	// amba read channel
	logic [31:0] i_addr_rc;
	logic [31:0] o_data_rc;

	// amba ctrl
	logic i_en_amba_write = 0;

	// datapath
	logic i_enable_ctrl_write = 0;
	logic o_start;
	logic [31:0] i_busr;
	logic [31:0] o_r0;
	logic [31:0] o_r1;

    // dut instantiation
    regfile uu_regfile(
        .ACLK(clk),
        .ARSTn(rst_n),
        
        // amba write channel
        .i_addr_wc,
        .i_data_wc,
    
        // amba read channel
        .i_addr_rc,
        .o_data_rc,
    
        // amba ctrl
        .i_en_amba_write,
    
        // datapath
        .i_enable_ctrl_write,
        .o_start,
        .i_busr,
        .o_r0, 
        .o_r1
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

        #0.2;
        repeat(100) begin
            i_addr_wc = $urandom_range(3, 0);
            i_data_wc = $random();
            i_en_amba_write = $urandom_range(1, 0);
            @(posedge clk);
        end

        $finish();
    end


endmodule