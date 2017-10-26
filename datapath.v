module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel,
		ALUop, loadc, loads, writenum, write, mdata, 
		status, C, sximm8, PC, sximm5);

  input clk, loada, loadb, loadc, loads, asel, bsel, write;
  input [1:0] vsel;
  input [1:0] shift, ALUop; 
  input [2:0] writenum, readnum;  
  input [15:0] mdata, sximm8, sximm5;
  input [7:0] PC;
  output wire [2:0] status;
  output wire [15:0] C;
  reg [15:0] data_in;
  wire [15:0] muxa, muxb, aout, bout, bout_shift, data_out, ALUout;
  wire [2:0] status_out;
 
  always @(*)
    case(vsel)
      2'b00: data_in = C;
      2'b01: data_in = {8'b0,PC};
      2'b10: data_in = sximm8;
      2'b11: data_in = mdata;
    endcase
  
  //The 8 Register File which will determine whether or not to 
  //write or read to a register, will only return out data_out when 
  //reading a register 
  regfile REGFILE( .clk(clk), 
           		.write(write),
			.writenum(writenum),
			.readnum(readnum),
			.data_in(data_in),
			.data_out(data_out)
  );
  
  //Pipeline Registers A, B, C and Status
  vDFFE #(16) reg_a(clk, loada, data_out, aout);
  vDFFE #(16) reg_b(clk, loadb, data_out, bout); 
  vDFFE #(16) reg_c(clk, loadc, ALUout, C);
  vDFFE #(3) status_block(.clk(clk), .en(loads), .in(status_out), .out(status));

  //Shifter for Reg_B
  shifter shift_b(shift, bout, bout_shift);

  //Source operand MUX (A and B)  
  assign muxa = asel ? 16'b0:aout;
  assign muxb = bsel ? sximm5:bout_shift;

  //ALU block, which will add muxa + muxb, subtract muxa -muxb, 
  //bitwise AND muxa&muxb, or NOT ~muxb and return that 16'b value for reg_c as 
  //well as a 1'b value for status block (1 if ALUout = 16'b0, 0 otherwise)
  alu ALU( .ALUop(ALUop), .Ain(muxa), .Bin(muxb), .out(ALUout), .status(status_out));

endmodule 
