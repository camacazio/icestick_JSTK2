`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan Bowler
// 
// Create Date:		05/23/2017
// Module Name:		ClkDiv_66_67kHz 
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Converts input 12 MHz clock signal to a 66.67kHz clock signal for serial comm
//////////////////////////////////////////////////////////////////////////////////

// ============================================================================== 
// 										  Define Module
// ==============================================================================
module ClkDiv_66_67kHz(
    CLK,											// 12MHz onbaord clock
    RST,											// Reset
    CLKOUT											// New clock output
    );

// ===========================================================================
// 										Port Declarations
// ===========================================================================
	input CLK;
	input RST;
	output CLKOUT;

// ===========================================================================
// 							  Parameters, Regsiters, and Wires
// ===========================================================================

	// Output register
	reg CLKOUT = 1'b1;

	// Value to toggle output clock at
	parameter cntEndVal = 7'b1011010;
	// Current count
	reg [6:0] clkCount = 7'b0000000;

// ===========================================================================
// 										Implementation
// ===========================================================================

	//----------------------------------------------
	//						Serial Clock
	//			66.67kHz Clock Divider, period 15us
	//----------------------------------------------
	always @(posedge CLK) begin

			// Reset clock
			if(RST == 1'b1) begin
					CLKOUT <= 1'b0;
					clkCount <= 0;
			end
			// Count/toggle normally
			else begin

					if(clkCount == cntEndVal) begin
							CLKOUT <= ~CLKOUT;
							clkCount <= 0;
					end
					else begin
							clkCount <= clkCount + 1'b1;
					end

			end

	end

endmodule
