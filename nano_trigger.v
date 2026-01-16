`timescale 1ns / 1ps

module nano_trigger (
    input clk,
    input rst,
    input signed [7:0] energy,    // Input from Calorimeter: How spicy is this particle?
    input signed [7:0] isol,      // Input from Muon Sensor: Social distancing score.
    output trigger                // The "Big Red Button": 1 = Nobel Prize, 0 = Trash.
);

    // Internal spaghetti wires connecting Layer 1 to Layer 2 (The Synapses)
    wire signed [15:0] l1_n1;
    wire signed [15:0] l1_n2;
    wire signed [15:0] l1_n3;
    
    // Debug wire: Because we don't trust our own math yet.
    wire signed [31:0] final_score;

    // --- INSTANTIATING LAYER 1 (The Grunt Work) ---
    // This layer does the heavy lifting, crunching raw numbers.
    layer_1 L1 (
        .clk(clk),
        .rst(rst),
        .input_energy(energy),
        .input_isol(isol),
        .n1_out(l1_n1),
        .n2_out(l1_n2),
        .n3_out(l1_n3)
    );

    // --- INSTANTIATING LAYER 2 (Upper Management) ---
    // Takes the credit for Layer 1's work and makes the final decision.
    layer_2 L2 (
        .n1(l1_n1),
        .n2(l1_n2),
        .n3(l1_n3),
        .trigger(trigger),
        .score(final_score)
    );

endmodule