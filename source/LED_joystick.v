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

module LED_joystick(
    input		clk,
	
	input [9:0]	xpos,
	input [9:0]	ypos,
	input [1:0]	button,
	
    output		LED1,
    output		LED2,
    output		LED3,
    output		LED4,
    output		LED5
    );
	
	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	reg xPosLED[1:0];
	reg yPosLED[1:0];
	
	// Begin
	always@(posedge clk)
		begin
		
		// Check if the joystick x position has gone beyond a min value
		if (xpos < 400) begin
			xPosLED[0] <= 1'b1;
			end
		else begin
			xPosLED[0] <= 1'b0;
			end
			
		if (xpos > 600) begin
			xPosLED[1] <= 1'b1;
			end
		else begin
			xPosLED[1] <= 1'b0;
			end
			
		// Check if the joystick y position has gone beyond a min value		
		if (ypos > 600) begin
			yPosLED[0] <= 1'b1;
			end
		else begin
			yPosLED[0] <= 1'b0;
			end
			
		if (ypos < 400) begin
			yPosLED[1] <= 1'b1;
			end
		else begin
			yPosLED[1] <= 1'b0;
			end
			
		// end behavior
		end
		
			
	// button assignments
	assign LED5 = button[0]|button[1];
	
	// x lights
	assign LED1 = xPosLED[0];
	assign LED3 = xPosLED[1];
	assign LED4 = yPosLED[0];	
	assign LED2 = yPosLED[1];
	
endmodule
