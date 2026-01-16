`timescale 1ns / 1ps

module layer_2 (
    input signed [15:0] n1,     // The hot take from Neuron 1
    input signed [15:0] n2,     // The dissenting opinion from Neuron 2
    input signed [15:0] n3,     // The tie-breaker from Neuron 3
    output reg trigger,         // 1 = CALL STOCKHOLM (Success), 0 = /dev/null (Trash)
    output reg signed [31:0] score // The raw score (kept for debugging my math anxiety)
);

    // --- LAYER 2 WEIGHTS (The Final Bosses) ---
    // Change these values if you want to alter reality.
    wire signed [7:0] w1 = 127;  // How much we trust Neuron 1
    wire signed [7:0] w2 = 128; // Neuron 2 is chil
    wire signed [7:0] w3 = 128; 
    wire signed [7:0] b  = 232;  // The pessimistic bias (guilty until proven innocent)

    always @(*) begin
        // The Grand Calculation: Weighted sum of the previous layer's hard work.
        // We use 32 bits because overflow is for amateurs.
        score = (n1 * w1) + (n2 * w2) + (n3 * w3) + b;

        // --- THE VERDICT (Thresholding) ---
        // If the score is positive, we found something cool.
        // If negative, it's just cosmic background static.
        if (score > 0) 
            trigger = 1'b1; // WE FOUND THE HIGGS! (Or a glitch).
        else 
            trigger = 1'b0; // Nothing to see here. Move along.
    end

endmodule