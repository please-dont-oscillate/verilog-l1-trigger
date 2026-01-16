module rom_weights (
    input clk,
    input [7:0] addr,       
    output reg signed [7:0] data 
);

    // Budget cuts applied: Downsized to just 9 slots (0 to 8).
    // If your Python script changes its mind, this hardcoded value will haunt your dreams.
    reg signed [7:0] memory [0:8];

    initial begin
        // Loading the 'lite' version of the weights.
        $readmemh("weights_L1.hex", memory);
    end

    always @(posedge clk) begin
        // Serving up data (or undefined ghosts if you access index > 8).
        data <= memory[addr];
    end

endmodule