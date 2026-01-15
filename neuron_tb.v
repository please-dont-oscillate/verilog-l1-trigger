`timescale 1ns / 1ps

module neuron_tb;

    // 1. INPUTS (Registers that we pilot)
    reg clk;
    reg rst;
    reg signed [7:0] x1, x2;
    reg signed [7:0] w1, w2;
    reg signed [7:0] b;

    // 2. OUTPUTS (Threads we observe)
    wire signed [15:0] y;

    // 3. We instantiate the neuron (DUT: Device Under Test)
    neuron uut (
        .clk(clk), 
        .rst(rst), 
        .x1(x1), .x2(x2), 
        .w1(w1), .w2(w2), 
        .b(b), 
        .y(y)
    );

    // 4. Clock Generator (wakes up circuit every 10ns)
    always #5 clk = ~clk; 

    // 5. The test scenario
    initial begin
        // Initial setup for GTKWave
        $dumpfile("neuron_wave.vcd"); // Create the wave file
        $dumpvars(0, neuron_tb);      // Record all variables

        // Initialize All
        clk = 0;
        rst = 1;
        x1 = 0; x2 = 0; w1 = 0; w2 = 0; b = 0;

        // Wait 20ns and undo the Reset
        #20;
        rst = 0;

        // --- TEST CASE 1: Positive ---
        // X1=10, W1=2  -> 20
        // X2=5,  W2=3  -> 15
        // Bias = 0
        // Expected: 20 + 15 + 0 = 35
        x1 = 10; w1 = 2;
        x2 = 5;  w2 = 3;
        b = 0;
        #20; // Wait for the clock to process (it takes 1-2 cycles in our code)

        // --- TEST CASE 2: ReLU (Negativo) ---
        // X1=10, W1=-5 -> -50
        // X2=2,  W2=2  -> 4
        // Bias = 10
        // Sum: -50 + 4 + 10 = -36
        // expected Output ReLU: 0
        x1 = 10; w1 = -5;
        x2 = 2;  w2 = 2;
        b = 10;
        #20;

        // THE END? (I hope so, still have so much to work on and so little time)
        $display("Test completato.");
        $finish;
    end

endmodule