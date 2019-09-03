`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2019 18:01:21
// Design Name: 
// Module Name: show_one_char
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


module show_one_char(
	input clk, 
	input rst, 
	input [10:0]hc_visible,
	input [10:0]vc_visible,
	input [7:0] the_char,
	output in_square,
	output logic in_character
	);
	
	parameter n = 						3;				//numero de bits necesario para contar los pixeles definidos por ancho_pixel
														// n = log_2 (ancho_pixel)
	parameter ancho_pixel = 			'd7;			//ancho y alto de cada pixel que compone a un caracter.
	parameter CHAR_X_LOC =				11'd70;
	parameter CHAR_Y_LOC =				11'd150;
	localparam CHARACTER_WIDTH = 		8'd5;
	localparam CHARACTER_HEIGHT = 		8'd8;
	localparam MAX_CHARACTER_LINE = 	1;		//habran 1 caracteres por linea
	localparam MAX_NUMBER_LINES = 		1;		//numero de lineas
	localparam MENU_WIDTH = 			( CHARACTER_WIDTH + 8'd1 ) * MAX_CHARACTER_LINE * ancho_pixel + ancho_pixel;
	localparam MENU_HEIGHT =			(CHARACTER_HEIGHT) * MAX_NUMBER_LINES * ancho_pixel  + ancho_pixel;
	localparam CHAR_X_TOP = 			CHAR_X_LOC + MENU_WIDTH;
	localparam CHAR_Y_TOP = 			CHAR_Y_LOC + MENU_HEIGHT;

	logic [7:0]push_menu_minimat_x;			//se incremente a incrementos de ancho de caracter
	logic [7:0]push_menu_minimat_y;			//se incremente a incrementos de largo de caracter
	logic [7:0]push_menu_minimat_x_next;
	logic [7:0]push_menu_minimat_y_next;
	
	
	logic [2:0]pixel_x_to_show;				//indica la coordenada x del pixel que se debe dibujar
	logic [2:0]pixel_y_to_show;				//indica la coordenada y del pixel que se debe dibujar
	logic [2:0]pixel_x_to_show_next;
	logic [2:0]pixel_y_to_show_next;
	
	logic [10:0]hc_visible_menu;				//para fijar la posicion x en la que aparecera el cuadro de texto
	logic [10:0]vc_visible_menu;				//para fijar la posicion y en la que aparecera el cuadro de texto
	
	logic in_square_hc;
	logic in_square_vc;
		
	assign in_square = (hc_visible_menu > 0) && (vc_visible_menu > 0);
	assign in_square_hc = in_square && (hc_visible_menu > ancho_pixel); // para comenzar a pintar a una distancia igual a ancho_pixel del borde
	assign in_square_vc = (vc_visible_menu > ancho_pixel); // para comenzar a pintar a una distancia igual a ancho_pixel del borde
	
	assign hc_visible_menu = ( (hc_visible >= CHAR_X_LOC) && (hc_visible <= CHAR_X_TOP) )? hc_visible - CHAR_X_LOC:11'd0;
	assign vc_visible_menu = ( (vc_visible >= CHAR_Y_LOC) && (vc_visible <= CHAR_Y_TOP) )? vc_visible - CHAR_Y_LOC:11'd0;
	
	
	logic [n-1:0]contador_pixels_horizontales;	//este registro cuenta de 0 a 2
	logic [n-1:0]contador_pixels_verticales;	//este registro cuenta de 0 a 2
	
	logic [n-1:0]contador_pixels_horizontales_next;
	logic [n-1:0]contador_pixels_verticales_next;
	//1 pixel por pixel de letra
	
	//contando cada 3 pixeles
	always_comb
		if(in_square_hc)
			if(contador_pixels_horizontales == (ancho_pixel - 'd1))
				contador_pixels_horizontales_next = 2'd0;
			else
				contador_pixels_horizontales_next = contador_pixels_horizontales + 'd1;
		else
			contador_pixels_horizontales_next = 'd0;
			
	always_ff@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_horizontales <= 'd0;
		else
			contador_pixels_horizontales <= contador_pixels_horizontales_next;
//////////////////////////////////////////////////////////////////////////////			
	
//contando cada tres pixeles verticales
	always_comb
		if(in_square_vc)
			if(hc_visible_menu == MENU_WIDTH)
				if(contador_pixels_verticales == (ancho_pixel - 'd1))
					contador_pixels_verticales_next = 'd0;
				else
					contador_pixels_verticales_next = contador_pixels_verticales + 'd1;
			else
				contador_pixels_verticales_next = contador_pixels_verticales;
		else
			contador_pixels_verticales_next = 'd0;
			
	always_ff@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_verticales <= 'd0;
		else
			contador_pixels_verticales <= contador_pixels_verticales_next;
/////////////////////////////////////////////////////////////////////////////
	
//Calculando en que caracter est?? el haz y qu?? pixel hay que dibujar
	logic pixel_limit_h = contador_pixels_horizontales == (ancho_pixel - 'd1);//cuando se lleg?? al m??ximo.
	logic hor_limit_char = push_menu_minimat_x == ((CHARACTER_WIDTH + 8'd1) - 8'd1);//se debe agregar el espacio de separaci??n

	always_comb
	begin
		case({in_square_hc, pixel_limit_h, hor_limit_char})
			3'b111: push_menu_minimat_x_next = 8'd0;
			3'b110: push_menu_minimat_x_next = push_menu_minimat_x + 8'd1;
			3'b100, 3'b101: push_menu_minimat_x_next = push_menu_minimat_x;
			default: push_menu_minimat_x_next = 8'd0;
		endcase
		
		case({in_square_hc,pixel_limit_h,hor_limit_char})
			3'b111: pixel_x_to_show_next = 3'd0;
			3'b110: pixel_x_to_show_next = pixel_x_to_show + 3'd1;
			3'b100,3'b101: pixel_x_to_show_next = pixel_x_to_show;
			default:pixel_x_to_show_next = 3'd0;
		endcase
	end
	
	always_ff@(posedge clk)
	begin
		push_menu_minimat_x <= push_menu_minimat_x_next;
		pixel_x_to_show <= pixel_x_to_show_next;
	end

	logic pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 'd1) && (hc_visible_menu == MENU_WIDTH)); //cuando se llega al maximo.
	logic ver_limit_char = push_menu_minimat_y == (CHARACTER_HEIGHT - 8'd1);

	always_comb
	begin
		case({in_square_vc, pixel_limit_v, ver_limit_char})
			3'b111:push_menu_minimat_y_next = 8'd0;
			3'b110:push_menu_minimat_y_next = push_menu_minimat_y + 8'd1;
			3'b100,3'b101:push_menu_minimat_y_next = push_menu_minimat_y;
			default:push_menu_minimat_y_next = 8'd0;
		endcase
		
		case({in_square_vc, pixel_limit_v, ver_limit_char})
			3'b111:pixel_y_to_show_next = 3'd0;
			3'b110:pixel_y_to_show_next = pixel_y_to_show + 3'd1;
			3'b100,3'b101:pixel_y_to_show_next = pixel_y_to_show;
			default:pixel_y_to_show_next = 3'd0;
		endcase
	end
	
	always_ff@(posedge clk)
	begin
		push_menu_minimat_y <= push_menu_minimat_y_next;
		
		pixel_y_to_show <= pixel_y_to_show_next;
	end

	logic [8 * MAX_CHARACTER_LINE - 1:0] tex_row_tmp;
	
	logic [7:0]select;
	assign tex_row_tmp = the_char;
	assign select = tex_row_tmp[7:0];
	
	logic pix;
	characters m_ch(select, pixel_x_to_show, pixel_y_to_show, pix);
	
	always_comb
		if(in_square_hc && in_square_vc)
			if(pixel_x_to_show == 5)
				in_character = 1'd0;
			else
				in_character = pix;
		else
			in_character = 1'd0;
endmodule

