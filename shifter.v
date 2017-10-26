/*Lab 5 shifter module*/
module shifter(shift,bin,out);
input [15:0] bin;
input [1:0] shift;
output reg [15:0] out;  

  always @(*) begin
    case(shift) 
      2'b01: out = bin << 1; //shift left one 
      2'b10: out = bin >> 1; //shift right one
      2'b11: out = $signed(bin) >>> 1; //shift right one and copy leftmost bit into leftmost afterwards 
      default: out = bin; //default is 2'b00
    endcase 
  end 
endmodule 
