`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan
//
// Create Date:    	06/07/2017
// Module Name:    	Main Module
// Project Name:		Joystick and oLED controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: This module uses the Digilent PMOD JSTK2 and oLED screens to
//						play around with and learn how to interface with serial communications.
//						The positional data of the joystick ranges from 0 to 1023 in both the X and Y
//					 	directions. The center LED will illuminate when a button is pressed.
//					 	SPI mode 0 is used for communication between the PmodJSTK and the FPGA.
//						SPI mode 3 is used for communication between the PMOD oLED and the FPGA.
//////////////////////////////////////////////////////////////////////////////////

// Top level entity

// ==============================================================================
// 								Define Module
// ==============================================================================
module Main_Control(
		CLK,
		RST,
        // Status lights
		LED,
		
		// OLED screen
        CS,
        SDIN,
        SCLK,
        DC,
        RES,
        VBAT,
        VDD,
        // Joystick module
		JSTK_SS,
		JSTK_MOSI,
		JSTK_MISO,
		JSTK_SCK
		);

	// ===========================================================================
	// 		Port Declarations
	// ===========================================================================
			input  CLK;					// 12Mhz onboard clock
			input  RST;					// reset command, not implemented

			output [4:0] LED;		    // On-board LEDs
		    
		    // OLED screen signals
            output CS;
            output SDIN;
            output SCLK;
            output DC;
            output RES;
            output VBAT;
            output VDD;
            // Joystick signals
			input  JSTK_MISO;			// Master In Slave Out
			output JSTK_SS;				// Slave Select
			output JSTK_MOSI;			// Master Out Slave In
			output JSTK_SCK;			// Serial Clock

	// ===========================================================================
	// 		Parameters, Regsiters, and Wires
	// ===========================================================================

			// Signal to send/receive data to/from PMOD peripherals
			wire sndRec;
			wire sendRec_screen;

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
			//		PmodOLED Interface
			//-----------------------------------------------
            PmodOLEDCtrl PmodOLEDCtrl_Int(
                    .CLK(CLK),
                    .RST(RST),
                    .UPDATE(sendRec_screen),
                    .CS(CS),
                    .SDIN(SDIN),
                    .SCLK(SCLK),
                    .DC(DC),
                    .RES(RES),
                    .VBAT(VBAT),
                    .VDD(VDD),
                    // Position on the screen
					.xpos(XposData),
                    .ypos(YposData)
            );
            
			//-----------------------------------------------
			//		PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(CLK),
					.RST(RST),
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
					.clk(CLK),
					.button(jstkData[1:0]),
					.RGBcolor(RGBcolor)
			);

			//-----------------------------------------------
			//		System update timing Generator
			//-----------------------------------------------
			ClkDiv_20Hz genSndRec(
					.CLK(CLK),
					.RST(RST),
					.CLKOUT(sndRec),
					.CLKOUTn(sendRec_screen)
			);

			//-----------------------------------------------
			//		Report joystick shit on on-board LEDs
			//-----------------------------------------------
			LED_joystick boardLEDcontroller(
					.color(RGBcolor),
					.button(jstkData[1:0]),
					.LED(LED)
			);

			
			//-----------------------------------------------
			//		Assignments
			//-----------------------------------------------
			
			// Collect joystick state for position state
			assign YposData = {jstkData[25:24], jstkData[39:32]};
			assign XposData = {jstkData[9:8], jstkData[23:16]};

			// Data to be sent to PmodJSTK, first byte is the command to control RGB on PmodJSTK
			assign sndData = {8'b10000100, RGBcolor, 8'b00000000};

endmodule
