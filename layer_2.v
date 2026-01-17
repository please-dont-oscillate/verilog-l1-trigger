`timescale 1ns / 1ps

module layer_2 (
    input signed [15:0] n1,     // Input from Neuron 1
    input signed [15:0] n2,     // Input from Neuron 2
    input signed [15:0] n3,     // Input from Neuron 3
    output reg trigger,         // The Verdict: 1 = DISCOVERY, 0 = NOISE
    output reg signed [31:0] score // The raw confidence score
);

    // --- DOWNLOADING THE BRAIN ---
    // Importing the Python-generated weights. 
    `include "weights.vh"

    // --- ASSIGNING THE AGENTS ---
    wire signed [7:0] w1 = L2_W1;
    wire signed [7:0] w2 = L2_W2;
    wire signed [7:0] w3 = L2_W3;
    wire signed [7:0] b  = L2_B;

    always @(*) begin
        // --- THE GRAND FINALE (With Normalization) ---
        // Just like inside the neurons, multiplying two scaled numbers creates a monster.
        // We shift right by 7 (divide by 128) to tame the beast before adding the bias.
        score = ((n1 * w1) >>> 7) + ((n2 * w2) >>> 7) + ((n3 * w3) >>> 7) + b;

        // --- THE DECISION ---
        // The moment of truth. 
        // If score > 0, pop the champagne (Higgs found).
        // If score <= 0, back to the drawing board (Noise).
        if (score > 0) 
            trigger = 1'b1;
        else 
            trigger = 1'b0;
    end

endmodule