`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amber Arendas
//
// Create Date:		05/23/2017
// Module Name:		colorcontrol
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Cycles the RGB color setting, each of R,G,B are a single byte
//////////////////////////////////////////////////////////////////////////////////

module colorcontrol(
	clk,
	button,
	RGBcolor
    );

	// ===========================================================================
	// 		Port Declarations
	// ===========================================================================
	input clk;
	input [1:0] button;
	output [23:0] RGBcolor; 

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	reg [1:0] cunt = 2'd0;
	reg [7:0] red;
	reg [7:0] gre;
	reg [7:0] blu;

	always @ (posedge button[0])
		begin
			if (button[0])
				cunt <= cunt+1;
		end

	// Begin
	always @ (posedge clk)
		begin
		// white light
		if (cunt == 0)begin
			red <= 8'b01111111;
			gre <= 8'b01111111;
			blu <= 8'b01111111;
			end
			
		// Color shit
		else if (cunt == 1)begin
			red <= 8'b01111111;
			gre <= 8'b00000000;
			blu <= 8'b00000000;
			end

		else if (cunt == 2)begin
			red <= 8'b00000000;
			gre <= 8'b01111111;
			blu <= 8'b00000000;
			end

		else if (cunt == 3)begin
			red <= 8'b00000000;
			gre <= 8'b00000000;
			blu <= 8'b01111111;
			end

		end

	assign RGBcolor = {red, gre, blu};

endmodule
