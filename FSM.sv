`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 

// 
//////////////////////////////////////////////////////////////////////////////////


module FSM  (
    input logic clk,reset,boton, mode,
    input logic [1:0] estado,
    input logic [4:0] valor,
    output logic [4:0] operador,
    output logic [15:0] operando1,operando2
    );
    
    
    logic [15:0] op1, op2;
    logic [4:0] op,op_next;
    logic [15:0] co_next,cor_next;
    
    always_comb begin
        co_next=op1;
        cor_next=op2;
        op_next=op;
        case(mode)
            0:  case(estado)
                    3'd0: if(valor<=5'b01111 && boton==1 && ({op1,valor[3:0]}<=20'h0FFFF)) begin// espera op1
                        co_next={op1[11:0],valor[3:0]};
                        end
                      else if(boton==1 && valor==5'b1_0110) begin
                        co_next=16'h0000;
                        end
                        
                3'd1: if(valor<=5'b01111 && boton==1 && ({op2,valor[3:0]}<=20'h0FFFF)) begin//espera op2
                        cor_next={op2[11:0],valor[3:0]};
                        end
                      else if(boton==1 && valor==5'b1_0110) begin
                        cor_next=16'h0000;
                        end  
                        
                3'd2: if((valor>5'b01111) && (valor!=5'b1_0011) && (valor!=5'b1_0110)&& (valor!=5'b1_0111) && (boton==1))//esper operac
                        op_next=valor;
                      else if(boton==1 && valor==5'b1_0110) begin
                    op_next=5'b11000;
                    end  
                endcase
            1:  case(estado)
                    3'd0: if(valor<=5'b01111 && boton==1 && ({op1,valor[3:0]}<=20'h0FFFF)) begin// espera op1
                        co_next=op1+op1*16'd9+({12'd0,valor[3:0]});
                        end
                      else if(boton==1 && valor==5'b1_0110) begin
                        co_next=16'h0000;
                        end
                        
                3'd1: if(valor<=5'b01111 && boton==1 && ({op2,valor[3:0]}<=20'h0FFFF)) begin//espera op2
                        cor_next=op2+op2*16'd9+({12'd0,valor[3:0]});
                        end
                      else if(boton==1 && valor==5'b1_0110) begin
                        cor_next=16'h0000;
                        end  
                        
                3'd2: if((valor>5'b01111) && (valor!=5'b1_0011) && (valor!=5'b1_0110)&& (valor!=5'b1_0111) && (boton==1))//esper operac
                        op_next=valor;
                      else if(boton==1 && valor==5'b1_0110) begin
                    op_next=5'b11000;
                    end  
                endcase
        endcase
    end             
                                                       
        
    always_ff @(posedge clk) begin
        if (reset==1) begin
            op1<=16'h0000;
            op2<=16'h0000;
            op<=5'b11000;
            end
            
        else if(boton==1 && valor==5'b1_0011 && estado==3'd3) begin
            op1<=16'h0000;
            op2<=16'h0000;
            op<=5'b11000; 
            end 
        else if(boton==1 && valor==5'b1_0111 && estado==3'd0) begin
                        op1<=16'h0000;
                        op2<=16'h0000;
                        op<=5'b11000; 
                        end 
        else if(boton==1 && valor==5'b1_0111 && estado==3'd1) begin
                            op1<=16'h0000;
                            op2<=16'h0000;
                            op<=5'b11000; 
                            end 
        else if(boton==1 && valor==5'b1_0111 && estado==3'd2) begin
                                op1<=16'h0000;
                                op2<=16'h0000;
                                op<=5'b11000; 
                                end                                           
        else if(boton==1 && valor==5'b1_0111 && estado==3'd3) begin
            op1<=16'h0000;
            op2<=16'h0000;
            op<=5'b11000; 
            end             

        else begin   
        op1 <= co_next;
        op2 <= cor_next;
        op <= op_next;
        end
        end
    
    assign operando1=op1;
    assign operando2=op2;
    assign operador=op;
    
endmodule