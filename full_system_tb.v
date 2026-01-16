`timescale 1ns / 1ps

module full_system_tb;

    reg clk;
    reg rst;
    reg signed [7:0] energy;
    reg signed [7:0] isol;
    wire trigger;

    // Instantiating the Beast (The entire chip)
    nano_trigger uut (
        .clk(clk), .rst(rst),
        .energy(energy), .isol(isol),
        .trigger(trigger)
    );

    // The heartbeat. 100MHz of pure anxiety.
    always #5 clk = ~clk;

    initial begin
        // Black box recording. If it crashes, we'll know why.
        $dumpfile("full_trigger.vcd");
        $dumpvars(0, full_system_tb);

        // Factory reset. Wiping its memory before we start interrogation.
        clk = 0; rst = 1; energy = 0; isol = 0;
        #20 rst = 0;

        // --- CASE 1: NOISE (The Boring Stuff) ---
        // Low energy, low isolation. Basically just the universe humming.
        // Expectation: Trigger stays low (0).
        energy = 15; 
        isol = 10;
        #40; // Waiting for the neurons to hold a meeting and vote.

        // --- CASE 2: THE JACKPOT (Higgs?) ---
        // High energy, super clean. 
        // Expectation: Trigger goes HIGH (1). Call Stockholm.
        energy = 110; 
        isol = 90;
        #40;
        
        // --- CASE 3: THE TWILIGHT ZONE ---
        // Mediocre energy, mediocre isolation. 
        // Will it pass? Will it fail? The suspense is terrible.
        energy = 60;
        isol = 40;
        #40;

        $finish; // simulation.kill();
    end
endmodule