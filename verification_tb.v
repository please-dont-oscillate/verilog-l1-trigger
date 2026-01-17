`timescale 1ns / 1ps

module verification_tb;

    reg clk;
    reg rst;
    reg signed [7:0] energy;
    reg signed [7:0] isol;
    wire trigger;
    
    // BACKDOOR ACCESS: Spying on the internal thoughts of the chip
    // We are cheating by looking at "score" inside layer_2 without a license.
    wire signed [31:0] debug_score = uut.L2.score; 

    integer file, status;
    integer input_eng, input_iso, label_exp; 
    integer correct = 0;
    integer total = 0;
    integer false_positives = 0;
    integer false_negatives = 0;
    
    // Mercy flag: Only print the first failure to save your dignity
    // (Prevents the console from exploding with error messages)
    integer error_printed = 0; 

    nano_trigger uut (
        .clk(clk), .rst(rst),
        .energy(energy), .isol(isol),
        .trigger(trigger)
    );

    always #5 clk = ~clk;

    initial begin
        file = $fopen("validation_data.hex", "r");
        if (file == 0) begin
            $display("FATAL ERROR: validation_data.hex missing! Did you forget to run 'python master_config.py'?");
            $finish;
        end

        clk = 0; rst = 1; energy = 0; isol = 0;
        #20 rst = 0;

        $display("Starting the Inquisition (Test Run)...");

        while (!$feof(file)) begin
            status = $fscanf(file, "%h %h %d\n", input_eng, input_iso, label_exp);
            
            if (status == 3) begin
                energy = input_eng[7:0];
                isol = input_iso[7:0];

                #20; // Coffee break. Letting the electrons race through the silicon.

                if (trigger == label_exp) begin
                    correct = correct + 1;
                end else begin
                    // FAILURE AUTOPSY
                    if (trigger == 1 && label_exp == 0) false_positives = false_positives + 1;
                    else false_negatives = false_negatives + 1;

                    // PUBLIC SHAMING: Only showing the first error to avoid scrolling for eternity.
                    if (error_printed == 0) begin
                        $display("\n--- FIRST FAILURE DETECTED (The Shame) ---");
                        $display("Input: Energy=%d, Isol=%d", energy, isol);
                        $display("Expected: %b, Got: %b", label_exp, trigger);
                        $display("Internal Score (Needs >0 to trigger): %d", debug_score);
                        $display("------------------------------------------\n");
                        error_printed = 1;
                    end
                end
                total = total + 1;
            end
        end

        // FINAL SCOREBOARD
        $display("HARDWARE ACCURACY: %0d.%0d %%", (correct * 100) / total, ((correct * 1000) / total) % 10);
        $display("False Alarms (Paranoia): %d", false_positives);
        $display("Missed Events (Blindness): %d", false_negatives);
        $fclose(file);
        $finish;
    end
endmodule