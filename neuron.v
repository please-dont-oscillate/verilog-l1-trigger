`timescale 1ns / 1ps

module neuron (
    input clk,                  // The heart of the system: synchronize everything
    input rst,                  // Reset: Bring everything to zero
    input signed [7:0] x1,      // Input 1 (signed, 8-bit)
    input signed [7:0] x2,      // Input 2
    input signed [7:0] w1,      // weight for Input 1
    input signed [7:0] w2,      // weight for Input 2
    input signed [7:0] b,       // Bias (the basic threshold)
    output reg signed [15:0] y  // Output (16 bits to hold the BIG result)
);

    // Internal variables (wires) for intermediate calculations
    // They must be big enough!
    reg signed [15:0] mult1;
    reg signed [15:0] mult2;
    reg signed [15:0] sum_raw;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y <= 0;
            mult1 <= 0;
            mult2 <= 0;
            sum_raw <= 0;
        end else begin
            // STEP 1: Multiplication (Fixed Point)
            // Python: x * w
            mult1 <= x1 * w1;
            mult2 <= x2 * w2;

            // STEP 2: Sum (Accumulate)
            // Python: (x1*w1) + (x2*w2) + bias
            // Note: Bias (8-bit) is automatically extended
            sum_raw <= mult1 + mult2 + b; 

            // STEP 3: ReLU Activation (The "AI" Part)
            // If the sum is negative, the output is 0. Otherwise it is the sum.
            if (sum_raw < 0) 
                y <= 0;
            else 
                y <= sum_raw;
        end
    end

endmodule