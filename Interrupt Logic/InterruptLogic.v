module InterruptLogic(

input [7:0] IRBus,                    // IR7-IR0 Bus
input LTIM,                           // Level Triggered Interrupt Mode
input SFNM,                           // Special Fully Nested Mode
input AR,                             // Automatic Rotation Mode
input AEOI,                           // Automatic End Of Interrupt
input [4:0] TReg,                     // used for getting interrupt vector address
input [7:0] IMR,                      // Interrupt Mask Register
input readIRR,                        // Read Status flag (IRR)
input readISR,                        // Read Status flag (ISR)
input readIMR,                        // Read Status flag (IMR)
input INTA,                           // Interrupt Acknowledge (Active low)
output reg INT,                       // Interrupt the CPU
output reg [7:0] internalBus,         // inside the PIC
output reg decInterruptLocation,      // Location of the interrupt in decimal on IRBus (0->7)
output reg [2:0] interruptLocation    // Location of the interrupt in bits on IRBus (000->111)

);



	// Internal (inside the module)
	reg [7:0] IRR;                        // Interrupt Request Register
	reg [7:0] checkedIRR = 8'b00000000;   // Interrupt Request Register after checking ISR and IMR
	reg [7:0] ISR = 8'b00000000;          // In-Service Register         
	reg counter = 1'b0;                   // To count the two INTA pulses



	always @(posedge IRBus[0], posedge IRBus[1], posedge IRBus[2], posedge IRBus[3],
	  posedge IRBus[4], posedge IRBus[5], posedge IRBus[6], posedge IRBus[7]) begin
		
		
		IRR = IRBus;

		// Checking the ISR and IMR registers
		checkedIRR = IRR & (~IMR) & (~ISR);

		// Getting the highest priority bit depending on the mode
		if ((~SFNM) && (counter == 0)) begin

			INT = 1'b0;

			if(checkedIRR[0] == 1) begin
				decInterruptLocation = 0;
				interruptLocation = 3'b000;
			end
			else if (checkedIRR[1] == 1) begin
				decInterruptLocation = 1;
				interruptLocation = 3'b001;
			end
			else if (checkedIRR[2] == 1) begin
				decInterruptLocation = 2;
				interruptLocation = 3'b010;
			end
			else if (checkedIRR[3] == 1) begin
				decInterruptLocation = 3;
				interruptLocation = 3'b011;
			end
			else if (checkedIRR[4] == 1) begin
				decInterruptLocation = 4;
				interruptLocation = 3'b100;
			end
			else if (checkedIRR[5] == 1) begin
				decInterruptLocation = 5;
				interruptLocation = 3'b101;
			end
			else if (checkedIRR[6] == 1) begin
				decInterruptLocation = 6;
				interruptLocation = 3'b110;
			end
			else if (checkedIRR[7] == 1) begin
				decInterruptLocation = 7;
				interruptLocation = 3'b111;
			end

			INT = 1'b1;

		end

	end



	// Receiving the INTA pulses
	always@(negedge INTA) begin
		
		if((counter == 0) && (INT == 1)) begin
			INT <= 1'b0;
			IRR[decInterruptLocation] <= 1'b0;
			ISR[decInterruptLocation] <= 1'b1;
			counter <= counter + 1;
		end

		else if ((counter == 1) && (INT == 0)) begin
			internalBus <= {TReg, interruptLocation};
			counter <= 1'b0;
			if (AEOI)
				ISR[decInterruptLocation] = 1'b0;
		end

	end



	// Read Status
	always @(posedge readIRR, posedge readISR, posedge readIMR) begin

		if(readIRR)
			internalBus = IRR;

		else if(readISR)
			internalBus = ISR;

		else if(readIMR)
			internalBus = IMR;

	end



endmodule
