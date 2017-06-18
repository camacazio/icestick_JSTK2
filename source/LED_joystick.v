//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amber Arendas
// 
// Create Date:		05/23/2017
// Module Name:		LED_Rotation 
// Project Name:	Joystick_Controller
// Target Devices:	ICEStick
// Tool versions:	iCEcube2
// Description: Toggles on-board LEDs depending on joystick state
//////////////////////////////////////////////////////////////////////////////////

module LED_joystick(
    input  clk,
	
	input [9:0] xpos,
	input [9:0] ypos,
	input [1:0] button,
	
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output LED5
    );
	
	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	reg xPosLED;
	
	// Begin
	always@(posedge clk)
		begin
		
		// Check if the joystick x position has gone beyond a min value
		if (xpos > 640) begin
			xPosLED <= 1'b1;
			end
		else begin
			xPosLED <= 1'b0;
			end
			
		end
			

	assign LED5 = button[0]|button[1];
	assign LED1 = xPosLED;
	
endmodule
