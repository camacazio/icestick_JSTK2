//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ryan Bowler
// 
// Create Date:		06/07/2017
// Module Name:		ClkDiv_10Hz 
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Converts input 12 MHz clock signal to a 10Hz clock signal
//////////////////////////////////////////////////////////////////////////////////

// ============================================================================== 
// 										  Define Module
// ==============================================================================
module ClkDiv_10Hz(
    CLK,										// 12MHz onbaord clock
    RST,										// Reset
    CLKOUT										// New clock output
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
	parameter cntEndVal = 20'h927C0;
	// Current count
	reg [19:0] clkCount = 20'h00000;
	
// ===========================================================================
// 										Implementation
// ===========================================================================

	//-------------------------------------------------
	//	10Hz Clock Divider Generates Send/Receive signal
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