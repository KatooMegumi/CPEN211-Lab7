/*Test Bench for ALU*/
module alu_tb();

reg [1:0] alu_op; 
reg [15:0] ain, bin;
wire [15:0] out;
wire [2:0]status;

//Instantiating the alu module 
alu DUT(
  .ALUop(alu_op),
  .Ain(ain),
  .Bin(bin),
  .out(out),
  .status(status)
);

initial begin
  ain = {12'b0,4'b0100};
  bin = {12'b0,4'b0011}; 
  alu_op = 2'b00; #5;
  //The answer should be addition, so should be equal to 5
  $display("%b, should be %b", out, {12'b0,4'b011}); #1; 

  //now let us change the operations first 
  alu_op = 2'b01;  #5;
  $display(("%b, should be %b"), out, {15'b0,1'b1}); #1;
 
  alu_op = 2'b10; #5; 
  $display(("%b, should be %b"), out, 16'b0); #1;

  alu_op = 2'b11; #5;
  $display(("%b, should be %b"), out, ~bin); #1;

  //now let us try to change the ain and bin and test it out with addition
  alu_op = 2'b00; ain = {12'b0, 4'b0101};
  #5;
  ain = {12'b0,4'b1010};
  $display(("%b, should be %b"), out, {12'b0,4'b1000}); #1;

  bin = {12'b0, 4'b0101}; #5;
  $display(("%b, should be %b"), out, {12'b0,4'b1111}); #1;

  ain = {12'b0, 4'b0101};
  alu_op = 2'b01; #5;
  $display(("%b, should be %b"), out, 16'b0); #1;
  #5;
  //Test overflow
  ain = 16'b1111111111111111;
  bin = 16'b1111111111111111;
  alu_op = 2'b00;
  #5;
  if( alu_tb.DUT.ovf !== 1'b0 )begin
	$display("ERROR ** overflow is %b, should be %b",alu_tb.DUT.ovf,1'b0);
  end
  
end
endmodule 