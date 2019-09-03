`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2019 16:31:34
// Design Name: 
// Module Name: lab_8
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


module lab_8(
	input CLK100MHZ,
	input SW,
//	input CPU_RESETN,
	input BTNC,	BTNU, BTNL, BTNR, BTND, CPU_RESETN,
//	output [15:0] LED,
//	output CA, CB, CC, CD, CE, CF, CG,
//	output DP,
//	output [7:0] AN,

	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);
	
	
	logic CLK82MHZ;
	logic rst = 0;
	logic hw_rst = ~CPU_RESETN;
	
	clk_wiz_0 inst(
		// Clock out ports  
		.clk_out1(CLK82MHZ),
		// Status and control signals               
		.reset(1'b0), 
		//.locked(locked),
		// Clock in ports
		.clk_in1(CLK100MHZ)
		);
	//Fill here
	
      


	/************************* VGA ********************/
//	logic [2:0] op;
	logic [2:0] pos_x;
	logic [1:0] pos_y;
	logic [15:0] op1, op2;
	
	logic restriction;
	logic MASTER_BTNC;
	logic [4:0] value;
	logic [1:0] estadito;
	logic [15:0] resultado;
	logic [15:0] opera1,opera2;
	logic [4:0] simbolito;
	logic [4:0] operacion;
	
	assign simbolito = value;
    logic ocupado,ocupado2,ocupado3;
    logic [31:0]enbcd,enbcd2,enbcd3;
    logic [15:0] pantalla, operando1, operando2;
    logic [15:0] pantallita;
    
    logic b_u,b_c,b_l, b_r, b_d;
    grid_cursor gridcursor(.restriction(SW), .clk(CLK82MHZ),.rst(hw_rst),.PB5(BTNC),.PB2(BTNU), .ONCE(MASTER_BTNC),
                          .PB4(BTNL),.PB3(BTNR),.PB1(BTND),.pos_x(pos_x),.pos_y(pos_y), .val(value));  
	EstadoALU estado(.clk_in(CLK82MHZ), .reset(hw_rst), .BTNC(MASTER_BTNC), .valor(value), .estado_alu(estadito)); 
    
    FSM quehacer(.clk(CLK82MHZ),.reset(hw_rst),.boton(MASTER_BTNC),.estado(estadito),.valor(simbolito),.mode(SW),.operando1(opera1),.operando2(opera2),.operador(operacion)); 
   
    ALU alu(.A(opera1),.B(opera2),.op(operacion),.C(resultado));
	
	calculator_screen(
		.clk_vga(CLK82MHZ),
		.rst(hw_rst),
		.mode(SW),
//		.op(operacion[2:0]),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.op1(opera1),
		.op2(opera2),
		.input_screen(pantalla),
		.estado(estadito),
		.valor(operacion),
		
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B));
        
        
    
        always_comb begin
          pantalla=16'h00;
          
          case(estadito)
          3'd0: pantalla= operando1;
          3'd1: pantalla= operando2;
          3'd3: pantalla= resultado;
          endcase
          end
      
      always_comb begin
          operando1=16'h0000;
          operando2=16'h0000;
          case(estadito)
          3'd0: begin
                  operando1=16'h0000;
                  operando2=16'h0000;
                  end
          3'd1: begin
                  operando1=opera1;
                  operando2=16'h0000;
                  end
          3'd2: begin
                  operando1=opera1;
                  operando2=opera2;
                  end
          3'd3: begin
                  operando1=opera1;
                  operando2=opera2;
                  end        
          endcase
          end
      

 
    
endmodule

module unsigned_to_bcd

(

	input clk,            // Reloj

	input trigger,        // Inicio de conversión

	input [31:0] in,      // Número binario de entrada

	output reg idle,      // Si vale 0, indica una conversión en proceso

	output reg [31:0] bcd // Resultado de la conversión

);



	/*

	 * Por "buenas prácticas" parametrizamos las constantes numéricas de los estados

	 * del módulo y evitamos trabajar con números "mágicos" en el resto del código.

	 *

	 * https://en.wikipedia.org/wiki/Magic_number_(programming)

	 * http://stackoverflow.com/questions/47882/what-is-a-magic-number-and-why-is-it-bad

	 */

	localparam S_IDLE  = 'b001;

	localparam S_SHIFT = 'b010;

	localparam S_ADD3  = 'b100;



	reg [2:0] state, state_next; /* Contiene al estado actual y al siguiente */



	reg [31:0] shift, shift_next;

	reg [31:0] bcd_next;



	localparam COUNTER_MAX = 32;

	reg [5:0] counter, counter_next; /* Contador 6 bit para las iteraciones */



	always @(*) begin

		/*

		 * Por defecto, los estados futuros mantienen el estado actual. Esto nos

		 * ayuda a no tener que ir definiendo cada uno de los valores de las señales

		 * en cada estado posible.

		 */

		state_next = state;

		shift_next = shift;

		bcd_next = bcd;

		counter_next = counter;



		idle = 1'b0; /* LOW para todos los estados excepto S_IDLE */



		case (state)

		S_IDLE: begin

			counter_next = 'd1;

			shift_next = 'd0;

			idle = 1'b1;



			if (trigger) begin

				state_next = S_SHIFT;

			end

		end

		S_ADD3: begin

			/*

			 * Sumamos 3 a cada columna de 4 bits si el valor de esta es

			 * mayor o igual a 5

			 */

			if (shift[31:28] >= 5)

				shift_next[31:28] = shift[31:28] + 4'd3;



			if (shift[27:24] >= 5)

				shift_next[27:24] = shift[27:24] + 4'd3;



			if (shift[23:20] >= 5)

				shift_next[23:20] = shift[23:20] + 4'd3;



			if (shift[19:16] >= 5)

				shift_next[19:16] = shift[19:16] + 4'd3;



			if (shift[15:12] >= 5)

				shift_next[15:12] = shift[15:12] + 4'd3;



			if (shift[11:8] >= 5)

				shift_next[11:8] = shift[11:8] + 4'd3;



			if (shift[7:4] >= 5)

				shift_next[7:4] = shift[7:4] + 4'd3;



			if (shift[3:0] >= 5)

				shift_next[3:0] = shift[3:0] + 4'd3;



			state_next = S_SHIFT;

		end

		S_SHIFT: begin

			/* Desplazamos un bit de la entrada en el registro shift */

			shift_next = {shift[30:0], in[COUNTER_MAX - counter_next]};



			/*

			 * Si el contador actual alcanza la cuenta máxima, actualizamos la salida y

			 * terminamos el proceso.

			 */

			if (counter == COUNTER_MAX) begin

				bcd_next = shift_next;

				state_next = S_IDLE;

			end else

				state_next = S_ADD3;



			/* Incrementamos el contador (siguiente) en una unidad */

			counter_next = counter + 'd1;

		end

		default: begin

			state_next = S_IDLE;

		end

		endcase

	end



	always @(posedge clk) begin

		state <= state_next;

		shift <= shift_next;

		bcd <= bcd_next;

		counter <= counter_next;

	end



endmodule
/**
 * @brief Este modulo convierte un numero hexadecimal de 4 bits
 * en su equivalente ascii de 8 bits
 *
 * @param hex_num		Corresponde al numero que se ingresa
 * @param ascii_conv	Corresponde a la representacion ascii
 *
 */




/**
 * @brief Este modulo convierte un numero hexadecimal de 4 bits
 * en su equivalente ascii, pero binario, es decir,
 * si el numero ingresado es 4'hA, la salida debera sera la concatenacion
 * del string "1010" (cada caracter del string genera 8 bits).
 *
 * @param num		Corresponde al numero que se ingresa
 * @param bit_ascii	Corresponde a la representacion ascii pero del binario.
 *
 */
module hex_to_ascii(
	input [3:0] hex_num,
	output logic[7:0] ascii_conv
	);
	
    always_comb begin
        case( hex_num)
        4'h0: ascii_conv = 8'd48;
        4'h1: ascii_conv = 8'd49;  
        4'h2: ascii_conv = 8'd50;
        4'h3: ascii_conv = 8'd51;
        4'h4: ascii_conv = 8'd52;
        4'h5: ascii_conv = 8'd53;
        4'h6: ascii_conv = 8'd54;
        4'h7: ascii_conv = 8'd55;
        4'h8: ascii_conv = 8'd56;
        4'h9: ascii_conv = 8'd57;
        4'ha: ascii_conv = 8'd97;
        4'hb: ascii_conv = 8'd98;
        4'hc: ascii_conv = 8'd99;
        4'hd: ascii_conv = 8'd100;
        4'he: ascii_conv = 8'd101;
        4'hf: ascii_conv = 8'd102;
        default: ascii_conv = 8'd32;
        endcase
        end
	//fill here
endmodule

module op_to_ascii(
	input [4:0] hex_num,
	output logic[7:0] ascii_conv
	);
	
    always_comb begin
        case( hex_num)
        5'b10000: ascii_conv = 8'd43;//suma
        5'b10001: ascii_conv = 8'd42; //mult
        5'b10010: ascii_conv = 8'd38; //and
        5'b10100: ascii_conv = 8'd45; //resta
        5'b10101: ascii_conv = 8'd238; //or
        
        
        /*			8'd26:  vec_char=vect_char_and;
        8'd42:  vec_char=vect_char_multipl;
        8'd43:  vec_char=vect_char_suma;
        8'd45:  vec_char=vect_char_resta; 
        8'd124:  vec_char=vect_char_or;
        
        
        val = 5'b1_0000;//suma
        val = 5'b1_0001;//mult
        val = 5'b1_0010;//and
         val = 5'b1_0011;//EXE
        */
        default begin ascii_conv = 8'd32; end
        endcase
        end
	//fill here
endmodule

module hex_to_bit_ascii(
	input [3:0]num,
	output logic [4*8-1:0]bit_ascii
	);
	
     always_comb begin
       case( num)
       4'h0: bit_ascii = "0000";                                    //{8'd48, 8'd48, 8'd48, 8'd48};
       4'h1: bit_ascii = "0001";                                        //{8'd48, 8'd48, 8'd48, 8'd1};  
       4'h2: bit_ascii = "0010";                                    //{8'd480, 8'd48, 8'd1, 8'd0};
       4'h3: bit_ascii = "0011";                                    //{8'd48, 8'd48, 8'd1, 8'd1};
       4'h4: bit_ascii = "0100";                                    //{8'd48, 8'd1, 8'd48, 8'd48};
       4'h5: bit_ascii = "0101";                //{8'd48, 8'd1, 8'd48, 8'd1};
       4'h6: bit_ascii = "0110";                //{8'd48, 8'd1, 8'd1, 8'd48};
       4'h7: bit_ascii = "0111";                //{8'd48, 8'd1, 8'd1, 8'd1};
       4'h8: bit_ascii = "1000";                //{8'd0, 8'd48, 8'd48, 8'd48};
       4'h9: bit_ascii = "1001";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'ha: bit_ascii = "1010";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'hb: bit_ascii = "1011";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'hc: bit_ascii = "1100";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'hd: bit_ascii = "1101";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'he: bit_ascii = "1110";                //{8'd0, 8'd0, 8'd0, 8'd0};
       4'hf: bit_ascii = "1111";                    //{8'd0, 8'd0, 8'd0, 8'd0};
       endcase
       end
	//fill Here
	
endmodule
/**
 * @brief Este modulo es el encargado de dibujar en pantalla
 * la calculadora y todos sus componentes graficos
 *
 * @param clk_vga		:Corresponde al reloj con que funciona el VGA.
 * @param rst			:Corresponde al reset de todos los registros
 * @param mode			:'0' si se esta operando en decimal, '1' si esta operando hexadecimal
 * @param op			:La operacion matematica a realizar
 * @param pos_x			:Corresponde a la posicion X del cursor dentro de la grilla.
 * @param pos_y			:Corresponde a la posicion Y del cursor dentro de la grilla.
 * @param op1			:El operando 1 en formato hexadecimal.
 * @param op2			;El operando 2 en formato hexadecimal.
 * @param input_screen	:Lo que se debe mostrar en la pantalla de ingreso de la calculadora (en hexa)
 * @param VGA_HS		:Sincronismo Horizontal para el monitor VGA
 * @param VGA_VS		:Sincronismo Vertical para el monitor VGA
 * @param VGA_R			:Color Rojo para la pantalla VGA
 * @param VGA_G			:Color Verde para la pantalla VGA
 * @param VGA_B			:Color Azul para la pantalla VGA
 */
module calculator_screen(
	input logic clk_vga,
	input logic rst,
	input logic mode, //bcd or dec.
//	input logic [2:0]op,
	input logic [2:0]pos_x,
	input logic [1:0]pos_y,
	input logic [15:0] op1,
	input logic [15:0] op2,
	input logic [15:0] input_screen,
	input logic [1:0] estado,
	input logic [4:0] valor,
	
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);
	
	
	localparam CUADRILLA_XI = 		352;
	localparam CUADRILLA_XF = 		CUADRILLA_XI + 600;
	
	localparam CUADRILLA_YI = 		300;
	localparam CUADRILLA_YF = 		CUADRILLA_YI + 400;
	
	
	logic [10:0]vc_visible;
	logic [10:0]hc_visible;
	
	// MODIFICAR ESTO PARA HACER LLAMADO POR NOMBRE DE PUERTO, NO POR ORDEN!!!!!
	driver_vga_1024x768 m_driver(.clk_vga(clk_vga), .hs(VGA_HS), .vs(VGA_VS), .hc_visible(hc_visible), .vc_visible(vc_visible));
	/*************************** VGA DISPLAY ************************/
		
	logic [10:0]hc_template, vc_template;
	logic [2:0]matrix_x;
	logic [1:0]matrix_y;
	logic lines;
	
	template_6x4_600x400 #( .GRID_XI(CUADRILLA_XI), 
							.GRID_XF(CUADRILLA_XF), 
							.GRID_YI(CUADRILLA_YI), 
							.GRID_YF(CUADRILLA_YF)) 
    // MODIFICAR ESTO PARA HACER LLAMADO POR NOMBRE DE PUERTO, NO POR ORDEN!!!!!
	template_1(.clk(clk_vga), .hc(hc_visible), .vc(vc_visible), .matrix_x(matrix_x), .matrix_y(matrix_y), .lines(lines));
	
	logic [11:0]VGA_COLOR;
	
	logic text_sqrt_fg;
	logic text_sqrt_bg;

	logic [23:0]generic_fg;
	logic [23:0]generic_bg;
	
	logic [3:0]generic_1BIN_fg;
	logic [3:0]generic_1BIN_bg;
	
	logic [3:0]generic_2BIN_fg;
	logic [3:0]generic_2BIN_bg;
	
	logic [3:0]generic_3BIN_fg;
	logic [3:0]generic_3BIN_bg;
	
	logic [3:0]generic_NAME_fg;
	logic [3:0]generic_NAME_bg;
    
    logic [2:0]generic_OPE_fg;
	logic [2:0]generic_OPE_bg;
	
	logic [2:0]generic_OPR_fg;
	logic [2:0]generic_OPR_bg;
	
	logic [1:0]generic_NOT_fg;
	logic [1:0]generic_NOT_bg;
	
	logic [1:0]generic_ARROW_fg;
	logic [1:0]generic_ARROW_bg;
	
	logic [1:0]generic_RESULT_fg;
	logic [1:0]generic_RESULT_bg;
	
	localparam GRID_X_OFFSET	= 20;
	localparam GRID_Y_OFFSET	= 10;
	
	localparam FIRST_SQRT_X = 349;
	localparam FIRST_SQRT_Y = 313;
	
	localparam PAR_X_NAME = 30;
	localparam PAR_Y_NAME = 30;
	
	localparam PAR_X_BIN = 30;
	localparam PAR_Y_BIN = 30;
	
	localparam DESFASE_X_FILA = 100;
	localparam DESFASE_Y_FILA = 100;
	
	logic [7:0] op31,op32,op33,op34,op35,op36,op37,op38, op21, op22, op23, op24, op11, op12, op13, op14;
    logic [31:0] bin31, bin32, bin33, bin34;
    logic [31:0] bin21, bin22, bin23, bin24;
    logic [31:0] bin11, bin12, bin13, bin14;
    logic [7:0] operador;
    
    logic [7:0] fdec,fhex;
    
	assign fdec=(mode) ? 8'd60 : " ";
    assign fhex=(mode) ? " " : 8'd60;
    //parte de hex a ascii//
            op_to_ascii operadora(.hex_num(valor), .ascii_conv(operador)); 
            hex_to_ascii ope11(.hex_num(op1[3:0]), .ascii_conv(op11)); 
            hex_to_ascii ope12(.hex_num(op1[7:4]), .ascii_conv(op12));
            hex_to_ascii ope13(.hex_num(op1[11:8]), .ascii_conv(op13));
            hex_to_ascii ope14(.hex_num(op1[15:12]), .ascii_conv(op14));
            hex_to_ascii ope21(.hex_num(op2[3:0]), .ascii_conv(op21)); 
            hex_to_ascii ope22(.hex_num(op2[7:4]), .ascii_conv(op22));
            hex_to_ascii ope23(.hex_num(op2[11:8]), .ascii_conv(op23));
            hex_to_ascii ope24(.hex_num(op2[15:12]), .ascii_conv(op24));  
            hex_to_ascii screen(.hex_num(input_screen[3:0]), .ascii_conv(op31)); 
            hex_to_ascii screen2(.hex_num(input_screen[7:4]), .ascii_conv(op32));
            hex_to_ascii screen3(.hex_num(input_screen[11:8]), .ascii_conv(op33));
            hex_to_ascii screen4(.hex_num(input_screen[15:12]), .ascii_conv(op34)); 
    //hasta acá hex a ascii//
        logic [31:0]enbcd,enbcd2,enbcd3;
        logic [79:0] pantalla, pantalla_comb;
        logic [7:0] op11bcd, op12bcd, op13bcd, op14bcd, op15bcd,
                    op21bcd, op22bcd, op23bcd, op24bcd, op25bcd,
                    op31bcd, op32bcd, op33bcd, op34bcd, op35bcd, 
                    op36bcd, op37bcd, op38bcd;
        logic ocupado3, ocupado, ocupado2;
        logic [39:0] operador1, operador2, operador1_comb, operador2_comb;  
        unsigned_to_bcd HexBcd3(.clk(clk_vga),.trigger(mode),.in({16'd0,input_screen}),.idle(ocupado3),.bcd(enbcd3));
        unsigned_to_bcd HexBcd(.clk(clk_vga),.trigger(mode),.in({16'd0,op1}),.idle(ocupado),.bcd(enbcd)); 
        unsigned_to_bcd HexBcd2(.clk(clk_vga),.trigger(mode),.in({16'd0,op2}),.idle(ocupado2),.bcd(enbcd2));    

        hex_to_ascii o31bcd(.hex_num(enbcd3[3:0]), .ascii_conv(op31bcd)); 
        hex_to_ascii o32bcd(.hex_num(enbcd3[7:4]), .ascii_conv(op32bcd));
        hex_to_ascii o33bcd(.hex_num(enbcd3[11:8]), .ascii_conv(op33bcd));
        hex_to_ascii o34bcd(.hex_num(enbcd3[15:12]), .ascii_conv(op34bcd)); 
        hex_to_ascii o35bcd(.hex_num(enbcd3[19:16]), .ascii_conv(op35bcd));
        hex_to_ascii o36bcd(.hex_num(enbcd3[23:20]), .ascii_conv(op36bcd));
        hex_to_ascii o37bcd(.hex_num(enbcd3[27:24]), .ascii_conv(op37bcd));
        hex_to_ascii o38bcd(.hex_num(enbcd3[31:28]), .ascii_conv(op38bcd));
        
        hex_to_ascii o11bcd(.hex_num(enbcd[3:0]), .ascii_conv(op11bcd)); 
        hex_to_ascii o12bcd(.hex_num(enbcd[7:4]), .ascii_conv(op12bcd));
        hex_to_ascii o13bcd(.hex_num(enbcd[11:8]), .ascii_conv(op13bcd));
        hex_to_ascii o14bcd(.hex_num(enbcd[15:12]), .ascii_conv(op14bcd)); 
        hex_to_ascii o15bcd(.hex_num(enbcd[19:16]), .ascii_conv(op15bcd));
        
        hex_to_ascii o21bcd(.hex_num(enbcd2[3:0]), .ascii_conv(op21bcd)); 
        hex_to_ascii o22bcd(.hex_num(enbcd2[7:4]), .ascii_conv(op22bcd));
        hex_to_ascii o23bcd(.hex_num(enbcd2[11:8]), .ascii_conv(op23bcd));
        hex_to_ascii o24bcd(.hex_num(enbcd2[15:12]), .ascii_conv(op24bcd)); 
        hex_to_ascii o25bcd(.hex_num(enbcd2[19:16]), .ascii_conv(op25bcd));
    // Hex a bcd a ascii//
        hex_to_bit_ascii binarios_11(.num(op1[3:0]), .bit_ascii(bin11)); 
        hex_to_bit_ascii binarios_12(.num(op1[7:4]), .bit_ascii(bin12));
        hex_to_bit_ascii binarios_13(.num(op1[11:8]), .bit_ascii(bin13));
        hex_to_bit_ascii binarios_14(.num(op1[15:12]), .bit_ascii(bin14));
        
        hex_to_bit_ascii binarios_21(.num(op2[3:0]), .bit_ascii(bin21)); 
        hex_to_bit_ascii binarios_22(.num(op2[7:4]), .bit_ascii(bin22));
        hex_to_bit_ascii binarios_23(.num(op2[11:8]), .bit_ascii(bin23));
        hex_to_bit_ascii binarios_24(.num(op2[15:12]), .bit_ascii(bin24));
        
        hex_to_bit_ascii binarios_31(.num(input_screen[3:0]), .bit_ascii(bin31)); 
        hex_to_bit_ascii binarios_32(.num(input_screen[7:4]), .bit_ascii(bin32));
        hex_to_bit_ascii binarios_33(.num(input_screen[11:8]), .bit_ascii(bin33));
        hex_to_bit_ascii binarios_34(.num(input_screen[15:12]), .bit_ascii(bin34)); 
        
        //space_padding prim(.value(op1), .no_paddign(operador1), .paddign(operador1_comb));  
        //space_padding seg(.value(op2), .no_paddign(operador2), .paddign(operador2_comb)); 
               
        
        assign pantalla=(mode) ? {"  ",op38bcd, op37bcd, op36bcd,op35bcd,op34bcd,op33bcd,op32bcd,op31bcd} :{"      ", op34, op33, op32, op31} ; 
        assign operador1=(mode) ? {op15bcd, op14bcd, op13bcd, op12bcd, op11bcd} : {" ", op14, op13, op12, op11};
        assign operador2=(mode) ? {op25bcd, op24bcd, op23bcd, op22bcd, op21bcd} : {" ", op24, op23, op22, op21};
        
        space_padding prim(.value(op1), .no_pading(operador1), .sw(mode), .padding(operador1_comb));  
        space_padding seg(.value(op2), .no_pading(operador2), .sw(mode), .padding(operador2_comb));
        space_padding ter(.value(input_screen), .no_pading(pantalla), .sw(mode), .padding(pantalla_comb));
	
	hello_world_text_square m_hw(	.clk(clk_vga), 
									.rst(1'b0), 
									.hc_visible(hc_visible), 
									.vc_visible(vc_visible), 
									.in_square(text_sqrt_bg), 
									.in_character(text_sqrt_fg));
    logic [1:0] STATE;
	logic [79:0] muda1;
    //space_padding ter(.value(input_screen), .no_pading(muda1), .sw(mode), .padding(muda1_comb));                             
    always_comb
        case(estado)
            0: begin muda1 = {" ",operador1}; 
                     STATE = 2'b0;end
            1: begin muda1 = {" ",operador2}; 
                    STATE = 2'b01;end
            2: begin muda1 = {" ",operador};    
                        STATE = 2'b10;end
            3: begin muda1 = pantalla;  
                    STATE = 2'b11;end
        endcase    
        
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET ), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET )) 
	ch_00(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("0"), 
		  .in_square(generic_bg[0]), 
		  .in_character(generic_fg[0]));
	
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*0)) 
	ch_01(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("1"), 
		  .in_square(generic_bg[1]), 
		  .in_character(generic_fg[1]));	  
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*0)) 
	ch_02(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("2"), 
		  .in_square(generic_bg[2]), 
		  .in_character(generic_fg[2]));	 
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*0)) 
	ch_03(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("3"), 
		  .in_square(generic_bg[3]), 
		  .in_character(generic_fg[3]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*1)) 
	ch_04(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("4"), 
		  .in_square(generic_bg[4]), 
		  .in_character(generic_fg[4]));
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*1), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*1)) 
	ch_05(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("5"), 
		  .in_square(generic_bg[5]), 
		  .in_character(generic_fg[5]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*1)) 
	ch_06(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("6"), 
		  .in_square(generic_bg[6]), 
		  .in_character(generic_fg[6]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*1)) 
	ch_07(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("7"), 
		  .in_square(generic_bg[7]), 
		  .in_character(generic_fg[7]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*2)) 
	ch_08(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("8"), 
		  .in_square(generic_bg[8]), 
		  .in_character(generic_fg[8]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*1), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*2)) 
	ch_09(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("9"), 
		  .in_square(generic_bg[9]), 
		  .in_character(generic_fg[9]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*2)) 
	ch_a(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("a"), 
		  .in_square(generic_bg[10]), 
		  .in_character(generic_fg[10]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*2)) 
	ch_b(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("b"), 
		  .in_square(generic_bg[11]), 
		  .in_character(generic_fg[11]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*3)) 
	ch_c(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("c"), 
		  .in_square(generic_bg[12]), 
		  .in_character(generic_fg[12]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*1), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*3)) 
	ch_d(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("d"), 
		  .in_square(generic_bg[13]), 
		  .in_character(generic_fg[13]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*3)) 
	ch_e(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("e"), 
		  .in_square(generic_bg[14]), 
		  .in_character(generic_fg[14]));
		  
	show_one_char #(.CHAR_X_LOC(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.CHAR_Y_LOC(FIRST_SQRT_Y + GRID_Y_OFFSET + DESFASE_Y_FILA*3)) 
	ch_f(.clk(clk_vga), 
		  .rst(rst), 
		  .hc_visible(hc_visible), 
		  .vc_visible(vc_visible), 
		  .the_char("f"), 
		  .in_square(generic_bg[15]), 
		  .in_character(generic_fg[15]));	  
		  	  	  	  	  	  	  	  	  	  	  	  	  
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X -15 + GRID_X_OFFSET + DESFASE_X_FILA*4), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*3), 
					.MAX_CHARACTER_LINE(3), 
					.ancho_pixel(5), 
					.n(3)) 
	exe(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line("EXE"), 
			.in_square(generic_bg[22]), 
			.in_character(generic_fg[22]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +20+ GRID_X_OFFSET + DESFASE_X_FILA*4), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*0), 
					.MAX_CHARACTER_LINE(1), 
					.ancho_pixel(5), 
					.n(3)) 
	suma(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(8'd43), 
			.in_square(generic_bg[16]), 
			.in_character(generic_fg[16]));		
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +20+ GRID_X_OFFSET + DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*0), 
					.MAX_CHARACTER_LINE(1), 
					.ancho_pixel(5), 
					.n(3)) 
	resta(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(8'd45), 
			.in_square(generic_bg[17]), 
			.in_character(generic_fg[17]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +20+ GRID_X_OFFSET + DESFASE_X_FILA*4), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(1), 
					.ancho_pixel(5), 
					.n(3)) 
	multi(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(8'd42), 
			.in_square(generic_bg[18]), 
			.in_character(generic_fg[18]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +20+ GRID_X_OFFSET + DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(1), 
					.ancho_pixel(5), 
					.n(3)) 
	or1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(8'd238), 
			.in_square(generic_bg[19]), 
			.in_character(generic_fg[19]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +20+ GRID_X_OFFSET + DESFASE_X_FILA*4), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*2), 
					.MAX_CHARACTER_LINE(1), 
					.ancho_pixel(5), 
					.n(3)) 
	and1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(8'd38), 
			.in_square(generic_bg[20]), 
			.in_character(generic_fg[20]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  + GRID_X_OFFSET + DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*2), 
					.MAX_CHARACTER_LINE(2), 
					.ancho_pixel(5), 
					.n(3)) 
	ce(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line("CE"), 
			.in_square(generic_bg[21]), 
			.in_character(generic_fg[21]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X -15 + GRID_X_OFFSET + DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET + DESFASE_Y_FILA*3), 
					.MAX_CHARACTER_LINE(3), 
					.ancho_pixel(5), 
					.n(3)) 
	clr(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line("CLR"), 
			.in_square(generic_bg[23]), 
			.in_character(generic_fg[23]));										
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(PAR_Y_NAME*1), 
					.MAX_CHARACTER_LINE(10), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Operador",8'd32,"1"}), 
			.in_square(generic_OPE_bg[0]), 
			.in_character(generic_OPE_fg[0]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X + 10 + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(PAR_Y_NAME*2 - 5), 
					.MAX_CHARACTER_LINE(8), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_11(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,8'd32,8'd32,operador1_comb}), 
			.in_square(generic_OPR_bg[0]), 
			.in_character(generic_OPR_fg[0]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(PAR_Y_NAME*3), 
					.MAX_CHARACTER_LINE(10), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_2(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Operador",8'd32,"2"}), 
			.in_square(generic_OPE_bg[1]), 
			.in_character(generic_OPE_fg[1]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  + 10 + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4 - 5), 
					.MAX_CHARACTER_LINE(8), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_22(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,8'd32,8'd32,operador2_comb}), 
			.in_square(generic_OPR_bg[1]), 
			.in_character(generic_OPR_fg[1]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +30+ DESFASE_X_FILA*1), 
					.LINE_Y_LOCATION(PAR_Y_NAME*2), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_3(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,"OP",8'd32}), 
			.in_square(generic_OPE_bg[2]), 
			.in_character(generic_OPE_fg[2]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +35+ DESFASE_X_FILA*1), 
					.LINE_Y_LOCATION(PAR_Y_NAME*3 - 5), 
					.MAX_CHARACTER_LINE(3), 
					.ancho_pixel(2), 
					.n(3)) 
	OP_4(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,operador,8'd32}), 
			.in_square(generic_OPR_bg[2]), 
			.in_character(generic_OPR_fg[2]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +50 + DESFASE_X_FILA*4), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4), 
					.MAX_CHARACTER_LINE(3), 
					.ancho_pixel(2), 
					.n(3)) 
	HEX_1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"HEX"}), 
			.in_square(generic_NOT_bg[0]), 
			.in_character(generic_NOT_fg[0]));
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +25 + DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4), 
					.MAX_CHARACTER_LINE(3), 
					.ancho_pixel(2), 
					.n(3)) 
	DEC_1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"DEC"}), 
			.in_square(generic_NOT_bg[1]), 
			.in_character(generic_NOT_fg[1]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +100+ DESFASE_X_FILA*4 ), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4), 
					.MAX_CHARACTER_LINE(2), 
					.ancho_pixel(2), 
					.n(3)) 
	HEX_2(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd170,8'd32}), 
			.in_square(generic_ARROW_bg[0]), 
			.in_character(generic_ARROW_fg[0]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +70+ DESFASE_X_FILA*5), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4), 
					.MAX_CHARACTER_LINE(2), 
					.ancho_pixel(2), 
					.n(3)) 
	DEC_2(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd170,8'd32}), 
			.in_square(generic_ARROW_bg[1]), 
			.in_character(generic_ARROW_fg[1]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  -15+ DESFASE_X_FILA*2), 
					.LINE_Y_LOCATION(PAR_Y_NAME + 15), 
					.MAX_CHARACTER_LINE(10), 
					.ancho_pixel(7), 
					.n(3)) 
					
	RESULT_HEX(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,8'd32,8'd32,8'd32,muda1}), 
			.in_square(generic_RESULT_bg[0]), 
			.in_character(generic_RESULT_fg[0]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  -15+ DESFASE_X_FILA*2), 
					.LINE_Y_LOCATION(PAR_Y_NAME + 15), 
					.MAX_CHARACTER_LINE(10), 
					.ancho_pixel(7), 
					.n(3)) 
					
	RESULT_DEC(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({8'd32,8'd32,8'd32,8'd32,muda1}), 
			.in_square(generic_RESULT_bg[1]), 
			.in_character(generic_RESULT_fg[1]));
																					
	show_one_line #(.LINE_X_LOCATION(PAR_X_NAME), 
					.LINE_Y_LOCATION(PAR_Y_NAME), 
					.MAX_CHARACTER_LINE(16), 
					.ancho_pixel(2), 
					.n(3)) 
	name_1(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Nicolas",8'd32,"Canales",8'd32}), 
			.in_square(generic_NAME_bg[0]), 
			.in_character(generic_NAME_fg[0]));
	
	show_one_line #(.LINE_X_LOCATION(PAR_X_NAME), 
					.LINE_Y_LOCATION(PAR_Y_NAME*2), 
					.MAX_CHARACTER_LINE(16), 
					.ancho_pixel(2), 
					.n(3)) 
	name_2(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Cristobal",8'd32,"Roldan"}), 
			.in_square(generic_NAME_bg[1]), 
			.in_character(generic_NAME_fg[1]));
	
	show_one_line #(.LINE_X_LOCATION(PAR_X_NAME), 
					.LINE_Y_LOCATION(PAR_Y_NAME*3), 
					.MAX_CHARACTER_LINE(16), 
					.ancho_pixel(2), 
					.n(3)) 
	name_3(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Juan",8'd32,"Pi",8'd164,"eiro",8'd32,8'd32,8'd32,8'd32}), 
			.in_square(generic_NAME_bg[2]), 
			.in_character(generic_NAME_fg[2]));
	
	show_one_line #(.LINE_X_LOCATION(PAR_X_NAME), 
					.LINE_Y_LOCATION(PAR_Y_NAME*4), 
					.MAX_CHARACTER_LINE(16), 
					.ancho_pixel(2), 
					.n(3)) 
	name_4(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line({"Elo212",8'd32,"grupo",8'd32,"310"}), 
			.in_square(generic_NAME_bg[3]), 
			.in_character(generic_NAME_fg[3]));
									
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +PAR_X_BIN*1 + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_11(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin14), 
			.in_square(generic_1BIN_bg[0]), 
			.in_character(generic_1BIN_fg[0]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*2 + GRID_X_OFFSET  + DESFASE_X_FILA*1), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_12(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin13), 
			.in_square(generic_1BIN_bg[1]), 
			.in_character(generic_1BIN_fg[1]));
			
    show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*3 + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_13(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin12), 
			.in_square(generic_1BIN_bg[2]), 
			.in_character(generic_1BIN_fg[2]));

	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*4 + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_14(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin11), 
			.in_square(generic_1BIN_bg[3]), 
			.in_character(generic_1BIN_fg[3]));
	
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +PAR_X_BIN*1 + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_21(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin24), 
			.in_square(generic_2BIN_bg[0]), 
			.in_character(generic_2BIN_fg[0]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*2 + GRID_X_OFFSET  + DESFASE_X_FILA*1), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_22(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin23), 
			.in_square(generic_2BIN_bg[1]), 
			.in_character(generic_2BIN_fg[1]));
			
    show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*3 + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_23(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin22), 
			.in_square(generic_2BIN_bg[2]), 
			.in_character(generic_2BIN_fg[2]));

	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*4 + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_24(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin21), 
			.in_square(generic_2BIN_bg[3]), 
			.in_character(generic_2BIN_fg[3]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X  +PAR_X_BIN*1 + GRID_X_OFFSET + DESFASE_X_FILA*0), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_31(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin34), 
			.in_square(generic_3BIN_bg[0]), 
			.in_character(generic_3BIN_fg[0]));
			
	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*2 + GRID_X_OFFSET  + DESFASE_X_FILA*1), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_32(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin33), 
			.in_square(generic_3BIN_bg[1]), 
			.in_character(generic_3BIN_fg[1]));
			
    show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*3 + GRID_X_OFFSET + DESFASE_X_FILA*2), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_33(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin32), 
			.in_square(generic_3BIN_bg[2]), 
			.in_character(generic_3BIN_fg[2]));

	show_one_line #(.LINE_X_LOCATION(FIRST_SQRT_X +PAR_X_BIN*4 + GRID_X_OFFSET + DESFASE_X_FILA*3), 
					.LINE_Y_LOCATION(FIRST_SQRT_Y  + GRID_Y_OFFSET - DESFASE_Y_FILA*1), 
					.MAX_CHARACTER_LINE(4), 
					.ancho_pixel(4), 
					.n(3)) 
	Bin_34(	.clk(clk_vga), 
			.rst(rst), 
			.hc_visible(hc_visible), 
			.vc_visible(vc_visible), 
			.the_line(bin31), 
			.in_square(generic_3BIN_bg[3]), 
			.in_character(generic_3BIN_fg[3]));
							
	logic draw_cursor = (pos_x == matrix_x) && (pos_y == matrix_y);
	
	
	localparam COLOR_BLUE 		= 12'hE40; //ES NARANJO
	localparam COLOR_FONDO_GRILLA	= 12'hDDD;
	localparam COLOR_YELLOW 	= 12'hDDD;
	localparam COLOR_RED		= 12'hF00;
	localparam COLOR_BLACK		= 12'h000;
	localparam COLOR_WHITE		= 12'hFFF;
	localparam COLOR_AZUL_GRIS		= 12'hCCF;
	
	localparam COLOR_BLACK_2		= 12'h223;
	localparam COLOR_GRIS_2		= 12'h567;
	localparam COLOR_WHITE_2		= 12'hDDE;
	localparam COLOR_GRIS		= 12'hBBC;
	localparam COLOR_AZULADO		= 12'h56A;
	always@(*)
		if((hc_visible != 0) && (vc_visible != 0))
		begin

			if(generic_fg[0] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[0] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end
				    
			else if(generic_fg[1] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[1] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[2] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[2] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[3] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[3] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[4] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[4] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[5] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[5] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[6] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[6] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[7] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[7] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[8] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[8] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[9] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[9] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			
			else if(generic_fg[10] > 'd0) begin
			     if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[10] > 'd0)begin
			     if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			else if(generic_fg[11] > 'd0) begin
			 if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[11] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			
			else if(generic_fg[12] > 'd0) begin
			 if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[12] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			
			else if(generic_fg[13] > 'd0) begin
			     if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[13] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			
			else if(generic_fg[14] > 'd0) begin
			     if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[14] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			
			else if(generic_fg[15] > 'd0) begin
			     if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
				    end
			else if(generic_bg[15] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_FONDO_GRILLA; end
				    end	
			 end
			
			else if(generic_fg[16] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[16] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			else if(generic_fg[17] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[17] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[18] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[18] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[19] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[19] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[20] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[20] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[21] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[21] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[22] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[22] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
			
			else if(generic_fg[23] > 'd0) begin
			     if(draw_cursor)begin
				    VGA_COLOR = COLOR_WHITE; end
				 else begin
				    VGA_COLOR = COLOR_BLACK; end
				    end
			else if(generic_bg[23] > 'd0)begin
				if(draw_cursor)begin
				    VGA_COLOR = COLOR_AZULADO; end
				 else begin
				    VGA_COLOR = COLOR_AZUL_GRIS; end
				    end	
				    
            else if(generic_1BIN_fg > 'd0 & STATE==2'b00) begin
              
                    VGA_COLOR = COLOR_WHITE;
                
            end
            else if(generic_1BIN_bg > 'd0 & STATE==2'b00) begin
                
                    VGA_COLOR = COLOR_BLACK;
                
            end
            
            else if(generic_2BIN_fg > 'd0 & STATE==2'b01) begin
                
                    VGA_COLOR = COLOR_WHITE;
                
            end
            else if(generic_2BIN_bg > 'd0 & STATE==2'b01) begin
               
                    VGA_COLOR = COLOR_BLACK;
                
            end
            
            else if(generic_3BIN_fg > 'd0 & STATE==2'b11) begin
                
                    VGA_COLOR = COLOR_WHITE;
             
            end
            else if(generic_3BIN_bg > 'd0 & STATE==2'b11) begin
                
                    VGA_COLOR = COLOR_BLACK;
               
            end
           
			else if(text_sqrt_fg > 'd0)           /////////////COLOR_BLUE
				VGA_COLOR = COLOR_FONDO_GRILLA;
			else if(text_sqrt_bg > 'd0)
				VGA_COLOR = COLOR_BLUE;	
				
			else if(generic_NAME_fg > 'd0)
				VGA_COLOR = COLOR_AZULADO;
			else if(generic_NAME_bg > 'd0)
				VGA_COLOR = COLOR_FONDO_GRILLA;	
			
			else if(generic_OPE_fg > 'd0)
				VGA_COLOR = COLOR_WHITE;
			else if(generic_OPE_bg > 'd0)
				VGA_COLOR = COLOR_AZULADO;
				
		    else if(generic_OPR_fg > 'd0)
				VGA_COLOR = COLOR_WHITE;
			else if(generic_OPR_bg > 'd0)
				VGA_COLOR = COLOR_GRIS;	
			
			else if(generic_NOT_fg[0] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_GRIS_2;
			     end
			     else begin
				    VGA_COLOR = COLOR_WHITE;
				end
				end
			else if(generic_NOT_bg[0] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLACK_2;
			     end
			     else begin
				    VGA_COLOR = COLOR_AZULADO;
				end
				end
				
			else if(generic_ARROW_fg[0] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLUE;
			     end
			     else begin
				    VGA_COLOR = COLOR_WHITE;
				end
				end
			else if(generic_ARROW_bg[0] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_BLUE;	
			     end
			     else begin
				    VGA_COLOR = COLOR_BLUE;	
				end
				end
			
			else if(generic_NOT_fg[1] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_WHITE;
			     end
			     else begin
				    VGA_COLOR = COLOR_GRIS_2;
				end
				end
			else if(generic_NOT_bg[1] > 'd0)begin
				if(mode)begin
			         VGA_COLOR = COLOR_AZULADO;
			     end
			     else begin
				    VGA_COLOR = COLOR_BLACK_2;
				end
				end
				
			else if(generic_ARROW_fg[1] > 'd0)begin
			     if(mode)begin
			         VGA_COLOR = COLOR_WHITE;
			     end
			     else begin
				    VGA_COLOR = COLOR_BLUE;
				end
				end
			else if(generic_ARROW_bg[1] > 'd0) begin
			     if(mode)begin
			         VGA_COLOR = COLOR_BLUE;	
			     end
			     else begin
				    VGA_COLOR = COLOR_BLUE;	
				end
				end
				
			else if(generic_RESULT_fg[0] > 'd0 && mode == 1'b0)
				VGA_COLOR = COLOR_BLACK;
			else if(generic_RESULT_bg[0]> 'd0 && mode == 1'b0)
				VGA_COLOR = COLOR_WHITE_2;		
				
		     else if(generic_RESULT_fg[1] > 'd0 && mode == 1'b1)
				VGA_COLOR = COLOR_BLACK;
				
			else if(generic_RESULT_bg[1]> 'd0 && mode == 1'b1)
				VGA_COLOR = COLOR_WHITE_2;	
				
			//si esta dentro de la grilla.
			else if((hc_visible > CUADRILLA_XI) && (hc_visible <= CUADRILLA_XF) && (vc_visible > CUADRILLA_YI) && (vc_visible <= CUADRILLA_YF))
				if(lines)//lineas negras de la grilla
					VGA_COLOR = COLOR_BLACK;
				else if (draw_cursor) //el cursor 
					VGA_COLOR = COLOR_AZULADO;
			    else if((matrix_x == 3'd4 & matrix_y == 2'd0) || (matrix_x == 3'd5 & matrix_y == 2'd0) ||(matrix_x == 3'd4 & matrix_y == 2'd1) || (matrix_x == 3'd5 & matrix_y == 2'd1) || (matrix_x == 3'd4 & matrix_y == 2'd2) || (matrix_x == 3'd5 & matrix_y == 2'd2)|| (matrix_x == 3'd4 & matrix_y == 2'd3)|| (matrix_x == 3'd5 & matrix_y == 2'd3)) begin
					   VGA_COLOR = COLOR_AZUL_GRIS;	
					end
				else if (mode) begin//el cursor
				    if((matrix_x == 3'd2 & matrix_y == 2'd2) || (matrix_x == 3'd3 & matrix_y == 2'd2) ||(matrix_x == 3'd0 & matrix_y == 2'd3) || (matrix_x == 3'd1 & matrix_y == 2'd3) || (matrix_x == 3'd2 & matrix_y == 2'd3) || (matrix_x == 3'd3 & matrix_y == 2'd3)) begin
					   VGA_COLOR = COLOR_BLACK_2;	
					end
					else begin
					   VGA_COLOR = COLOR_FONDO_GRILLA;
					end
					end
				else
					VGA_COLOR = COLOR_FONDO_GRILLA;
			else
				VGA_COLOR = COLOR_BLUE;//el fondo de la pantalla
		end
		else
			VGA_COLOR = COLOR_BLACK;//esto es necesario para no poner en riesgo la pantalla.

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
endmodule



/**
 * @brief Este modulo cambia los ceros a la izquierda de un numero, por espacios
 * @param value			:Corresponde al valor (en hexa o decimal) al que se le desea hacer el padding.
 * @param no_pading		:Corresponde al equivalente ascii del value includos los ceros a la izquierda
 * @param padding		:Corresponde al equivalente ascii del value, pero sin los ceros a la izquierda.
 */

module space_padding(
input [19:0] value,
	input [39:0]no_pading,
	input logic sw,
	output logic [39:0]padding);
	
	logic	[3:0]	digit_1, digit_2, digit_3, digit_4;
	
	assign digit_1 = (value[7:4]  == 4'h0 & digit_2);
	assign digit_2 = (value[11:8] == 4'h0 & digit_3);
	assign digit_3 = (value[15:12]== 4'h0 & digit_4);
	assign digit_4 = (value[19:16]== 4'h0);
	
	
	always_comb
	begin
		if (digit_1) begin
		      if (sw==1'b1 & value>4'd9) begin
		          padding = { 8'd32,8'd32,8'd32, no_pading[8*2-1:0]};
              end
              else begin
		          padding = { 8'd32,8'd32,8'd32,8'd32, no_pading[8*1-1:0] };		// Num de 0: 4 // Num de digitos: 1
		      end
		end    
		else  begin
		    if (digit_2) begin
              if (sw==1'b1 & value>8'd99) begin
                 padding = {8'd32,8'd32, no_pading[8*3-1:0]};
              end
              else begin
		         padding = {8'd32,8'd32,8'd32, no_pading[8*2-1:0]};		// Num de 0: 3 // Num de digitos: 2
              end
            end
    	 	else begin
	 	        if (digit_3) begin
                    if (sw==1'b1 & value>12'd999) begin
                        padding = { 8'd32, no_pading[8*4-1:0]};		// Num de 0: 1 // Num de digitos: 4
                    end
			        else begin    
			            padding = { 8'd32,8'd32, no_pading[8*3-1:0]};		// Num de 0: 2 // Num de digitos: 3
                    end
                end
		    else begin
                if (digit_4) begin
                    if (sw==1'b1 & value>16'd9999) begin
                         padding = no_pading;
                    end
                    else begin
		                 padding = { 8'd32 , no_pading[8*4-1:0]};		// Num de 0: 1 // Num de digitos: 4
                    end
                end
		        else
			        padding = no_pading;
			    end
			    end
			end             
	end
	/*
space_padding DUT (.value(),.no_pading(),.padding());
*/
endmodule
