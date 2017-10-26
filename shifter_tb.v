/*Shifter Test Bench*/
module shifter_tb();

reg [15:0] in;
reg [1:0] shift;
wire [15:0] out; 

shifter DUT(
  .bin(in),
  .shift(shift),
  .out(out)
);

initial begin
  in = 16'b1111000011001111;
  shift = 2'b00; #5;
  $display(("%b, should be %b"),out,in); 

  shift = 2'b01; #5;
  $display(("%b, should be %b"),out, 16'b1110000110011110);

  shift = 2'b10; #5;
  $display(("%b, should be %b"),out, 16'b0111100001100111);
  
  shift = 2'b11; #5;
  $display(("%b, should be %b"),out, 16'b1111100001100111);
end
endmodule 