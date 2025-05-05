`timescale 1ns / 1ps

module cpu_tb;

    // Testbench signals
    logic clk;
    logic reset_n;

    // Instantiate the DUT (Device Under Test)
    cpu dut (
        .clk(clk),
        .reset_n(reset_n)
    );

    // Clock generation: 10ns周期
    always #5 clk = ~clk;

    // Initial procedure
    initial begin
        $display("=== CPU Testbench Start ===");
        clk = 0;
        reset_n = 0;

        // Apply reset for a few cycles
        #20;
        reset_n = 1;

        // Wait for some cycles to observe behavior
        repeat (1000) @(posedge clk);

        $display("=== CPU Testbench Finish ===");
        $stop;
    end

endmodule
