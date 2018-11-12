`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan
//
// Create Date:    	06/07/2017
// Module Name:    	Main Module
// Project Name:	Joystick controller
// Target Devices:	ICE40/Icestick
// Tool versions:	APIO/Icestorm
// Description: This module uses the Digilent PMOD JSTK2 to play around with and learn
//						how to interface with serial communications.
//						The positional data of the joystick ranges from 0 to 1023 in
//					 	both the X and Y directions. The center LED will illuminate when a button is pressed.
//					 	SPI mode 0 is used for communication between the PmodJSTK and the FPGA.
//////////////////////////////////////////////////////////////////////////////////

// Top level entitiy

// ==============================================================================
// 								Define Module
// ==============================================================================
module Main_Control(
		clk,
		rst,

		LED,

		JSTK_SS,
		JSTK_MOSI,
		JSTK_MISO,
		JSTK_SCK
		);

	// ===========================================================================
	// 		Port Declarations
	// ===========================================================================
			input  clk;					// 12Mhz onboard clock
			input  rst;					// reset command, not implemented

			output [4:0] LED;		// On-board LEDs

			input  JSTK_MISO;			// Master In Slave Out
			output JSTK_SS;				// Slave Select
			output JSTK_MOSI;			// Master Out Slave In
			output JSTK_SCK;			// Serial Clock

	// ===========================================================================
	// 		Parameters, Regsiters, and Wires
	// ===========================================================================

			// Signal to send/receive data to/from PMOD peripherals
			wire sndRec;

			// Data read from PmodJSTK
			wire [39:0] jstkData;
			// Signal carrying joystick X data
			wire [9:0] XposData;
			// Signal carrying joystick Y data
			wire [9:0] YposData;
			// Holds data to be sent to PmodJSTK
			wire [39:0] sndData;

			// Currently selected color for system
			wire [23:0] RGBcolor;

	// ===========================================================================
	// 		Implementation
	// ===========================================================================

			//-----------------------------------------------
			//		PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(clk),
					.RST(rst),
					.sndRec(sndRec),
					.DIN(sndData),
					.MISO(JSTK_MISO),
					.SS(JSTK_SS),
					.SCLK(JSTK_SCK),
					.MOSI(JSTK_MOSI),
					.DOUT(jstkData)
			);

			//-----------------------------------------------
			//		Cycle colors based on joystick button
			//-----------------------------------------------
			RGB_color_set Select_Color(
					.clk(clk),
					.button(jstkData[1:0]),
					.RGBcolor(RGBcolor)
			);

			//-----------------------------------------------
			//		System update timing Generator
			//-----------------------------------------------
			ClkDiv_20Hz genSndRec(
					.CLK(clk),
					.RST(rst),
					.CLKOUT(sndRec)
			);

			//-----------------------------------------------
			//		Report joystick shit on on-board LEDs
			//-----------------------------------------------
			LED_joystick boardLEDcontroller(
					.clk(clk),
					.xpos(XposData),
					.ypos(YposData),
					.button(jstkData[1:0]),
					.LED(LED)
			);


			//-----------------------------------------------
			//		Assignments
			//-----------------------------------------------

			// Collect joystick state for position state
			assign YposData = {jstkData[25:24], jstkData[39:32]};
			assign XposData = {jstkData[9:8], jstkData[23:16]};

			// Data to be sent to PmodJSTK, first byte signifies to control RGB on PmodJSTK
			assign sndData = {8'b10000100, RGBcolor, 8'b00000000};

endmodule
