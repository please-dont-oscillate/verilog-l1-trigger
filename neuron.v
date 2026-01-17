`timescale 1ns / 1ps

module neuron (
    input clk,                      // The heartbeat
    input rst,                      // The "Men in Black" memory eraser
    input signed [7:0] x1,          // Input 1
    input signed [7:0] x2,          // Input 2
    input signed [7:0] w1,          // Weight 1 (How much we care about Input 1)
    input signed [7:0] w2,          // Weight 2 (How much we care about Input 2)
    input signed [7:0] b,           // Bias (The neuron's predisposition to complain)
    output reg signed [15:0] y      // The Output
);

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
            // STEP 1: The Multiplication
            // This is where numbers get big. Fast.
            mult1 <= x1 * w1;
            mult2 <= x2 * w2;

            // STEP 2: Summation with NORMALIZATION (The "Math Savior")
            // Since we multiplied scaled numbers by scaled numbers, the result is huge.
            // We divide by 128 (shift right >>> 7) to bring it back to earth.
            // Without this, our neural network is just a random number generator.
            sum_raw <= (mult1 >>> 7) + (mult2 >>> 7) + b; 

            // STEP 3: ReLU Activation (The "No Negativity" Policy)
            // If the result is negative, we pretend it never happened (0).
            // If positive, we keep it. Simple psychology.
            if (sum_raw < 0) 
                y <= 0;
            else 
                y <= sum_raw;
        end
    end

endmodule