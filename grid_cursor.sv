`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.08.2019 02:51:37
// Design Name: 
// Module Name: grid_cursor
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


module grid_cursor(
    input clk, rst,
	input restriction,
	input PB1,PB2,PB3,PB4,PB5,
	output logic ONCE,
	output logic [2:0] pos_x,
	output logic [1:0] pos_y,
	output logic [4:0] val
	);
    
	logic [2:0]pos_x_next;
	logic [1:0]pos_y_next;
	logic ONAB,PRESSED1,OFF1;
	logic ONIZ,PRESSED2,OFF2;
	logic ONDE,PRESSED3,OFF3;
	logic ONAR,PRESSED4,OFF4;
	logic PRESSED5,OFF5;
    
	logic [1:0] ff;
	logic [1:0]count_ne;
	logic restriction_ne;
//definición de val
	always_comb
		case(pos_x)
			3'd0:
					case(pos_y)
						2'd0: val = 5'd0;
						2'd1: val = 5'd4;
						2'd2: val = 5'd8;
						2'd3: val = 5'hc;
					endcase
			3'd1:
					case(pos_y)
						2'd0: val = 5'd1;
						2'd1: val = 5'd5;
						2'd2: val = 5'd9;
						2'd3: val = 5'hd;
					endcase
		
			3'd2:
					case(pos_y)
						2'd0: val = 5'd2;
						2'd1: val = 5'd6;
						2'd2: val = 5'ha;
						2'd3: val = 5'he;
					endcase
			3'd3:
					case(pos_y)
						2'd0: val = 5'd3;
						2'd1: val = 5'd7;
						2'd2: val = 5'hb;
						2'd3: val = 5'hf;
					endcase
			3'd4:
					case(pos_y)
						2'd0: val = 5'b1_0000;//suma
						2'd1: val = 5'b1_0001;//mult
						2'd2: val = 5'b1_0010;//and
						2'd3: val = 5'b1_0011;//EXE
					endcase
			3'd5:
					case(pos_y)
						2'd0: val = 5'b1_0100;//resta
						2'd1: val = 5'b1_0101;//or
						2'd2: val = 5'b1_0110;//CE
						2'd3: val = 5'b1_0111;//CLR
					endcase
			default:
					val = 5'h1F;
		endcase

	//FILL HERE
debouncer PBD1(.clock(clk),.reset(rst),.PB(PB1),.PB_pressed_state(PRESSED1),
                           .PB_pressed_pulse(OFF1),.PB_released_pulse(ONAB));
                            
debouncer PBD2(.clock(clk),.reset(rst),.PB(PB2),.PB_pressed_state(PRESSED2),
                           .PB_pressed_pulse(OFF2),.PB_released_pulse(ONAR));                            
     
debouncer PBD3(.clock(clk),.reset(rst),.PB(PB3),.PB_pressed_state(PRESSED3),
                           .PB_pressed_pulse(OFF3),.PB_released_pulse(ONDE)); 

debouncer PBD4(.clock(clk),.reset(rst),.PB(PB4),.PB_pressed_state(PRESSED4),
                            .PB_pressed_pulse(OFF4),.PB_released_pulse(ONIZ));
                            
debouncer PBD5(.clock(clk),.reset(rst),.PB(PB5),.PB_pressed_state(PRESSED5),
                           .PB_pressed_pulse(OFF5),.PB_released_pulse(ONCE));
                           
                
always_comb begin
    case(restriction_ne) 
     0: begin  
            pos_y_next = 2'd0;
            pos_x_next = 3'd0;   
            if (pos_x == 3'd5 & ONDE) begin pos_y_next = pos_y; pos_x_next = 3'd0;end
            else if (pos_x == 3'd0 & ONIZ)begin pos_y_next = pos_y; pos_x_next = 3'd5; end                              
            else if (pos_y == 2'd3 & ONAB)begin pos_y_next = 2'd0; pos_x_next = pos_x; end
            else if (pos_y == 2'd0 & ONAR)begin pos_y_next = 2'd3;pos_x_next = pos_x;end
            else if (pos_x != 3'd5 & ONDE)begin pos_x_next = pos_x + 3'd1; pos_y_next = pos_y;end
            else if (pos_x != 3'd0 & ONIZ)begin pos_x_next = pos_x - 3'd1;pos_y_next = pos_y;end
            else if (pos_y != 2'd0 & ONAR)begin pos_y_next = pos_y - 2'd1;pos_x_next = pos_x;end
            else if (pos_y != 2'd3 & ONAB)begin pos_y_next = pos_y + 2'd1;pos_x_next = pos_x; end
            else begin pos_y_next = pos_y; pos_x_next = pos_x;end
        end
     1: begin   
          pos_y_next = 2'd0;
          pos_x_next = 3'd0;  
           if (((pos_x == 3'd5 & (pos_y== 2'd0||pos_y==1)/*& ONDE*/ || (pos_x == 3'd1 & pos_y == 2'd2)) & ONDE))begin pos_x_next = 3'd0;pos_y_next = pos_y;end     
          else if ((pos_x == 3'd5 & (pos_y == 2'd2 || pos_y == 2'd3)) & ONDE) begin pos_x_next = 3'd4;pos_y_next = pos_y; end
          else if ((pos_x == 3'd0 & ONIZ) || ((pos_x == 3'd4 & (pos_y == 2'd2 ||pos_y == 2'd3)) & ONIZ))begin pos_x_next = 3'd5;pos_y_next = pos_y;end
          else if (pos_y == 2'd3 & ONAB )begin pos_y_next = 2'd0;pos_x_next = pos_x;end
          /*else if ((pos_y == 2'd0 & ONAR) || 
                (((pos_x == 3'd0 || pos_x == 3'd1) & pos_y == 2'd2) & ONAB)||
                 ((pos_x == 3'd2 || pos_x == 3'd3) & pos_y == 2'd1) & ONAB)begin pos_y_next = 2'd3;pos_x_next = pos_x;end*/
          else if (((pos_x == 3'd4 || pos_x == 3'd5) & pos_y == 2'd0) & ONAR) begin pos_y_next = 2'd3;pos_x_next = pos_x;end
          else if ((pos_x == 3'd5 & pos_y == 2'd3) & ONDE) begin pos_y_next = pos_y;pos_x_next = 3'd4;end
          else if (((pos_x == 3'd0 || pos_x == 3'd1) & pos_y == 2'd2) & ONAB) begin pos_y_next = 2'd0;pos_x_next = pos_x;end
          else if (((pos_x == 3'd2 || pos_x == 3'd3) & pos_y == 2'd1) & ONAB) begin pos_y_next = 2'd0;pos_x_next = pos_x;end
          else if (((pos_x == 3'd0 || pos_x == 3'd1) & pos_y == 2'd0) & ONAR) begin pos_y_next = 2'd2;pos_x_next = pos_x;end
          else if (((pos_x == 3'd2 || pos_x == 3'd3) & pos_y == 2'd0) & ONAR) begin pos_y_next = 2'd1;pos_x_next = pos_x;end
          else if (pos_x != 3'd5 & ONDE)begin pos_x_next = pos_x + 3'd1;pos_y_next = pos_y;end
          else if (pos_x != 3'd0 & ONIZ)begin pos_x_next = pos_x - 3'd1;pos_y_next = pos_y;end
          else if (pos_y != 2'd0 & ONAR)begin pos_y_next = pos_y - 2'd1;pos_x_next = pos_x;end
          else if (pos_y != 2'd3 & ONAB)begin pos_y_next = pos_y + 2'd1;pos_x_next = pos_x;end
          else begin pos_y_next = pos_y; pos_x_next = pos_x;end
        end   
    default: begin pos_y_next = 2'd0;
                   pos_x_next = 3'd0;end
    endcase    
	//movimiento de pos_x y pos_y.    
end

logic q = 0;

always_ff @(posedge clk) 
if(rst)
    q <= 0;
else
    q <= restriction;

always_ff @(posedge clk, posedge rst) 
            if(rst || ((~q)&restriction) ) begin
                restriction_ne <= 0;
                pos_x <= 3'd0; 
                pos_y <= 2'd0; 
            end
            else begin
                pos_x <= pos_x_next;
                pos_y <= pos_y_next;
                restriction_ne <= restriction; 
           end           
endmodule
