module controlLogic (
input A0,
input rden,
input ICW1flag,
input ICW2flag,
input ICW3flag,
input ICW4flag,
input OCW1flag,
input OCW2flag,
input OCW3flag,
input [7:0] DBus,
output reg LTIM,
output reg SNGL,
output reg IC4,
output reg [4:0] TReg,
output reg [7:0] SReg,
output reg SFNM,
output reg BUF,
output reg MS,
output reg AEOI,
output reg [7:0] MReg,
output reg R,
output reg SL,
output reg EOI,
output reg readIRR,
output reg readISR,
output reg readIMR
);


	reg P, RR, RIS;


	always @(ICW1flag, ICW2flag, ICW3flag, ICW4flag, OCW1flag, OCW2flag, OCW3flag) begin

		if(ICW1flag) begin
				LTIM <= DBus[3];
				SNGL <= DBus[1];
				IC4 <= DBus[0];
			end

			else if(ICW2flag) begin
				TReg <= DBus[7:3];
				if (IC4 == 0) begin
					SFNM <= 1'b0;
					AEOI <= 1'b0;
				end
			end

			else if(ICW3flag)
				SReg <= DBus[7:0];

			else if(ICW4flag) begin
				SFNM <= DBus[4];
				BUF <= DBus[3];
				MS <= DBus[2];
				AEOI <= DBus[1];
			end

			else if(OCW1flag)
				MReg <= DBus[7:0];

			else if(OCW2flag) begin
				R <= DBus[7];
				SL <= DBus[6];
				EOI <= DBus[5];
			end

			else if(OCW3flag) begin
				P <= DBus[2];
				RR <= DBus[1];
				RIS <= DBus[0];
			end

	end

	always @(rden, A0) begin

		readIRR <= ((~P) && RR && (~RIS) && rden && (~A0));
		readISR <= ((~P) && RR && RIS && rden && (~A0));
		readIMR <= (A0 && rden);

	end


endmodule



module controlLogicTB ();


	reg ICW1flag, ICW2flag, ICW3flag, ICW4flag, OCW1flag, OCW2flag, OCW3flag;
	reg rden, A0;
	reg [7:0] DBus;
	reg [2:0] interruptLocation;

	wire LTIM, SNGL, IC4, SFNM, BUF, MS, AEOI, R, SL, EOI, readIRR, readISR, readIMR;
	wire [7:3] TReg;
	wire [7:0] SReg;
	wire [7:0] MReg;


	initial begin


		// Testing ICW1
		A0 = 1'b0;
		rden = 1'b0;
		DBus = 8'b00011101;
		ICW1flag = 1'b1;
		#50; //0->50

		// Testing ICW2
		A0 = 1'b1;
		DBus = 8'b11001010;
		ICW1flag = 1'b0;
		ICW2flag = 1'b1;
		interruptLocation = 3'b101;
		#50; //50->100

		// Testing ICW3
		DBus = 8'b00011110;
		ICW2flag = 1'b0;
		ICW3flag = 1'b1;
		#50; //100->150

		// Testing ICW4
		DBus = 8'b00010010;
		ICW3flag = 1'b0;
		ICW4flag = 1'b1;
		#50; //150->200

		// Testing OCW1
		DBus = 8'b01101010;
		ICW4flag = 1'b0;
		OCW1flag = 1'b1;
		#50; //200->250

		// Testing OCW2
		A0 = 1'b0;
		DBus = 8'b11000100;
		OCW1flag = 1'b0;
		OCW2flag = 1'b1;
		#50; //250->300

		// Testing OCW3
		DBus = 8'b00001011;
		OCW2flag = 1'b0;
		OCW3flag = 1'b1;
		#50; //300->350

		// Reading ISR (P=0, RR=1, RIS=1)
		OCW3flag = 1'b0;
		rden = 1'b1;
		#50; //350->400

		// Writing another OCW3
		rden = 1'b0;
		DBus = 8'b00001010;
		OCW3flag = 1'b1;
		#50; //400->450

		// Reading IRR (P=0, RR=1, RIS=0)
		OCW3flag = 1'b0;
		rden = 1'b1;
		#50; //450->500

		// Reading IMR
		A0 = 1'b1;
		#50; //500->550

		// Stop Reading
		rden = 1'b0;
		#50; //550->600

		// Reading IRR again (Remembering the last OCW3)
		rden = 1'b1;
		A0 = 1'b0;
		#50; //600->650


	end

	controlLogic CLInstance (
	A0,
	rden,
	ICW1flag,
	ICW2flag,
	ICW3flag,
	ICW4flag,
	OCW1flag,
	OCW2flag,
	OCW3flag,
	DBus,
	interruptLocation,
	LTIM,
	SNGL,
	IC4,
	TReg,
	SReg,
	SFNM,
	BUF,
	MS,
	AEOI,
	MReg,
	R,
	SL,
	EOI,
	readIRR,
	readISR,
	readIMR
	);


endmodule
