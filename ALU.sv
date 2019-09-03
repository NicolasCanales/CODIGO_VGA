`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.08.2019 06:10:03
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU#(parameter entradas =16, parameter salida = 16)(
   input logic [entradas - 1 :0] A,
   input logic [entradas - 1:0] B,
   input logic [4:0] op, 
   output logic [salida - 1:0]C  
   );

always_comb begin
   if(op==5'b10000)begin
      C = A + B;
      end
   else if(op==5'b10100)begin
             if (A>B) begin
                C = A - B;
                end
             else begin
                C = B - A;
                end
             end
   else if(op==5'b10101)begin
        C = A | B;
        end    
   else if(op==5'b10010)begin
        C = A & B;
        end
   else if(op==5'b10001)begin
        C = A * B;
        end     
        
   else begin
       C = 16'd0;
       end
   
   end
endmodule

