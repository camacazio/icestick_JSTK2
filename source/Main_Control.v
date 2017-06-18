//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan Bowler
// 
// Create Date:    	06/07/2017
// Module Name:    	Main Module 
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: This is a demo for the Digilent PmodJSTK. Data is sent and received
//					 to and from the PmodJSTK at a frequency of 10Hz, and positional 
//					 data controls the cross LED pattern on the board. The positional
//					 data of the joystick ranges from 0 to 1023 in both the X and Y
//					 directions. The center LED will illuminate when a button is pressed.
//					 SPI mode 0 is used for communication between the PmodJSTK and the Nexys3.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////

// ============================================================================== 
// 										  Define Module
// ==============================================================================
module Main_Control(
    clk,
	rst,
	
	LED1,
    LED2,
    LED3,
    LED4,
    LED5,
	
	JSTK_SS,
    JSTK_MOSI,
    JSTK_MISO,
    JSTK_SCK
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
			input clk;					// 12Mhz onboard clock
			input rst;					// reset command, not implemented
			
			output LED1;
			output LED2;
			output LED3;
			output LED4;
			output LED5;
			
			input JSTK_MISO;				// Master In Slave Out
			output JSTK_SS;					// Slave Select
			output JSTK_MOSI;				// Master Out Slave In
			output JSTK_SCK;				// Serial Clock

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================

			// Holds data to be sent to PmodJSTK
			wire [7:0] sndData;

			// Signal to send/receive data to/from PmodJSTK
			wire sndRec;

			// Data read from PmodJSTK
			wire [39:0] jstkData;
			// Signal carrying joystick X data
			wire [9:0] XposData;
			// Signal carrying joystick Y data
			wire [9:0] YposData;

	// ===========================================================================
	// 										Implementation
	// ===========================================================================


			//-----------------------------------------------
			//  	  			PmodJSTK Interface
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
			//  			 Send Receive Generator
			//-----------------------------------------------
			ClkDiv_10Hz genSndRec(
					.CLK(clk),
					.RST(rst),
					.CLKOUT(sndRec)
			);
			

			LED_joystick lightcontroller(
					.clk(clk),
					.xpos(XposData),
					.ypos(YposData),
					.button(jstkData[1:0]),
					.LED1(LED1),
					.LED2(LED2),
					.LED3(LED3),
					.LED4(LED4),
					.LED5(LED5)			
			);

			// Use state of switch 0 to select output of X position or Y position data to SSD
			assign XposData = {jstkData[25:24], jstkData[39:32]};
			assign YposData = {jstkData[9:8], jstkData[23:16]};
			
			// Data to be sent to PmodJSTK, lower two bits will turn on leds on PmodJSTK
			assign sndData = 8'b00000000;

endmodule