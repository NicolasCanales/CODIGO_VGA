`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 

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


module EstadoALU(
    input logic clk_in,reset,
    input logic [4:0] valor,
    input logic BTNC,
    output logic [1:0]estado_alu
    );
    
    enum logic [1:0] {W1,W2,WOP,GOP} state, nextstate;
    
    assign estado_alu=state;
    
    localparam EXE=5'b10011;
    localparam CLR=5'b10111;
    localparam CE = 5'b10110;
    
    always_ff @(posedge clk_in or posedge reset) begin
        if (reset==1)
             state <= W1;
        else 
             state <= nextstate;
            
        end
   always_comb begin
       nextstate = state; 
             
       case (state) 
               W1: if (BTNC==1 && valor==EXE) begin
                        nextstate = W2;  
                        end
                   else if (BTNC==1 && valor==CLR) begin
                        nextstate = W1;
                        end                                    
               W2: if (BTNC==1 && valor==EXE) begin
                        nextstate = WOP;
                        end 
                   else if (BTNC==1 && valor==CLR) begin
                        nextstate = W1;
                        end 
                   else if (BTNC==1 && valor==CE) begin
                        nextstate = W1;
                        end    
               WOP: if(BTNC==1 && valor==EXE) begin
                        nextstate = GOP;
                        end
                   else if (BTNC==1 && valor==CLR) begin
                        nextstate = W1;
                        end 
                   else if (BTNC==1 && valor==CE) begin
                        nextstate = W2;
                        end                                                                           
               GOP: if (BTNC==1 && valor==EXE) begin
                        nextstate = W1;
                        end
                    else if (BTNC==1 && valor==CLR) begin
                        nextstate = W1;
                        end    
                    else if (BTNC==1 && valor==CE) begin
                        nextstate = WOP;
                        end
        endcase
        end                                               
                                                       
    endmodule
