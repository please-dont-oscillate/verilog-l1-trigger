`timescale 1ns / 1ps

module rom_tb;
    reg clk;
    reg [7:0] addr;
    wire signed [7:0] data;

    // Summoning the UUT (Unit Under Torture)
    rom_weights uut (
        .clk(clk),
        .addr(addr),
        .data(data)
    );

    // Oscillating like a caffeinated nervous system
    always #5 clk = ~clk;

    initial begin
        $dumpfile("rom_test.vcd");
        $dumpvars(0, rom_tb);

        clk = 0;
        addr = 0;
        
        // Poking the memory addresses to see who's home
        #10 addr = 0; // The Genesis byte. Start here.
        #10 addr = 1; // Array index 1: The lonely number.
        #10 addr = 2; // Third time's the charm?
        #10 addr = 3; // 11 in binary, but who's counting?
        
        #20 $finish;
    end
endmodule