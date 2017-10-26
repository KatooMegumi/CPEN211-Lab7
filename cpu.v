module cpu(clk,reset,s,load,in,out,N,V,Z,w);

  input clk, reset, s, load; //load_ir
  input [15:0] in; //read_data and mdata 

  output [15:0] out; //datapath_out
  output [1:0] mem_cmd;
  output [8:0] mem_addr;
  output N, V, Z, w; //?
  output [7:0] PC; //?

//lab 6 cpu wires
  wire [15:0] instruction_out;
  wire loada,loadb,loads,loadc,write,asel,bsel;
  wire [2:0] status;
  wire [1:0] op, ALUop, shift, vsel;
  wire [2:0] opcode, readnum, writenum, nsel;  
  wire [15:0] sximm5, sximm8; 

//added wires for lab 7
  //wires out from state machine
  wire addr_sel; 
  wire load_pc; 
  wire reset_pc; 

  //top MUX output wire
  wire [8:0] next_pc

  //output wire for program counter
  wire [8:0] output_program_counter; 

  //instruction register
  vDFFE #(16) instruct_reg(clk, load , in, instruction_out); 
 
  instruct_decoder decoder(   .instruction_out(instruction_out),
			        .nsel(nsel),
				.opcode(opcode),
				.op(op),
				.ALUop(ALUop),
				.sximm5(sximm5),
				.sximm8(sximm8),
				.shift(shift),
				.readnum(readnum),
				.writenum(writenum)
  );

  FSM state_machine(    .clk(clk),
			.reset(reset),
			.s(s),
			.w(w),
			.opcode(opcode),
			.op(op),
			.nsel(nsel),
			.loada(loada),
			.loadb(loadb),
			.loadc(loadc),
			.loads(loads),
			.vsel(vsel),
			.write(write),
			.asel(asel),
			.bsel(bsel)
  );

  datapath DP(          .clk(clk),
			.readnum(readnum),
			.writenum(writenum),
			.write(write),
			.vsel(vsel),
			.loada(loada),
			.loadb(loadb),
			.loadc(loadc),
			.loads(loads),
			.shift(shift),
			.ALUop(ALUop),
			.asel(asel),
			.bsel(bsel),
			.mdata(mdata),
			.status(status),
			.C(out),
			.sximm8(sximm8),
			.sximm5(sximm5),
			.PC(PC)
  );	

  vDFFE #(9) Program_counter(clk,load_pc,next_pc,output_program_counter);

  // for MUX above program counter
  assign next_pc = reset_pc ? 9'b0 : (output_program_counter+1'b1);
 
  //Lower MUX
  assign mem_addr = addr_sel ? output_program_counter : 9'b0;

  //Now assign N,V,Z the values from status we get from datapath 
  assign N = status[0];
  assign V = status[1]; 
  assign Z = status[2];  
  
endmodule

module instruct_decoder( instruction_out, 
			 nsel, 
			 opcode,
			 op,
			 ALUop, 
			 sximm5, 
			 sximm8, 
			 shift,
			 readnum,
			 writenum );

  input [15:0] instruction_out;
  input [2:0] nsel;
  output [2:0] opcode;
  output reg [2:0] readnum, writenum;
  output [1:0] shift, ALUop, op;
  output [15:0] sximm5, sximm8;
  wire [2:0] Rn, Rd, Rm;
  wire [4:0] imm5;
  wire [7:0] imm8;

  setval retval(instruction_out,opcode,op,ALUop,imm5,imm8,shift,Rn,Rd,Rm);
  //signed extended imm5 and imm8
  assign sximm5 = imm5[4] ? {11'b11111111111,imm5}:{11'b00000000000,imm5}; 
  assign sximm8 = imm8[7] ? {8'b11111111,imm8}:{8'b00000000,imm8};
  always @(*) 
    case(nsel)
      3'b001: {readnum,writenum} = {Rn,Rn}; //set the register to Rn if nsel = 0
      3'b010: {readnum,writenum} = {Rd,Rd}; //set register to Rd if nsel = 1
      3'b100: {readnum,writenum} = {Rm,Rm}; //set register to Rm if nsel = 2
      default: {readnum,writenum} = 6'bx; //set the registers to x 
    endcase
endmodule

module setval(instruction_out,opcode,op,ALUop,imm5,imm8,shift,Rn,Rd,Rm);
  input [15:0] instruction_out;
  output reg [2:0] opcode,Rn,Rd,Rm;
  output reg [1:0] op, ALUop, shift;
  output reg [4:0] imm5;
  output reg [7:0] imm8;

  always @(*) begin 
    casex(instruction_out)
	//set all outputs that are not used to 0
	{5'b11010,11'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b10,2'b0,instruction_out[10:8],instruction_out[7:0],
						5'b0,3'b0,2'b0,3'b0};//Move value to register (MOV Rn, #<im8>)
	{8'b11000000,8'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b0,2'b0,3'b0,8'b0,5'b0, instruction_out[7:5],
						instruction_out[4:3],instruction_out[2:0]};//Shift a known value and store in a new register (Rn =sh_Rm)
	{5'b10100,11'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b0,2'b0,instruction_out[10:8],
						8'b0,5'b0,instruction_out[7:5],instruction_out[4:3],instruction_out[2:0]};//Add (ADD Rd = Rn + Rm)
	{5'b10101,11'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b01,2'b01,instruction_out[10:8],
						8'b0,5'b0,3'b0, instruction_out[4:3], instruction_out[2:0]};//Subtract (CMP status = Rn - Rm)
 	{5'b10110,11'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b10,2'b10,instruction_out[10:8],
						8'b0,5'b0,instruction_out[7:5],instruction_out[4:3],instruction_out[2:0]};//And (AND Rd = Rn & Rm)
	{5'b10111,11'bx}: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {instruction_out[15:13],2'b11,2'b11,3'b0,
						8'b0,5'b0,instruction_out[7:5],instruction_out[4:3],instruction_out[2:0]};//Not (MVN Rd = ~Rm)
	default: {opcode,op,ALUop,Rn,imm8,imm5,Rd,shift,Rm} = {3'bx,2'bx,2'bx,3'bx,8'bx,5'bx,3'bx,2'bx,3'bx}; //for now any other operation will set all vars to x 
    endcase
end
endmodule
