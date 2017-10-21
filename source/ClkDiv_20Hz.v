`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan
//
// Create Date:		06/07/2017
// Module Name:		ClkDiv_20Hz
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Converts input 12 MHz clock signal to a 20Hz "update system" clock signal
//////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module ClkDiv_20Hz(
    CLK,										// 12MHz onbaord clock
    RST,										// Reset
    CLKOUT									// New clock output
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
	parameter cntEndVal = 19'h493E0;
	// Current count
	reg [18:0] clkCount = 19'h00000;

// ===========================================================================
// 										Implementation
// ===========================================================================

	//-------------------------------------------------
	// 20Hz Clock Divider Generates timing to initiate Send/Receive
	//-------------------------------------------------
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
