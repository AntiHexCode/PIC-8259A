module InterruptLogicDUT(

input [7:0] IRBus, // IR7-IR0 Bus
input LTIM, // Level Triggered Interrupt Mode

input SFNM, // Special Fully Nested Mode
input AR, // Automatic Rotation Mode
input AEOI, // Automatic End Of Interrupt

input [4:0] TReg, // used for getting interrupt vector address
input [7:0] IMR, // Interrupt Mask Register

input readIRR, // Read Status flag (IRR)
input readISR, // Read Status flag (ISR)

input INTA, // Interrupt Acknowledge (Active low)


output reg INT, // Interrupt
output reg [7:0] internalBus,
output reg [2:0] interruptLocation,
output reg [7:0] IRR

);


// Internal
reg [7:0] checkedIRR = 8'b00000000; // Interrupt Request Register
reg [7:0] ISR = 8'b00000000; // In-Service Register
//reg [7:0] IRR;
//reg [2:0] interruptLocation; // Location of the interrupt in bits on IRBus (000->111)
reg i;
reg counter = 1'b0;


always @(posedge IRBus[0], posedge IRBus[1], posedge IRBus[2], posedge IRBus[3], posedge IRBus[4], posedge IRBus[5], posedge IRBus[6], posedge IRBus[7]) begin
	
	IRR = IRBus;

	// Checking the ISR and IMR registers
	checkedIRR = IRR & (~IMR) & (~ISR);

	// Getting the highest priority bit depending on the mode
	if ((~SFNM) && (counter == 0)) begin

		INT = 0; // inactive

		if(checkedIRR[0] == 1) begin
			i = 0; // set ISR bit
			interruptLocation = 000;
		end
		else if (checkedIRR[1] == 1) begin
			i = 1;
			interruptLocation = 001;
		end
		else if (checkedIRR[2] == 1) begin
			i = 2;
			interruptLocation = 010;
		end
		else if (checkedIRR[3] == 1) begin
			i = 3;
			interruptLocation = 011;
		end
		else if (checkedIRR[4] == 1) begin
			i = 4;
			interruptLocation = 100;
		end
		else if (checkedIRR[5] == 1) begin
			i = 5;
			interruptLocation = 101;
		end
		else if (checkedIRR[6] == 1) begin
			i = 6;
			interruptLocation = 110;
		end
		else if (checkedIRR[7] == 1) begin
			i = 7;
			interruptLocation = 111;
		end

		INT = 1;

	end

end



always@(negedge INTA) begin
	
	if((counter == 0) && (INT == 1)) begin
		INT = 0;
		IRR[i] = 0;
		ISR[i] = 1;
		counter = counter + 1;
	end

	else if ((counter == 1) && (INT == 0)) begin
		internalBus = {TReg, interruptLocation};
		counter = 0;
		if (AEOI)
			ISR[i] = 0;
	end

end



always @(posedge readIRR, posedge readISR) begin

	if(readIRR)
		internalBus = IRR;

	else if(readISR)
		internalBus = ISR;

end



endmodule








module InterruptLogicTB();

	reg [7:0] IRBus; // IR7-IR0 Bus
	reg LTIM; // Level Triggered Interrupt Mode
	reg SFNM; // Special Fully Nested Mode
	reg AR; // Automatic Rotation Mode
	reg AEOI; // Automatic End Of Interrupt
	reg [4:0] TReg;
	reg [7:0] IMR; // Interrupt Mask Register
	reg readIRR; // Read Status flag (IRR)
	reg readISR; // Read Status flag (ISR)
	reg INTA; // Interrupt Acknowledge (Active low)
	wire INT; // Interrupt
	wire [7:0] IRR;
	wire [7:0] internalBus;

	wire [2:0] interruptLocation;
 


	initial begin

		IRBus = 8'b00000000;
		INTA = 1'b1;
		#100;

		SFNM = 1'b0;
		AR = 1'b0;
		AEOI =1'b1;
		TReg = 5'b01110;
		IMR = 8'b00001111;
		IRBus = 8'b01100100;
		#100;

		INTA = 1'b0;
		#50;
		INTA = 1'b1;
		#50

		INTA = 1'b0;
		#50;
		INTA = 1'b1;
		#100

		IMR = 8'b00000000;
		IRBus = 8'b10000000;
		#100;

		IMR = 8'b11001100;
		IRBus = 8'b10000010;
		#100;

		INTA = 1'b0;
		#50;
		INTA = 1'b1;
		#50

		INTA = 1'b0;
		#50;
		INTA = 1'b1;
		#00

		readIRR = 1;
		#100;

		readIRR = 0;
		readISR = 1;
		#100;


	end

InterruptLogicDUT ILInstance(

IRBus, // IR7-IR0 Bus
LTIM, // Level Triggered Interrupt Mode

SFNM, // Special Fully Nested Mode
AR, // Automatic Rotation Mode
AEOI, // Automatic End Of Interrupt

TReg,
IMR, // Interrupt Mask Register

readIRR, // Read Status flag (IRR)
readISR, // Read Status flag (ISR)

INTA, // Interrupt Acknowledge (Active low)


INT, // Interrupt
internalBus,
interruptLocation,
IRR

);

endmodule