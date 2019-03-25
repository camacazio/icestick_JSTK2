`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan
//
// Create Date:		05/23/2017
// Module Name:		LED_joystick
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Toggles on-board LEDs depending on joystick state
//////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module LED_joystick(
      input	[1:0]	button,
      input [23:0]  color,
      output [4:0] 	LED
      );
      
	// button assignments
	assign LED[4] = button[1];
	assign LED[3] = button[0];

	// RGB LED lights
	assign LED[0] = ~|color[23:16];
	assign LED[1] = ~|color[15:8];
	assign LED[2] = ~|color[7:0];

endmodule
