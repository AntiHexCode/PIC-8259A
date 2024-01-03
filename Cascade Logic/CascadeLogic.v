module CascadeLogic(

input SPEN,
input [7:0] SReg,
input decInterruptLocation,
input [2:0] interruptLocation,
inout [2:0] CASBus,
output wire sPermissionToWrite,
output wire mPermissionToWrite

);

	
	assign mPermissionToWrite = ((SReg[decInterruptLocation] == 1) &&	(SPEN == 1))? 0 : 1;
	assign CASBus = ((SReg[decInterruptLocation] == 1) && (SPEN == 1))? interruptLocation : 3'bzzz;
	assign sPermissionToWrite = ((CASBus == SReg[2:0]) && (SPEN == 0))? 1 : 0;


endmodule



module CascadeLogicTB();

reg SPEN;
reg [7:0] SReg;
reg decInterruptLocation;
reg [2:0] interruptLocation;
wire [2:0] CASBus;
wire spermissionToWrite;
wire mPermissionToWrite;

initial begin

	SPEN = 1'b1;
	SReg = 8'b00111010;
	decInterruptLocation = 2;
	interruptLocation = 3'b010;
	#10;

	decInterruptLocation = 5;
	interruptLocation = 3'b101;
	#10;

	decInterruptLocation = 7;
	interruptLocation = 3'b111;
	#10;

	SReg = 8'b01101011;
	decInterruptLocation = 6;
	interruptLocation = 3'b110;
	#10;

	decInterruptLocation = 2;
	interruptLocation = 3'b010;
	#10;

	SPEN = 0;
	#10;


	end


CascadeLogic CLInstance(

	.SPEN(SPEN),
	.SReg(SReg),
	.decInterruptLocation(decInterruptLocation),
	.interruptLocation(interruptLocation),
	.CASBus(CASBus),
	.sPermissionToWrite(sPermissionToWrite),
	.mPermissionToWrite(mPermissionToWrite)
);


endmodule

