module IRR (
    input reset,
    input LTIM, // For determining whether it will be edge or level triggered
    input [7:0] ir, // Vectorized input for interrupt signals
    output reg [7:0] irr,
    output reg interrupt
);
    reg [7:0] cur_irr;

    always @(posedge reset or posedge ir) begin
        if (reset) begin
            irr <= 8'b00000000; // Reset the interrupt request signals
        end
        else begin
            if (LTIM) begin
                cur_irr <= ir; // Update cur_irr based on LTIM condition
            end
            else begin
                if (ir & ~cur_irr) begin
                    // If there is a new interrupt (edge-triggered), update cur_irr
                    cur_irr <= ir;
                end
            end
        end
    end

    always @* begin
        if (!LTIM) begin
            // If edge-triggered, update the irr register with cur_irr
            irr = cur_irr;
        end
        else begin
            // If level-triggered, update the irr register with ir
            irr = ir;
        end
        interrupt = (|ir) ? 1'b1 : 1'b0; // Set interrupt to 1 if any bit contains 1
    end
endmodule


module test_IRR;

    // Inputs
    reg reset;
    reg LTIM;
    reg [7:0] ir;

    // Outputs
    wire [7:0] irr;
    wire interrupt;

    // Instantiate the IRR module
    IRR dut (
        .reset(reset),
        .LTIM(LTIM),
        .ir(ir),
        .irr(irr),
        .interrupt(interrupt)
    );

    // Test bench stimulus
    initial begin
        // Reset
        #20 reset = 1;
        LTIM = 0;
        ir = 8'b00000000;
        #10;
        reset = 0;

        // Test case 1: Level-triggered interrupt
        LTIM = 1;
        ir = 8'b01010101; // Set different interrupt signals
        ir = 8'b01010111;
        #10;

        // Test case 2: Edge-triggered interrupt
        LTIM = 1;
        ir = 8'b10101010; // Set different interrupt signals
        ir = 8'b11101010;
        #10;

        // Test case 3: Level-triggered interrupt with all interrupts active
        LTIM = 1;
        ir = 8'b11111111; // Set all interrupt signals
        #10;

        // Test case 4: Edge-triggered interrupt with no interrupts active
        LTIM = 0;
        ir = 8'b10000000; // Set no interrupt signals
        #10;

        // Test case 5: Level-triggered interrupt with some interrupts active
        LTIM = 1;
        ir = 8'b11001100; // Set some interrupt signals
        #10;

        // Test case 6: Edge-triggered interrupt with alternating interrupts
        LTIM = 0;
        ir = 8'b10101010; // Set alternating interrupt signals
        #10;

        // Add more test cases as needed

    end

endmodule

