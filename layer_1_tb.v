`timescale 1ns / 1ps

module layer_1_tb;

    reg clk;
    reg rst;
    reg signed [7:0] in_energy;
    reg signed [7:0] in_isol;
    
    wire signed [15:0] out1;
    wire signed [15:0] out2;
    wire signed [15:0] out3;

    // Summoning the Neural Layer (The 'Unit Under Torture')
    layer_1 uut (
        .clk(clk),
        .rst(rst),
        .input_energy(in_energy),
        .input_isol(in_isol),
        .n1_out(out1),
        .n2_out(out2),
        .n3_out(out3)
    );

    // The pacemaker: Toggling every 5ns to keep the silicon heart beating
    always #5 clk = ~clk;

    initial begin
        // Paparazzi mode: Recording every scandalous signal change for the VCD viewer
        $dumpfile("layer1_test.vcd");
        $dumpvars(0, layer_1_tb);

        // Factory settings: Reset is ON, energy is ZERO. Boredom ensues.
        clk = 0;
        rst = 1;
        in_energy = 0;
        in_isol = 0;

        #20 rst = 0; // Release the Kraken! (Turning off reset)

        // --- TEST CASE 1: The "Nothing Burger" ---
        // Low energy, low isolation. Basically just cosmic background radiation.
        // We expect the neurons to sleep through this.
        in_energy = 10;
        in_isol = 5;
        #20;

        // --- TEST CASE 2: The "Nobel Prize Candidate" ---
        // High Energy. High Isolation. 
        // If the neurons don't scream at this input, check your math.
        in_energy = 100;
        in_isol = 100;
        #20;

        $finish; // Game Over. Insert coin to continue.
    end

endmodule