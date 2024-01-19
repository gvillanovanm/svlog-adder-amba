module tb();
	logic ACLK  	  = 1'b0;
	logic ARSTn 	  = 1'b0;

	amba_axi4_lite_if uu_amba_axi4_lite_if(.ACLK(ACLK),.ARSTn(ARSTn));

    amba_axi4_lite uu_amba_axi4_lite(
        .amba(uu_amba_axi4_lite_if)
    );

    initial begin
        $display("Starts the test here...");
        $finish();
    end
endmodule