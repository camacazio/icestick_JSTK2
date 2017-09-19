`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amber Arendas
//
// Create Date:		05/23/2017
// Module Name:		LED_joystick
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Toggles on-board LEDs depending on joystick state
//////////////////////////////////////////////////////////////////////////////////

module colorcontrol(
    input clk,
	input [1:0] button,

	output [23:0] RGBcolor
    );

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	reg cunt [1:0];
	reg red [7:0];
	reg gre [7:0];
	reg blu [7:0];

	always @ (posedge button[0])
		begin
        cunt <= cunt+1;
		end

	// Begin
	always @ (posedge clk)
		begin
		// Color shit
		if (cunt = 0)begin
			red <= 8'b11111111;
			gre <= 8'b00000000;
			blu <= 8'b00000000;
			end

		if (cunt = 1)begin
			red <= 8'b00000000;
			gre <= 8'b11111111;
			blu <= 8'b00000000;
			end

		if (cunt = 2)begin
			red <= 8'b00000000;
			gre <= 8'b00000000;
			blu <= 8'b11111111;
			end

		if (cunt = 3)begin
			red <= 8'b11111111;
			gre <= 8'b11111111;
			blu <= 8'b11111111;
			end
		end

	assign RGBcolor = {red, gre, blu};

endmodule
