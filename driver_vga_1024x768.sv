`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2019 17:09:08
// Design Name: 
// Module Name: driver_vga_1024x768
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


module driver_vga_1024x768(
	input clk_vga,                      // 25 MHz !
	output hs, vs, 
	output [10:0]hc_visible,
	output [10:0]vc_visible
	); 

	//640x480 original
	localparam hpixels = 11'd1312;  // --Value of pixels in a horizontal line
	localparam vlines  = 11'd800;  // --Number of horizontal lines in the display

	localparam hfp  = 11'd16;      // --Horizontal front porch
	localparam hsc  = 11'd96;      // --Horizontal sync
	localparam hbp  = 11'd176;      // --Horizontal back porch
                       
	localparam vfp  = 11'd1;       // --Vertical front porch
	localparam vsc  = 11'd3;       // --Vertical sync
	localparam vbp  = 11'd28;      // --Vertical back porch
	
	
	logic [10:0] hc, hc_next, vc, vc_next;             // --These are the Horizontal and Vertical counters    
	
	assign hc_visible = ((hc < (hpixels - hfp)) && (hc > (hsc + hbp)))?(hc -(hsc + hbp)):11'd0;
	assign vc_visible = ((vc < (vlines - vfp)) && (vc > (vsc + vbp)))?(vc - (vsc + vbp)):11'd0;
	
	
	// --Runs the horizontal counter

	always_comb
		if(hc == hpixels)				// --If the counter has reached the end of pixel count
			hc_next = 11'd0;			// --reset the counter
		else
			hc_next = hc + 11'd1;		// --Increment the horizontal counter

	
	// --Runs the vertical counter
	always_comb
		if(hc == 11'd0)
			if(vc == vlines)
				vc_next = 11'd0;
			else
				vc_next = vc + 11'd1;
		else
			vc_next = vc;
	
	always_ff@(posedge clk_vga)
		{hc, vc} <= {hc_next, vc_next};
		
	assign hs = (hc < hsc) ? 1'b0 : 1'b1;   // --Horizontal Sync Pulse
	assign vs = (vc < vsc) ? 1'b0 : 1'b1;   // --Vertical Sync Pulse
	
endmodule



