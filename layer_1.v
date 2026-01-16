`timescale 1ns / 1ps

module layer_1 (
    input clk,
    input rst,
    input signed [7:0] input_energy,  // Input X1: The raw fuel.
    input signed [7:0] input_isol,    // Input X2: The noise... or is it signal?
    output signed [15:0] n1_out,      // Neuron 1 Result: The optimist.
    output signed [15:0] n2_out,      // Neuron 2 Result: The realist.
    output signed [15:0] n3_out       // Neuron 3 Result: The wild card.
);

    // --- HARDCODED WEIGHTS (Etched into the silicon soul) ---
    // Note: We use 8'd... because Verilog treats bits like raw data.
    // The "signed" keyword below does the heavy lifting for the math.

    // NEURON 1 (Values ripped from your screenshot)
    // addr 0 -> 127 (Max positive. Living life on the edge.)
    // addr 1 -> 223 (This is actually -33. It's having an identity crisis.)
    // addr 2 -> 128 (This becomes -128. The most negative bias possible. Grumpy.)
    wire signed [7:0] w1_1 = 8'd127; 
    wire signed [7:0] w1_2 = 8'd223;
    wire signed [7:0] b1   = 8'd128;

    // NEURON 2 (Realistic examples, or so we hope)
    wire signed [7:0] w2_1 = 8'd45;
    wire signed [7:0] w2_2 = -8'd12;
    wire signed [7:0] b2   = 8'd10;

    // NEURON 3 (More realistic examples)
    wire signed [7:0] w3_1 = -8'd20;
    wire signed [7:0] w3_2 = 8'd60;
    wire signed [7:0] b3   = 8'd5;

    // --- THE ENGINE: Three neurons in a trench coat pretending to be a brain ---
    
    // Instance 1
    neuron N1 (
        .clk(clk), .rst(rst),
        .x1(input_energy), .x2(input_isol),
        .w1(w1_1), .w2(w1_2), .b(b1),
        .y(n1_out)
    );

    // Instance 2
    neuron N2 (
        .clk(clk), .rst(rst),
        .x1(input_energy), .x2(input_isol),
        .w1(w2_1), .w2(w2_2), .b(b2),
        .y(n2_out)
    );

    // Instance 3
    neuron N3 (
        .clk(clk), .rst(rst),
        .x1(input_energy), .x2(input_isol),
        .w1(w3_1), .w2(w3_2), .b(b3),
        .y(n3_out)
    );

endmodule