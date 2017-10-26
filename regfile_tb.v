/*Test Bench for Register*/
`define REG0 3'b000
`define REG1 3'b001
`define REG2 3'b010
`define REG3 3'b011
`define REG4 3'b100
`define REG5 3'b101
`define REG6 3'b110
`define REG7 3'b111
module regfile_tb();

reg clk,write;
reg [2:0] writenum, readnum;
reg [15:0] in;
wire [15:0] out;

//instatiating the register module from regfile.v
regfile DUT(
  .clk(clk),
  .write(write),
  .writenum(writenum),
  .readnum(readnum),
  .data_in(in),
  .data_out(out)
);

initial begin
  //Going to start with empty registers and will read to register 2 
  writenum = `REG0;
  readnum = `REG2;
  write = 0;
  clk = 0;
  in = 42;
  #5;
  $display("%b is data_out, it should be all x as nothing is set in this register",out);
  
  //Now let us try to write to register 0
  write = 1;
  clk = 1;
  readnum = `REG0;
  #5; 
  $display("%b is data_out, it should be %b",out,42);

  /*So so far, we only have the 0th register written to, let us try to write to the other registers
  with a value of one*/
  clk = 0; write = 0; #5; 
  in = 1; write = 1; #10; writenum = `REG1; #5; 
  clk = 1; #5; 
  in = 2; clk = 0; writenum = `REG2; #5; 
  clk = 1; #5;
  in = 3; clk = 0; writenum = `REG3; #5;
  clk = 1; #5; 
  in = 4; clk = 0; writenum = `REG4; #5;
  clk = 1; #5; 
  in = 5; clk = 0; writenum = `REG5; #5; 
  clk = 1; #5;
  in = 6; clk = 0; writenum = `REG6; #5; 
  clk = 1; #5;
  in = 7; clk = 0; writenum = `REG7; #5; 
  clk = 1; #5;
  clk = 0; writenum = `REG1; write = 0; in = 19; #5; //Testing out if the rise of clk with write = 0 works as it should
  clk = 1; #5; //This should not change number stored in REGISTER 1 
 
  /*Now we will read the numbers from the various registers, notice that there is a 
    delay needed after setting readnum to a register as it takes time to read the register
    if not included it will read the previous register that readnum was set to*/
  readnum = `REG1; #5;
  $display("%b is dataout for REG1, should be %b",out,1); #5;
  readnum = `REG2; #5;
  $display("%b is dataout for REG2, should be %b",out,2); #5;
  readnum = `REG3; #5;
  $display("%b is dataout for REG3, should be %b",out,3); #5;
  readnum = `REG4; #5;
  $display("%b is dataout for REG4, should be %b",out,4); #5;
  readnum = `REG5; #5;
  $display("%b is dataout for REG5, should be %b",out,5); #5;
  readnum = `REG6; #5;
  $display("%b is dataout for REG6, should be %b",out,6); #5;
  readnum = `REG7; #5;
  $display("%b is dataout for REG7, should be %b",out,7); #5; 

end
endmodule 